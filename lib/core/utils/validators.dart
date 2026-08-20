class Validators {
  const Validators._();

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  static String? email(String? value) {
    final requiredError = required(value, fieldName: 'Email');
    if (requiredError != null) return requiredError;

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? password(String? value) {
    final requiredError = required(value, fieldName: 'Password');
    if (requiredError != null) return requiredError;

    if (value!.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    return null;
  }

  static String? positiveAmount(String? value) {
    final requiredError = required(value, fieldName: 'Amount');
    if (requiredError != null) return requiredError;

    final parsed = num.tryParse(value!.trim());
    if (parsed == null || parsed <= 0) {
      return 'Enter an amount greater than zero.';
    }
    return null;
  }
}
