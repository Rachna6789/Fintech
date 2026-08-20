sealed class Failure {
  const Failure({required this.message, this.code, this.cause});

  final String message;
  final String? code;
  final Object? cause;
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code, super.cause});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code, super.cause});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code, super.cause});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code, super.cause});
}

class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.code, super.cause});
}
