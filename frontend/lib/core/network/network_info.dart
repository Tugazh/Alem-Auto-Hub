import 'package:connectivity_plus/connectivity_plus.dart';

/// Network connectivity checker
/// Used for offline-first architecture and smart retry policies
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get connectionStream;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return _isConnectedResult(result);
  }

  @override
  Stream<bool> get connectionStream {
    return _connectivity.onConnectivityChanged.map(
      (result) => _isConnectedResult(result),
    );
  }

  bool _isConnectedResult(List<ConnectivityResult> results) {
    return results.any(
      (result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet,
    );
  }
}
