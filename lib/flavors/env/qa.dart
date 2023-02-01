import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../main.dart';
import '../flavor_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  FlavorConfig().setupFlavor(flavorConfig: BuildFlavor.qa);
  await mainCommon();
}
