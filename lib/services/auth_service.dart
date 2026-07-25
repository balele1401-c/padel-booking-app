import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'user_service.dart';

class AuthService {
  final FirebaseAuth _auth;
  final UserService _userService;

  AuthService({
    FirebaseAuth? auth,
    UserService? userService,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _userService = userService ?? UserService();

  /// Get currently authenticated Firebase User
  User? get currentUser => _auth.currentUser;

  /// Stream of Firebase Auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign Up with Email, Password, Name, and Phone Number
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    String role = 'customer',
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw Exception('Registrasi gagal, pengguna tidak ditemukan.');
    }

    // Update Firebase display name
    await firebaseUser.updateDisplayName(name.trim());

    // Create user profile document in Firestore
    final newUser = UserModel(
      id: firebaseUser.uid,
      name: name.trim(),
      email: email.trim(),
      phoneNumber: phoneNumber.trim(),
      role: role,
      createdAt: DateTime.now(),
    );

    await _userService.createUser(newUser);
    return newUser;
  }

  /// Sign In with Email and Password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw Exception('Login gagal, akun tidak terautentikasi.');
    }

    // Fetch user profile from Firestore to get role and details
    final userModel = await _userService.getUser(firebaseUser.uid);
    if (userModel == null) {
      throw Exception('Data profil pengguna tidak ditemukan di database.');
    }

    return userModel;
  }

  /// Send Password Reset Email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Fetch user profile for currently logged in user
  Future<UserModel?> getCurrentUserProfile() async {
    final firebaseUser = currentUser;
    if (firebaseUser == null) return null;
    return await _userService.getUser(firebaseUser.uid);
  }
}
