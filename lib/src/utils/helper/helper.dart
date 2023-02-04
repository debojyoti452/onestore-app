import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../themes/color_constants.dart';

mixin Helper {
  static getRandomColor(int index) {
    var colorArray = [
      ColorConstants.CARD_1,
      ColorConstants.CARD_2,
      ColorConstants.CARD_3,
      ColorConstants.CARD_4,
    ];

    return colorArray[index % colorArray.length];
  }

  /// Tap to copy
  static void copyToClipboard({
    required BuildContext context,
    required String text,
  }) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.vibrate();
    BotToast.showText(text: 'Copied to clipboard');
  }
}
