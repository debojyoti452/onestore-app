import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'security_module_method_channel.dart';

abstract class SecurityModulePlatform
    extends PlatformInterface {
  /// Constructs a SecurityModulePlatform.
  SecurityModulePlatform() : super(token: _token);

  static final Object _token = Object();

  static SecurityModulePlatform _instance =
      MethodChannelSecurityModule();

  /// The default instance of [SecurityModulePlatform] to use.
  ///
  /// Defaults to [MethodChannelSecurityModule].
  static SecurityModulePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SecurityModulePlatform] when
  /// they register themselves.
  static set instance(SecurityModulePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Checks if the device has biometric support.
  Future<bool?> hasBiometricSupport() {
    throw UnimplementedError(
        'hasBiometricSupport() has not been implemented.');
  }

  /// Authenticates the user.
  Future<dynamic> authenticate() {
    throw UnimplementedError(
        'authenticate() has not been implemented.');
  }

  /// Secure App with WindowManager Flags
  Future<dynamic> secureApp({required int flags}) {
    throw UnimplementedError(
        'secureApp() has not been implemented.');
  }
}
