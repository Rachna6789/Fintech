import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../state/profile_state.dart';

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController(this._repository) : super(const ProfileState());

  final ProfileRepository _repository;

  Stream<Profile?> watchProfile() => _repository.watchProfile();

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.getProfile();
    switch (result) {
      case Success<Profile?>():
        state = state.copyWith(profile: result.value, isLoading: false);
      case FailureResult<Profile?>():
        state = state.copyWith(isLoading: false, error: result.failure.message);
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? baseCurrency,
    String? photoUrl,
    bool? isDarkMode,
    bool? notificationsEnabled,
    bool? biometricEnabled,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.updateProfile(
      displayName: displayName,
      baseCurrency: baseCurrency,
      photoUrl: photoUrl,
      isDarkMode: isDarkMode,
      notificationsEnabled: notificationsEnabled,
      biometricEnabled: biometricEnabled,
    );
    switch (result) {
      case Success<Profile>():
        state = state.copyWith(profile: result.value, isLoading: false);
      case FailureResult<Profile>():
        state = state.copyWith(isLoading: false, error: result.failure.message);
    }
  }

  Future<void> uploadProfilePicture(String path, dynamic file) async {
    final result = await _repository.uploadProfilePicture(path, file);
    switch (result) {
      case Success<String>():
        await updateProfile(photoUrl: result.value);
      case FailureResult<String>():
        state = state.copyWith(error: result.failure.message);
    }
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.deleteAccount();
    switch (result) {
      case Success<void>():
        state = state.copyWith(profile: null, isLoading: false);
      case FailureResult<void>():
        state = state.copyWith(isLoading: false, error: result.failure.message);
    }
  }
}
