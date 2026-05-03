import 'package:crypto_tracker_app/features/auth/data/datasources/google_id_token_provider.dart';
import 'package:crypto_tracker_app/features/auth/domain/gateways/google_sign_in_gateway.dart';

class GoogleSignInGatewayImpl implements GoogleSignInGateway {
  GoogleSignInGatewayImpl(this._provider);

  final GoogleIdTokenProvider _provider;

  @override
  Future<String?> getIdToken() => _provider.getIdToken();

  @override
  Future<void> signOut() => _provider.signOut();
}
