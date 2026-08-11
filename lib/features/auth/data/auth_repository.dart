import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth;

  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  // Signs in with email and password, then returns the Firebase ID token for authenticated requests.
  Future<String> signInAndGetToken({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final idToken = await credential.user!.getIdToken();
    return idToken!;
  }

  // Returns the current user's Firebase ID token, optionally forcing a refresh.
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return _auth.currentUser?.getIdToken(forceRefresh);
  }

  // Signs out the current user.
  Future<void> signOut() => _auth.signOut();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
