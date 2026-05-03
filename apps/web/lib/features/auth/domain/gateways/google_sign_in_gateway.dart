abstract class GoogleSignInGateway {
  Future<String?> getIdToken();

  Future<void> signOut();
}
