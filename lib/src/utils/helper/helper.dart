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

  /// Mask First 4 digits and last 4 digits of the card number are visible
  static String cardNumberToAsterisk(String cardNumber) {
    var firstFourDigits = cardNumber.substring(0, 4);
    var lastFourDigits =
        cardNumber.substring(cardNumber.length - 4);
    var asterisk =
        cardNumber.substring(4, cardNumber.length - 4);
    var asteriskLength = asterisk.length;
    var asteriskString = '';
    for (var i = 0; i < asteriskLength; i++) {
      asteriskString += '*';
    }
    return '$firstFourDigits$asteriskString$lastFourDigits';
  }

  /// Mask the month and year
  static String monthYearToAsterisk(String monthYear) {
    var year = monthYear.substring(2);
    var asterisk = '**';
    return '$asterisk$year';
  }

  /// Mask the card holder name before surname
  static String cardHolderNameToAsterisk(
    String cardHolderName,
  ) {
    if (!cardHolderName.contains(' ')) {
      return cardHolderName;
    }
    var name = cardHolderName.split(' ');
    var asterisk = '';
    for (var i = 0; i < name[0].length; i++) {
      asterisk += '*';
    }
    return '$asterisk ${name[1]}';
  }
}
