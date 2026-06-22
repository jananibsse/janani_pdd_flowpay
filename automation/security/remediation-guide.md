# FlowPay — Security Remediation Guide
> Document Version: 1.0 | Priority Order: Critical → High → Medium → Low

---

## Overview

This guide provides step-by-step remediation instructions for all findings identified in the [security-review.md](./security-review.md). Each fix is categorized by effort level and includes code examples.

---

## FIX-001: Admin Dashboard — Server-Side Role Enforcement (HIGH)
**Finding**: SEC-007 | **Effort**: Medium (2-3 days)

### Problem
Admin role validation relies on client-side checks. A motivated attacker could bypass Flutter widget conditionals.

### Firestore Security Rules Fix
```
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Admin-only collection
    match /admin_data/{docId} {
      allow read, write: if request.auth != null 
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Analytics — admin only
    match /analytics/{docId} {
      allow read: if request.auth != null 
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
      allow write: if false; // System writes only
    }
    
    // User wallets — user-scoped
    match /wallets/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Transactions — user-scoped
    match /transactions/{txId} {
      allow read: if request.auth != null 
        && resource.data.senderId == request.auth.uid 
        || resource.data.receiverId == request.auth.uid;
      allow create: if request.auth != null 
        && request.resource.data.senderId == request.auth.uid;
      allow update, delete: if false; // Immutable
    }
  }
}
```

### Alternative: Firebase Custom Claims
```javascript
// Cloud Function (Node.js) — Set admin claim
const admin = require('firebase-admin');
admin.initializeApp();

exports.setAdminClaim = functions.https.onCall(async (data, context) => {
  // Only callable by existing admins
  if (!context.auth || !context.auth.token.admin) {
    throw new functions.https.HttpsError('permission-denied', 'Not authorized');
  }
  await admin.auth().setCustomUserClaims(data.uid, { admin: true });
  return { success: true };
});
```

---

## FIX-002: Firestore Security Rules Audit (HIGH)
**Finding**: SEC-001 | **Effort**: Low (1 day)

### Checklist
- [ ] Every collection has `request.auth != null` guard
- [ ] User data scoped to `request.auth.uid == userId`
- [ ] Wallet balances protected (read/write)
- [ ] Transactions immutable after creation
- [ ] Admin endpoints use role-based rules
- [ ] Offline transaction records user-scoped

### Testing Rules
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Emulate and test rules
firebase emulators:start --only firestore
firebase emulators:exec --only firestore "npm test"
```

---

## FIX-003: Certificate Pinning (Android) (HIGH)
**Finding**: SEC-003 | **Effort**: High (3-5 days)

### Android Network Security Config
```xml
<!-- android/app/src/main/res/xml/network_security_config.xml -->
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
  <domain-config cleartextTrafficPermitted="false">
    <domain includeSubdomains="true">firestore.googleapis.com</domain>
    <domain includeSubdomains="true">firebase.googleapis.com</domain>
    <domain includeSubdomains="true">api.razorpay.com</domain>
    <pin-set expiration="2027-01-01">
      <!-- Get current pin: openssl s_client -connect firestore.googleapis.com:443 | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | base64 -->
      <pin digest="SHA-256">YOUR_PIN_BASE64_HERE</pin>
      <pin digest="SHA-256">BACKUP_PIN_BASE64_HERE</pin>
    </pin-set>
  </domain-config>
</network-security-config>
```

```xml
<!-- AndroidManifest.xml — add to <application> -->
android:networkSecurityConfig="@xml/network_security_config"
```

---

## FIX-004: QR Code Input Validation (MEDIUM)
**Finding**: SEC-009 | **Effort**: Low (1 day)

```dart
// lib/services/qr_service.dart — Add payload validation
class QrService {
  static const Map<String, dynamic> _expectedSchema = {
    'userId': String,
    'amount': double,
    'timestamp': int,
    'signature': String,
  };

  static QrPaymentPayload? parseAndValidate(String rawData) {
    try {
      final json = jsonDecode(rawData);
      
      // Validate required fields
      if (!json.containsKey('userId') || !json.containsKey('amount')) {
        throw ValidationException('Invalid QR payload structure');
      }
      
      // Validate amount is positive
      if (json['amount'] <= 0 || json['amount'] > 100000) {
        throw ValidationException('Invalid amount in QR code');
      }
      
      // Validate userId format (Firestore UID)
      if (json['userId'].toString().length < 20) {
        throw ValidationException('Invalid user ID in QR code');
      }
      
      // Validate signature (optional but recommended)
      if (json.containsKey('signature')) {
        if (!_verifySignature(json)) {
          throw ValidationException('QR code signature invalid');
        }
      }
      
      return QrPaymentPayload.fromJson(json);
    } catch (e) {
      debugPrint('QR validation failed: $e');
      return null;
    }
  }
  
