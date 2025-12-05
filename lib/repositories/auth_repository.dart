import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await Future.delayed(const Duration(milliseconds: 300));

      await result.user?.reload();
      final User? refreshedUser = _firebaseAuth.currentUser;

      if (refreshedUser == null) {
        throw Exception('User authentication failed');
      }

      return UserModel.fromFirebaseUser(refreshedUser);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred: ${e.toString()}';
    }
  }

  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await Future.delayed(const Duration(milliseconds: 300));

      await result.user?.reload();
      final User? refreshedUser = _firebaseAuth.currentUser;

      if (refreshedUser == null) {
        throw Exception('User registration failed');
      }

      return UserModel.fromFirebaseUser(refreshedUser);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred: ${e.toString()}';
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'invalid-credential':
        return 'Invalid credentials provided.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An error occurred: ${e.message ?? e.code}';
    }
  }
}
