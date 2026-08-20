import 'app_environment.dart';

class EnvConfig {
  const EnvConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.socketBaseUrl,
    required this.enableNetworkLogging,
    required this.requestTimeout,
  });

  final AppEnvironment environment;
  final String apiBaseUrl;
  final String socketBaseUrl;
  final bool enableNetworkLogging;
  final Duration requestTimeout;

  static const development = EnvConfig(
    environment: AppEnvironment.development,
    apiBaseUrl: 'https://dev-api.fintrack.app',
    socketBaseUrl: 'https://dev-realtime.fintrack.app',
    enableNetworkLogging: true,
    requestTimeout: Duration(seconds: 30),
  );

  static const staging = EnvConfig(
    environment: AppEnvironment.staging,
    apiBaseUrl: 'https://staging-api.fintrack.app',
    socketBaseUrl: 'https://staging-realtime.fintrack.app',
    enableNetworkLogging: true,
    requestTimeout: Duration(seconds: 30),
  );

  static const production = EnvConfig(
    environment: AppEnvironment.production,
    apiBaseUrl: 'https://api.fintrack.app',
    socketBaseUrl: 'https://realtime.fintrack.app',
    enableNetworkLogging: false,
    requestTimeout: Duration(seconds: 20),
  );
}