  static bool _verifySignature(Map<String, dynamic> payload) {
    // Implement HMAC-SHA256 signature verification
    return true; // Placeholder
  }
}
```

---

## FIX-005: Wallet PIN Hashing (MEDIUM)
**Finding**: SEC-004 | **Effort**: Low (hours)

```dart
// lib/utils/crypto_utils.dart — Verify PIN hashing
import 'package:crypto/crypto.dart';
import 'dart:convert';

class CryptoUtils {
  /// Hash wallet PIN using SHA-256 with salt
  static String hashPin(String pin, String userId) {
    // Never store raw PIN
    final salt = 'flowpay_${userId}_salt';
    final combined = '$pin$salt';
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  /// Verify PIN against stored hash
  static bool verifyPin(String inputPin, String storedHash, String userId) {
    final computedHash = hashPin(inputPin, userId);
    return computedHash == storedHash;
  }
}

// Usage in wallet_service.dart:
// await _firestore.collection('wallets').doc(userId).set({
//   'pinHash': CryptoUtils.hashPin(pin, userId),
// });
```

---

## FIX-006: Razorpay — Server-Side Order Creation (MEDIUM)
**Finding**: SEC-006 | **Effort**: High (3-5 days)

```javascript
// Firebase Cloud Function — Create Razorpay order
const Razorpay = require('razorpay');
const functions = require('firebase-functions');

const razorpay = new Razorpay({
  key_id: functions.config().razorpay.key_id,      // Stored in Cloud config
  key_secret: functions.config().razorpay.secret,  // Never in client
});

exports.createPaymentOrder = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Login required');
  }
  
  const { amount, currency = 'INR' } = data;
  
  if (!amount || amount <= 0 || amount > 100000) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid amount');
  }
  
  const order = await razorpay.orders.create({
    amount: amount * 100, // Convert to paise
    currency,
    receipt: `order_${context.auth.uid}_${Date.now()}`,
  });
  
  return { orderId: order.id, amount: order.amount };
});
```

```dart
// Flutter — Use Cloud Function instead of direct Razorpay key
final callable = FirebaseFunctions.instance.httpsCallable('createPaymentOrder');
final result = await callable.call({'amount': amount});
final orderId = result.data['orderId'];
```

---

## FIX-007: Remove Debug Logs (LOW)
**Finding**: SEC-005 | **Effort**: Low (hours)

```dart
// Replace throughout codebase:
// ❌ BEFORE:
print('User data: $userData');
debugPrint('Wallet balance: $balance');

// ✅ AFTER:
import 'package:flutter/foundation.dart';
if (kDebugMode) {
  debugPrint('Debug info — remove before release');
}

// Or use a proper logger:
import 'package:logger/logger.dart';
final log = Logger(level: kReleaseMode ? Level.nothing : Level.debug);
log.d('Wallet balance loaded');
```

---

## FIX-008: SharedPreferences → flutter_secure_storage (LOW)
**Finding**: SEC-008 | **Effort**: Low (1 day)

```yaml
# pubspec.yaml — Add dependency
dependencies:
  flutter_secure_storage: ^9.0.0
```

```dart
// ❌ BEFORE (SharedPreferences — cleartext):
final prefs = await SharedPreferences.getInstance();
await prefs.setString('user_token', token);

// ✅ AFTER (flutter_secure_storage — encrypted):
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
const storage = FlutterSecureStorage();
await storage.write(key: 'user_token', value: token);
final token = await storage.read(key: 'user_token');
```

---

## FIX-009: Firebase App Check (Recommended)
**Finding**: SEC-002 | **Effort**: Medium (2 days)

```dart
// main.dart — Enable App Check
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Enable App Check (prevents API key abuse)
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.deviceCheck,
    webProvider: ReCaptchaV3Provider('YOUR_RECAPTCHA_SITE_KEY'),
  );
  
  runApp(const FlowPayApp());
}
```

---

## Remediation Timeline

| Sprint | Findings to Fix | Effort |
|--------|----------------|--------|
| Sprint 1 (Week 1) | SEC-007, SEC-001 | 3 days |
| Sprint 2 (Week 2) | SEC-009, SEC-004, SEC-005 | 3 days |
| Sprint 3 (Week 3) | SEC-003, SEC-006 | 5 days |
| Sprint 4 (Week 4) | SEC-008, SEC-010, App Check | 3 days |

**Estimated Total Effort**: 14 developer days
**Target Security Score After Fixes**: 92/100
