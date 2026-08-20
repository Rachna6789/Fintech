import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_environment.dart';
import 'env_config.dart';

final appEnvironmentProvider = Provider<AppEnvironment>(
  (ref) => AppEnvironment.development,
);

final envConfigProvider = Provider<EnvConfig>((ref) {
  return switch (ref.watch(appEnvironmentProvider)) {
    AppEnvironment.development => EnvConfig.development,
    AppEnvironment.staging => EnvConfig.staging,
    AppEnvironment.production => EnvConfig.production,
  };
});
