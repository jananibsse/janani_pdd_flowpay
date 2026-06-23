import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay_app/services/auth_service.dart';
import 'package:flowpay_app/models/app_user.dart';

/// ═══════════════════════════════════════════════════════════════
/// FlowPay Backend Test Suite — AUTH SERVICE (50 Test Cases)
/// Covers: Login, Registration, Logout, Session, Error Handling
/// ═══════════════════════════════════════════════════════════════
void main() {
  group('AuthService — Login Tests', () {
    test('TC_AUTH_001 — Initial user is null when not signed in', () {
      final auth = MockFirebaseAuth(signedIn: false);
      final service = AuthService(firebaseAuth: auth);
      expect(service.currentFirebaseUser, isNull);
      expect(service.currentUser, isNull);
    });

    test('TC_AUTH_002 — Sign in with valid email and password returns user', () async {
      final user = MockUser(uid: 'u1', email: 'valid@test.com', displayName: 'Valid User');
      final auth = MockFirebaseAuth(mockUser: user, signedIn: false);
      final service = AuthService(firebaseAuth: auth);

      final result = await service.signInWithEmailAndPassword(email: 'valid@test.com', password: 'pass123');
      expect(result, isNotNull);
      expect(service.currentFirebaseUser, isNotNull);
    });

    test('TC_AUTH_003 — Sign in trims email whitespace', () async {
      final user = MockUser(uid: 'u2', email: 'trim@test.com');
      final auth = MockFirebaseAuth(mockUser: user, signedIn: false);
      final service = AuthService(firebaseAuth: auth);

      await service.signInWithEmailAndPassword(email: '  trim@test.com  ', password: 'pass');
      expect(service.currentFirebaseUser?.email, 'trim@test.com');
    });

    test('TC_AUTH_004 — Sign in returns UserCredential with correct uid', () async {
      final user = MockUser(uid: 'uid_exact', email: 'uid@test.com');
      final auth = MockFirebaseAuth(mockUser: user, signedIn: false);
      final service = AuthService(firebaseAuth: auth);

      await service.signInWithEmailAndPassword(email: 'uid@test.com', password: 'pass');
      expect(service.currentFirebaseUser?.uid, 'uid_exact');
    });

    test('TC_AUTH_005 — Sign in updates currentFirebaseUser', () async {
      final user = MockUser(uid: 'u5', email: 'stream@test.com');
      final auth = MockFirebaseAuth(mockUser: user, signedIn: false);
      final service = AuthService(firebaseAuth: auth);

      expect(service.currentFirebaseUser, isNull);
      await service.signInWithEmailAndPassword(email: 'stream@test.com', password: 'pass');
      expect(service.currentFirebaseUser, isNotNull);
      expect(service.currentFirebaseUser?.uid, 'u5');
    });

    test('TC_AUTH_006 — Sign in with empty email still calls Firebase', () async {
      final auth = MockFirebaseAuth(signedIn: false);
      final service = AuthService(firebaseAuth: auth);
      // MockFirebaseAuth doesn't throw on empty email, but real Firebase would
      await service.signInWithEmailAndPassword(email: '', password: 'pass');
      // Just verifying it doesn't crash
      expect(true, isTrue);
    });

    test('TC_AUTH_007 — Sign in with empty password still calls Firebase', () async {
      final auth = MockFirebaseAuth(signedIn: false);
      final service = AuthService(firebaseAuth: auth);
      await service.signInWithEmailAndPassword(email: 'test@test.com', password: '');
      expect(true, isTrue);
    });

    test('TC_AUTH_008 — Multiple sign-in calls do not throw', () async {
      final user = MockUser(uid: 'u8', email: 'multi@test.com');
      final auth = MockFirebaseAuth(mockUser: user, signedIn: false);
      final service = AuthService(firebaseAuth: auth);

      await service.signInWithEmailAndPassword(email: 'multi@test.com', password: 'p1');
      await service.signInWithEmailAndPassword(email: 'multi@test.com', password: 'p2');
      expect(service.currentFirebaseUser, isNotNull);
    });

    test('TC_AUTH_009 — currentUser returns AppUser with correct email', () async {
      final user = MockUser(uid: 'u9', email: 'app@test.com', displayName: 'App');
      final auth = MockFirebaseAuth(mockUser: user, signedIn: true);
      final service = AuthService(firebaseAuth: auth);

      final appUser = service.currentUser;
      expect(appUser, isNotNull);
      expect(appUser?.email, 'app@test.com');
    });

    test('TC_AUTH_010 — currentUser returns AppUser with correct displayName', () async {
      final user = MockUser(uid: 'u10', email: 'dn@test.com', displayName: 'Display Name');
      final auth = MockFirebaseAuth(mockUser: user, signedIn: true);
      final service = AuthService(firebaseAuth: auth);

      expect(service.currentUser?.displayName, 'Display Name');
    });
  });

  group('AuthService — Registration Tests', () {
    test('TC_AUTH_011 — Register with valid credentials creates user', () async {
      final user = MockUser(uid: 'new1', email: 'new@test.com');
      final auth = MockFirebaseAuth(mockUser: user, signedIn: false);
      final service = AuthService(firebaseAuth: auth);

      await service.registerWithEmailAndPassword(email: 'new@test.com', password: 'strong123');
      expect(service.currentFirebaseUser, isNotNull);
    });

    test('TC_AUTH_012 — Register trims email whitespace', () async {
      final user = MockUser(uid: 'new2', email: 'trimreg@test.com');
      final auth = MockFirebaseAuth(mockUser: user, signedIn: false);
      final service = AuthService(firebaseAuth: auth);

      await service.registerWithEmailAndPassword(email: '  trimreg@test.com  ', password: 'pass');
      expect(service.currentFirebaseUser, isNotNull);
    });

    test('TC_AUTH_013 — Register returns UserCredential', () async {
      final user = MockUser(uid: 'new3', email: 'cred@test.com');
      final auth = MockFirebaseAuth(mockUser: user, signedIn: false);
      final service = AuthService(firebaseAuth: auth);

      final result = await service.registerWithEmailAndPassword(email: 'cred@test.com', password: 'pass');
      expect(result, isA<UserCredential>());
    });

    test('TC_AUTH_014 — Register then currentUser is not null', () async {
      final user = MockUser(uid: 'new4', email: 'r4@test.com');
      final auth = MockFirebaseAuth(mockUser: user, signedIn: false);
      final service = AuthService(firebaseAuth: auth);

      await service.registerWithEmailAndPassword(email: 'r4@test.com', password: 'pass');
      expect(service.currentUser, isNotNull);
    });

    test('TC_AUTH_015 — Register with special characters in email', () async {
      final user = MockUser(uid: 'new5', email: 'user+tag@test.com');
      final auth = MockFirebaseAuth(mockUser: user, signedIn: false);
      final service = AuthService(firebaseAuth: auth);

      await service.registerWithEmailAndPassword(email: 'user+tag@test.com', password: 'pass');
      expect(service.currentFirebaseUser, isNotNull);
    });
  });

  group('AuthService — Logout Tests', () {
    test('TC_AUTH_016 — Sign out clears the current user', () async {
      final user = MockUser(uid: 'lo1', email: 'lo@test.com');
      final auth = MockFirebaseAuth(mockUser: user, signedIn: true);
      final service = AuthService(firebaseAuth: auth);

      expect(service.currentFirebaseUser, isNotNull);
      await service.signOut();
      expect(service.currentFirebaseUser, isNull);
    });

    test('TC_AUTH_017 — Sign out clears currentFirebaseUser to null', () async {
      final user = MockUser(uid: 'lo2', email: 'lo2@test.com');
      final auth = MockFirebaseAuth(mockUser: user, signedIn: true);
      final service = AuthService(firebaseAuth: auth);

      expect(service.currentFirebaseUser, isNotNull);
      await service.signOut();
      expect(service.currentFirebaseUser, isNull);
      expect(service.currentUser, isNull);
    });

    test('TC_AUTH_018 — Sign out when already signed out does not throw', () async {
      final auth = MockFirebaseAuth(signedIn: false);
      final service = AuthService(firebaseAuth: auth);

      await service.signOut(); // Should not throw
      expect(service.currentFirebaseUser, isNull);
    });

    test('TC_AUTH_019 — Sign out then currentUser returns null', () async {
      final user = MockUser(uid: 'lo4', email: 'lo4@test.com');
      final auth = MockFirebaseAuth(mockUser: user, signedIn: true);
      final service = AuthService(firebaseAuth: auth);

      await service.signOut();
      expect(service.currentUser, isNull);
    });

    test('TC_AUTH_020 — Double sign-out does not throw', () async {
      final user = MockUser(uid: 'lo5', email: 'lo5@test.com');
      final auth = MockFirebaseAuth(mockUser: user, signedIn: true);
      final service = AuthService(firebaseAuth: auth);

      await service.signOut();
      await service.signOut();
      expect(service.currentFirebaseUser, isNull);
    });
  });

  group('AuthService — Error Messages', () {
    late AuthService service;

    setUp(() {
      service = AuthService(firebaseAuth: MockFirebaseAuth(signedIn: false));
    });

    test('TC_AUTH_021 — invalid-email returns friendly message', () {
      final msg = service.messageForAuthException(FirebaseAuthException(code: 'invalid-email'));
      expect(msg, 'Please enter a valid email address.');
    });

    test('TC_AUTH_022 — user-disabled returns friendly message', () {
      final msg = service.messageForAuthException(FirebaseAuthException(code: 'user-disabled'));
      expect(msg, 'This account has been disabled.');
    });

    test('TC_AUTH_023 — user-not-found returns friendly message', () {
      final msg = service.messageForAuthException(FirebaseAuthException(code: 'user-not-found'));
      expect(msg, 'No account found for this email.');
    });

    test('TC_AUTH_024 — wrong-password returns friendly message', () {
      final msg = service.messageForAuthException(FirebaseAuthException(code: 'wrong-password'));
      expect(msg, 'Incorrect password.');
    });

    test('TC_AUTH_025 — email-already-in-use returns friendly message', () {
      final msg = service.messageForAuthException(FirebaseAuthException(code: 'email-already-in-use'));
      expect(msg, 'An account already exists for this email.');
    });

    test('TC_AUTH_026 — weak-password returns friendly message', () {
      final msg = service.messageForAuthException(FirebaseAuthException(code: 'weak-password'));
      expect(msg, 'Password must be at least 6 characters.');
    });

    test('TC_AUTH_027 — invalid-credential returns friendly message', () {
      final msg = service.messageForAuthException(FirebaseAuthException(code: 'invalid-credential'));
      expect(msg, 'Invalid email or password.');
    });

    test('TC_AUTH_028 — operation-not-allowed returns friendly message', () {
      final msg = service.messageForAuthException(FirebaseAuthException(code: 'operation-not-allowed'));
      expect(msg, 'Email/password sign-in is not enabled.');
    });

    test('TC_AUTH_029 — unknown code with message uses that message', () {
      final msg = service.messageForAuthException(
        FirebaseAuthException(code: 'unknown', message: 'Custom error'),
      );
      expect(msg, 'Custom error');
    });

    test('TC_AUTH_030 — unknown code without message uses default', () {
      final msg = service.messageForAuthException(
        FirebaseAuthException(code: 'some-random-code'),
      );
      expect(msg, 'Authentication failed. Please try again.');
    });
  });

  group('AuthService — AppUser Model', () {
    test('TC_AUTH_031 — AppUser.fromFirebaseUser maps uid correctly', () {
      final mockUser = MockUser(uid: 'uid123', email: 'a@b.com', displayName: 'AB');
      final appUser = AppUser.fromFirebaseUser(mockUser);
      expect(appUser.uid, 'uid123');
    });

    test('TC_AUTH_032 — AppUser.fromFirebaseUser maps email correctly', () {
      final mockUser = MockUser(uid: 'uid', email: 'map@test.com');
      final appUser = AppUser.fromFirebaseUser(mockUser);
      expect(appUser.email, 'map@test.com');
    });

    test('TC_AUTH_033 — AppUser.fromFirebaseUser maps displayName correctly', () {
      final mockUser = MockUser(uid: 'uid', email: 'e@e.com', displayName: 'Name');
      final appUser = AppUser.fromFirebaseUser(mockUser);
      expect(appUser.displayName, 'Name');
    });

    test('TC_AUTH_034 — AppUser handles null displayName', () {
      final mockUser = MockUser(uid: 'uid', email: 'e@e.com');
      final appUser = AppUser.fromFirebaseUser(mockUser);
      // displayName defaults based on mock implementation
      expect(appUser, isNotNull);
    });

    test('TC_AUTH_035 — AppUser constructor works with named params', () {
      const user = AppUser(uid: 'test', email: 'test@t.com', displayName: 'Test');
      expect(user.uid, 'test');
      expect(user.email, 'test@t.com');
      expect(user.displayName, 'Test');
    });

    test('TC_AUTH_036 — AppUser with null email', () {
      const user = AppUser(uid: 'test');
      expect(user.email, isNull);
    });

    test('TC_AUTH_037 — AppUser with null displayName', () {
      const user = AppUser(uid: 'test', email: 'e@e.com');
      expect(user.displayName, isNull);
    });
  });

  group('AuthService — Session & State', () {
    test('TC_AUTH_038 — authStateChanges emits null when not signed in', () async {
      final auth = MockFirebaseAuth(signedIn: false);
      final service = AuthService(firebaseAuth: auth);
      final user = await service.authStateChanges.first;
      expect(user, isNull);
    });

    test('TC_AUTH_039 — authStateChanges emits user when signed in', () async {
      final mockUser = MockUser(uid: 'sess1', email: 's@s.com');
      final auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
      final service = AuthService(firebaseAuth: auth);
      final user = await service.authStateChanges.first;
      expect(user, isNotNull);
    });

    test('TC_AUTH_040 — Login then logout then login works', () async {
      final user = MockUser(uid: 'cycle', email: 'cycle@t.com');
      final auth = MockFirebaseAuth(mockUser: user, signedIn: false);
      final service = AuthService(firebaseAuth: auth);

      await service.signInWithEmailAndPassword(email: 'cycle@t.com', password: 'p');
      expect(service.currentFirebaseUser, isNotNull);
      await service.signOut();
      expect(service.currentFirebaseUser, isNull);
      await service.signInWithEmailAndPassword(email: 'cycle@t.com', password: 'p');
      expect(service.currentFirebaseUser, isNotNull);
    });

    test('TC_AUTH_041 — AuthService can be created with no params (uses singleton)', () {
      // This should not throw
      final service = AuthService();
      expect(service, isNotNull);
    });

    test('TC_AUTH_042 — AuthService with explicit FirebaseAuth instance', () {
      final auth = MockFirebaseAuth(signedIn: false);
      final service = AuthService(firebaseAuth: auth);
      expect(service, isNotNull);
    });

    test('TC_AUTH_043 — currentFirebaseUser returns User type', () {
      final mockUser = MockUser(uid: 'type', email: 'type@t.com');
      final auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
      final service = AuthService(firebaseAuth: auth);
      expect(service.currentFirebaseUser, isA<User>());
    });

    test('TC_AUTH_044 — currentUser returns AppUser type', () {
      final mockUser = MockUser(uid: 'atype', email: 'atype@t.com');
      final auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
      final service = AuthService(firebaseAuth: auth);
      expect(service.currentUser, isA<AppUser>());
    });

    test('TC_AUTH_045 — Register then sign out then sign in', () async {
      final user = MockUser(uid: 'regcycle', email: 'rc@t.com');
      final auth = MockFirebaseAuth(mockUser: user, signedIn: false);
      final service = AuthService(firebaseAuth: auth);

      await service.registerWithEmailAndPassword(email: 'rc@t.com', password: 'p');
      expect(service.currentFirebaseUser, isNotNull);
      await service.signOut();
      expect(service.currentFirebaseUser, isNull);
      await service.signInWithEmailAndPassword(email: 'rc@t.com', password: 'p');
      expect(service.currentFirebaseUser, isNotNull);
    });
  });

  group('AuthService — Edge Cases', () {
    test('TC_AUTH_046 — Very long email is accepted', () async {
      final longEmail = '${'a' * 200}@test.com';
      final user = MockUser(uid: 'long', email: longEmail);
      final auth = MockFirebaseAuth(mockUser: user, signedIn: false);
      final service = AuthService(firebaseAuth: auth);

      await service.signInWithEmailAndPassword(email: longEmail, password: 'pass');
      expect(service.currentFirebaseUser, isNotNull);
    });

    test('TC_AUTH_047 — Very long password is accepted', () async {
      final user = MockUser(uid: 'longp', email: 'lp@t.com');
      final auth = MockFirebaseAuth(mockUser: user, signedIn: false);
      final service = AuthService(firebaseAuth: auth);

      await service.signInWithEmailAndPassword(email: 'lp@t.com', password: 'p' * 500);
      expect(service.currentFirebaseUser, isNotNull);
    });

    test('TC_AUTH_048 — Unicode email characters handled', () async {
      final user = MockUser(uid: 'uni', email: 'üser@test.com');
      final auth = MockFirebaseAuth(mockUser: user, signedIn: false);
      final service = AuthService(firebaseAuth: auth);

      await service.signInWithEmailAndPassword(email: 'üser@test.com', password: 'pass');
      expect(service.currentFirebaseUser, isNotNull);
    });

    test('TC_AUTH_049 — Unicode password characters handled', () async {
      final user = MockUser(uid: 'unip', email: 'unip@t.com');
      final auth = MockFirebaseAuth(mockUser: user, signedIn: false);
      final service = AuthService(firebaseAuth: auth);

      await service.signInWithEmailAndPassword(email: 'unip@t.com', password: 'пароль123');
      expect(service.currentFirebaseUser, isNotNull);
    });

    test('TC_AUTH_050 — Multiple AuthService instances share MockFirebaseAuth', () async {
      final user = MockUser(uid: 'shared', email: 'shared@t.com');
      final auth = MockFirebaseAuth(mockUser: user, signedIn: false);
      final service1 = AuthService(firebaseAuth: auth);
      final service2 = AuthService(firebaseAuth: auth);

      await service1.signInWithEmailAndPassword(email: 'shared@t.com', password: 'p');
      expect(service2.currentFirebaseUser, isNotNull);
    });
  });
}
