import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'firestore_service.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestore = FirestoreService();
  User? _user;

  AuthService() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the Google Authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Case: User cancelled

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final cred = await _auth.signInWithCredential(credential);
      
      if (cred.user != null) {
        // Automatically check/create user in Firestore
        await _firestore.checkOrCreateUser(cred.user!.uid, cred.user!.displayName ?? 'New User', cred.user!.email ?? '');
      }
      
      return cred;
    } catch (e) {
      if (kDebugMode) print('Google Sign-In Error: $e');
      throw 'Google Sign-In failed. Please check your internet and try again.';
    }
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return 'No user found with this email.';
      case 'wrong-password': return 'Incorrect password.';
      case 'email-already-in-use': return 'This email is already registered.';
      case 'invalid-email': return 'Please enter a valid email address.';
      case 'weak-password': return 'Password is too weak.';
      case 'operation-not-allowed': return 'Email/Password sign-in is not enabled.';
      default: return e.message ?? 'Authentication failed.';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut(); // Ensure Google session is cleared for next login
  }
}

