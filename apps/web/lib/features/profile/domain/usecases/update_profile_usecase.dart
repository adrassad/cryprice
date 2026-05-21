import 'package:cryprice_frontend/features/profile/domain/entities/public_user.dart';
import 'package:cryprice_frontend/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfileUseCase {
  UpdateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<PublicUser> execute(Map<String, Object?> patch) => _repository.updateProfile(patch);
}
