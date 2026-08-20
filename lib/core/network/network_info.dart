import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final networkInfoProvider = Provider<NetworkInfo>(
  (ref) => NetworkInfo(Connectivity()),
);

class NetworkInfo {
  const NetworkInfo(this._connectivity);

  final Connectivity _connectivity;

  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }

  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (results) => results.any((result) => result != ConnectivityResult.none),
    );
  }
}
