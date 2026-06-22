import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flowpay_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  group('AuthService Tests', () {
    late MockFirebaseAuth mockAuth;
    late AuthService authService;

    setUp(() {
      mockAuth = MockFirebaseAuth(signedIn: false);
      authService = AuthService(firebaseAuth: mockAuth);
    });

    test('Initial user is null', () {
      expect(authService.currentFirebaseUser, isNull);
    });

    test('Sign in with valid credentials updates user', () async {
      final user = MockUser(
        isAnonymous: false,
        uid: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      
      final auth = MockFirebaseAuth(mockUser: user, signedIn: false);
      final service = AuthService(firebaseAuth: auth);

      await service.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(service.currentFirebaseUser, isNotNull);
      expect(service.currentFirebaseUser?.uid, 'user123');
    });

    test('Register with valid credentials logs user in', () async {
       final user = MockUser(
        isAnonymous: false,
        uid: 'user_new',
        email: 'new@example.com',
      );
      
      final auth = MockFirebaseAuth(mockUser: user, signedIn: false);
      final service = AuthService(firebaseAuth: auth);

      await service.registerWithEmailAndPassword(
        email: 'new@example.com',
        password: 'password123',
      );

      expect(service.currentFirebaseUser, isNotNull);
      expect(service.currentFirebaseUser?.email, 'new@example.com');
    });

    test('Sign out clears the user', () async {
      final user = MockUser(uid: 'user123', email: 'test@example.com');
      final auth = MockFirebaseAuth(mockUser: user, signedIn: true);
      final service = AuthService(firebaseAuth: auth);

      expect(service.currentFirebaseUser, isNotNull);

      await service.signOut();

      expect(service.currentFirebaseUser, isNull);
    });

    test('AuthException messages map correctly', () {
      final exception = FirebaseAuthException(code: 'user-not-found');
      final message = authService.messageForAuthException(exception);
      expect(message, 'No account found for this email.');
      
      final defaultException = FirebaseAuthException(code: 'unknown', message: 'Unknown error');
      final defaultMessage = authService.messageForAuthException(defaultException);
      expect(defaultMessage, 'Unknown error');
    });
  });
}
