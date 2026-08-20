import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/firebase_auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/datasources/price_alert_remote_data_source.dart';
import '../../data/repositories/price_alert_repository_impl.dart';
import '../../domain/repositories/price_alert_repository.dart';
import '../../domain/usecases/create_price_alert_usecase.dart';
import '../../domain/usecases/delete_price_alert_usecase.dart';
import '../../domain/usecases/set_price_alert_enabled_usecase.dart';
import '../../domain/usecases/trigger_price_alert_usecase.dart';
import '../../domain/usecases/watch_price_alerts_usecase.dart';
import '../controllers/alerts_controller.dart';
import '../state/alerts_state.dart';

final priceAlertRemoteDataSourceProvider = Provider<PriceAlertRemoteDataSource>(
  (ref) {
    return PriceAlertRemoteDataSource(
      authService: ref.watch(firebaseAuthServiceProvider),
      firestoreService: ref.watch(firestoreServiceProvider),
      notificationService: ref.watch(notificationServiceProvider),
    );
  },
);

final priceAlertRepositoryProvider = Provider<PriceAlertRepository>((ref) {
  return PriceAlertRepositoryImpl(ref.watch(priceAlertRemoteDataSourceProvider));
});

final watchPriceAlertsUseCaseProvider = Provider<WatchPriceAlertsUseCase>(
  (ref) => WatchPriceAlertsUseCase(ref.watch(priceAlertRepositoryProvider)),
);

final createPriceAlertUseCaseProvider = Provider<CreatePriceAlertUseCase>(
  (ref) => CreatePriceAlertUseCase(ref.watch(priceAlertRepositoryProvider)),
);

final deletePriceAlertUseCaseProvider = Provider<DeletePriceAlertUseCase>(
  (ref) => DeletePriceAlertUseCase(ref.watch(priceAlertRepositoryProvider)),
);

final setPriceAlertEnabledUseCaseProvider = Provider<SetPriceAlertEnabledUseCase>(
  (ref) => SetPriceAlertEnabledUseCase(ref.watch(priceAlertRepositoryProvider)),
);

final triggerPriceAlertUseCaseProvider = Provider<TriggerPriceAlertUseCase>(
  (ref) => TriggerPriceAlertUseCase(ref.watch(priceAlertRepositoryProvider)),
);

final alertsControllerProvider = NotifierProvider<AlertsController, AlertsState>(
  AlertsController.new,
);
