import '../../domain/entities/profile.dart';

class ProfileState {
  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
  });

  final Profile? profile;
  final bool isLoading;
  final String? error;

  ProfileState copyWith({
    Profile? profile,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
