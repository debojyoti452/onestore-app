import 'package:flutter/cupertino.dart';

enum BuildFlavor { dev, qa, prod }

class FlavorConfig {
  //Singleton Initialization
  static final FlavorConfig _obj = FlavorConfig._internal();

  static FlavorConfig get instance => _obj;

  //instance
  BuildFlavor? buildFlavor;

  //Configurations..
  String? appId = 'com.swing.onestore.dev';

  factory FlavorConfig() {
    return _obj;
  }

  FlavorConfig._internal();

  void setupFlavor({@required BuildFlavor? flavorConfig}) {
    switch (flavorConfig) {
      case BuildFlavor.dev:
        {
          buildFlavor = BuildFlavor.dev;
          appId = 'com.swing.onestore.dev';
        }
        break;
      case BuildFlavor.qa:
        {
          buildFlavor = BuildFlavor.qa;
          appId = 'com.swing.onestore.qa';
        }
        break;
      case BuildFlavor.prod:
        {
          buildFlavor = BuildFlavor.prod;
          appId = 'com.swing.onestore';
        }
        break;
      case null:
        break;
    }
  }
}
