import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/profile/domain/entities/profile.dart';

void main() {
  group('Profile', () {
    test('copyWith updates the editable fields', () {
      const profile = Profile(
        uid: 'user-1',
        email: 'user@example.com',
        displayName: 'Jane',
        baseCurrency: 'USD',
        photoUrl: null,
        isDarkMode: false,
        notificationsEnabled: true,
        biometricEnabled: true,
      );

      final updated = profile.copyWith(
        displayName: 'Jane Doe',
        isDarkMode: true,
      );

      expect(updated.displayName, 'Jane Doe');
      expect(updated.baseCurrency, 'USD');
      expect(updated.isDarkMode, isTrue);
      expect(updated.notificationsEnabled, isTrue);
    });
  });
}
