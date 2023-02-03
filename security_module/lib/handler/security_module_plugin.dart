import 'security_module_platform_interface.dart';

class SecurityModule {
  Future<bool?> hasBiometricSupport() async {
    return await SecurityModulePlatform.instance
        .hasBiometricSupport();
  }

  Future<dynamic> authenticate() async {
    return await SecurityModulePlatform.instance
        .authenticate();
  }
}
