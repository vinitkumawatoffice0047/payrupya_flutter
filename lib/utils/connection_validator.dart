//
// class ConnectionValidator{
//   Future<bool> check() async {
//     //var connectivityResult = await (Connectivity().checkConnectivity());
//     // if (connectivityResult == ConnectivityResult.mobile) {
//     //   return false;
//     // } else if (connectivityResult == ConnectivityResult.wifi) {
//     //   return false;
//     // }else{
//     //   return false;
//     // }
//      return false;
//   }
// }


import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionValidator {
  static Future<bool> isConnected() async {
    try {
      // Modern connectivity_plus returns List<ConnectivityResult>
      final List<ConnectivityResult> connectivityResult =
      await Connectivity().checkConnectivity();

      // Check if any valid connection type exists
      return connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.ethernet);
    } catch (e) {
      print("Connectivity Check Error: $e");
      // If error occurs, assume connected (don't block user)
      return true;
    }
  }

  /// Alternative: Real-time connectivity listener
  static Stream<bool> connectivityStream() {
    return Connectivity().onConnectivityChanged.map((List<ConnectivityResult> result) {
      return result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.ethernet);
    });
  }
}
