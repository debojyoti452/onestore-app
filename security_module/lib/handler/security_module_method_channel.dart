import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:security_module/constants/security_constants.dart';

import 'security_module_platform_interface.dart';

/// An implementation of [SecurityModulePlatform] that uses method channels.
class MethodChannelSecurityModule
    extends SecurityModulePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel =
      const MethodChannel(SecurityConstants.CHANNEL_NAME);

  /// Checks if the device has biometric support.
  @override
  Future<bool?> hasBiometricSupport() async {
    return await methodChannel.invokeMethod<bool>(
        SecurityConstants.HAS_BIOMETRIC_SUPPORT);
  }

  /// Authenticates the user.
  @override
  Future<dynamic> authenticate() async {
    return await methodChannel.invokeMethod<dynamic>(
        SecurityConstants.AUTHENTICATE);
  }

  @override
  Future<dynamic> secureApp({required int flags}) {
    return methodChannel.invokeMethod(
      SecurityConstants.SECURE_APP,
      {
        SecurityConstants.SECURE_APP: flags,
      },
    );
  }
}
