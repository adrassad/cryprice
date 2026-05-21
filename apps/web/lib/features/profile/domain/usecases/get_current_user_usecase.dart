import 'package:cryprice_frontend/features/profile/domain/entities/public_user.dart';
import 'package:cryprice_frontend/features/profile/domain/repositories/profile_repository.dart';

class GetCurrentUserUseCase {
  GetCurrentUserUseCase(this._repository);

  final ProfileRepository _repository;

  Future<PublicUser> execute() => _repository.getCurrentUser();
}
