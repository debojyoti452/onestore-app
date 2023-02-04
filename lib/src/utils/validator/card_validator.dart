import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wallet_ui/src/utils/themes/color_constants.dart';

enum CardEnum {
  DEBIT_CARD,
  CREDIT_CARD,
}

enum CardType {
  visa,
  mastercard,
  amex,
  discover,
  maestro,
  rupay,
  unknown,
}

class CardValidator {
  static CardType getCardType(String cardNumber) {
    if (cardNumber.isEmpty) {
      return CardType.unknown;
    }
    log('cardNumber: $cardNumber');

    if (cardNumber.startsWith(RegExp(
        r'((5[1-5])|(222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720))'))) {
      return CardType.mastercard;
    } else if (cardNumber.startsWith(RegExp(r'[4]'))) {
      return CardType.visa;
    } else if (cardNumber
        .startsWith(RegExp(r'((34)|(37))'))) {
      return CardType.amex;
    } else if (cardNumber
        .startsWith(RegExp(r'((6[45])|(6011))'))) {
      return CardType.discover;
    } else if (cardNumber.startsWith(RegExp(
        r'^(5018|5020|5038|5893|6304|6759|6761|6762|6763)[0-9]{8,15}$'))) {
      return CardType.maestro;
    } else if (cardNumber
        .startsWith(RegExp(r'^60[0-9]{14}$'))) {
      return CardType.rupay;
    } else {
      return CardType.unknown;
    }
  }

  /// Validate Card Number using Luhn Algorithm
  static String? validateCardNumWithLuhnAlgorithm(
      String? cardNumber) {
    if (cardNumber == null || cardNumber.isEmpty) {
      return 'Card Number is required';
    }

    if (cardNumber.isEmpty) {
      return 'Card Number is required';
    }

    if (cardNumber.length < 16) {
      return 'Card Number must be 16 digits';
    }

    if (!_luhnCheck(cardNumber)) {
      return 'Invalid Card Number';
    }

    return null;
  }

  /// Card Number using Luhn Algorithm
  static _luhnCheck(String cardNumber) {
    int sum = 0;
    bool alternate = false;
    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int n = int.parse(cardNumber[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) {
          n = (n % 10) + 1;
        }
      }
      sum += n;
      alternate = !alternate;
    }
    return (sum % 10 == 0);
  }

  /// Fetch Card Icon from Card Type
  static Widget getCardIcon(CardType cardType) {
    switch (cardType) {
      case CardType.visa:
        return Image.asset(
          'assets/card/visa.png',
          width: 30,
          height: 30,
          color: ColorConstants.BLACK,
        );
      case CardType.mastercard:
        return Image.asset(
          'assets/card/mastercard.png',
          width: 30,
          height: 30,
          color: ColorConstants.BLACK,
        );
      case CardType.amex:
        return Image.asset(
          'assets/card/amex.png',
          width: 30,
          height: 30,
          color: ColorConstants.BLACK,
        );
      case CardType.discover:
        return Image.asset(
          'assets/card/discover.png',
          width: 30,
          height: 30,
          color: ColorConstants.BLACK,
        );
      case CardType.maestro:
        return Image.asset(
          'assets/card/maestro.png',
          width: 30,
          height: 30,
          color: ColorConstants.BLACK,
        );
      case CardType.rupay:
        return Image.asset(
          'assets/card/rupay.png',
          width: 30,
          height: 30,
          color: ColorConstants.BLACK,
        );
      default:
        return const Icon(
          Icons.credit_card,
          size: 30,
          color: ColorConstants.BLACK,
        );
    }
  }
}
