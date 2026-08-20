enum AppEnvironment {
  development,
  staging,
  production;

  bool get isDevelopment => this == AppEnvironment.development;
  bool get isStaging => this == AppEnvironment.staging;
  bool get isProduction => this == AppEnvironment.production;

  String get label => switch (this) {
        AppEnvironment.development => 'Development',
        AppEnvironment.staging => 'Staging',
        AppEnvironment.production => 'Production',
      };
}
