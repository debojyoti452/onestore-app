import 'package:flutter/services.dart';
import 'package:onestore_wallet_app/src/data/constants/app_constants.dart';

class AndroidMethodChannel {
  static const MethodChannel _channel =
      MethodChannel(AppConstants.methodChannelId);

  Future<String> platformVersion() async {
    final String version = await _channel
        .invokeMethod(AppConstants.getPlatformVersion);
    return version;
  }

  void terminateApp() async {
    await _channel.invokeMethod(AppConstants.terminateApp);
  }
}
