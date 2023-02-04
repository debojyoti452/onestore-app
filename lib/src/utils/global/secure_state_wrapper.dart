import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:security_module/handler/security_module_plugin.dart';

abstract class SecureStateWrapper<T extends StatefulWidget>
    extends State<T> with WidgetsBindingObserver {
  late SecurityModule securityModule;

  void onInit();

  void onStop();

  void onPause();

  void onResume();

  void onDestroy();

  void onDispose();

  Widget onBuild(BuildContext context);

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    if (!kDebugMode) {
      securityModule = SecurityModule();
      checkBiometricSupport();
    }
    super.initState();
    onInit();
  }

  @override
  Widget build(BuildContext context) {
    return onBuild(context);
  }

  void checkBiometricSupport() async {
    var isBiometricSupport =
        await securityModule.hasBiometricSupport();
    if (isBiometricSupport == true) {
      await securityModule.authenticate();
    } else {
      /// show alert dialog
      // BotToast.showWidget(toastBuilder: (_) {
      //   return AlertDialog(
      //     title:
      //         const Text('Biometric / Auth not supported'),
      //     content: const Text(
      //         'Your device does not support biometric authentication'),
      //     actions: [
      //       TextButton(
      //         onPressed: () {
      //           // close app
      //           Navigator.of(context).pop();
      //         },
      //         child: const Text('OK'),
      //       ),
      //     ],
      //   );
      // });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (!kDebugMode) {
          checkBiometricSupport();
        }
        onResume();
        break;
      case AppLifecycleState.inactive:
        onStop();
        break;
      case AppLifecycleState.paused:
        onPause();
        break;
      case AppLifecycleState.detached:
        onDestroy();
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
