import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  
  final AuthService _auth = AuthService();
  final FirestoreService _firestore = FirestoreService();
  
  final Rx<User?> _firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> _userModel = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;

  User? get firebaseUser => _firebaseUser.value;
  UserModel? get user => _userModel.value;

  @override
  void onReady() {
    super.onReady();
    _firebaseUser.bindStream(_auth.authStateChanges);
    ever(_firebaseUser, _setInitialScreen);
  }

  _setInitialScreen(User? user) async {
    if (user == null) {
      Get.offAllNamed('/login');
    } else {
      await refreshUser();
      Get.offAllNamed('/dashboard');
    }
  }

  Future<void> refreshUser() async {
    if (_firebaseUser.value != null) {
      try {
        _userModel.value = await _firestore.getUser(_firebaseUser.value!.uid);
      } catch (e) {
        // Handle case where user is in Firebase Auth but not yet in Firestore
        _userModel.value = null;
      }
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      await _auth.signIn(email, password);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String name, String email, String password, {String? referrerId}) async {
    isLoading.value = true;
    try {
      final cred = await _auth.signUp(email, password);
      if (cred?.user != null) {
        await _firestore.createUser(
          cred!.user!.uid, 
          name, 
          email, 
          referrerId: referrerId
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> googleSignIn() async {
    isLoading.value = true;
    try {
      await _auth.signInWithGoogle();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
