import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth;

  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  /// Signs in with email/password via the Firebase client SDK and returns the
  /// ID token. Throws [FirebaseAuthException] on bad credentials.
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

  /// Returns a fresh ID token for the currently signed-in user, or null if
  /// no user is signed in. Pass [forceRefresh] = true to bypass the cache.
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return _auth.currentUser?.getIdToken(forceRefresh);
  }

  Future<void> signOut() => _auth.signOut();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
