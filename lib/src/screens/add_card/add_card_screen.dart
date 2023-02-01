import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/validator/card_number_formatter.dart';
import '../../utils/validator/card_validator.dart';
import '../../utils/validator/card_year_month_formatter.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({Key? key}) : super(key: key);

  @override
  _AddCardScreenState createState() =>
      _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  CardType cardType = CardType.unknown;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 20),
          margin: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  const Text(
                    'Add Card',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
              const SizedBox(height: 20),
              _cardNumberInput(),
              const SizedBox(height: 20),
              _cardHolderNameInput(),
              const SizedBox(height: 20),
              _cardMonthYearInput(),
              const SizedBox(height: 20),
              _addCardButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Card Month/Year Input
  Widget _cardMonthYearInput() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Month/Year',
        hintText: 'MM/YY',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
        CardMonthYearFormatter(),
      ],
    );
  }

  /// Card Number Input Text Field
  Widget _cardNumberInput() {
    return TextFormField(
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        CardNumberFormatter(),
        LengthLimitingTextInputFormatter(19),
      ],
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.number,
      validator:
          CardValidator.validateCardNumWithLuhnAlgorithm,
      onChanged: (value) {
        log('Card Number: $value');
        setState(() {
          cardType =
              CardValidator.getCardType(value.trim());
        });
        log('cardType: $cardType');
      },
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding:
              const EdgeInsets.only(left: 12, right: 12),
          child: CardValidator.getCardIcon(cardType),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        hintText: 'XXXX-XXXX-XXXX-XXXX',
        labelText: 'Card Number',
        counterText: "",
      ),
      maxLength: 19,
    );
  }

  /// Card Name Holder Input Text Field
  Widget _cardHolderNameInput() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Card Holder Name',
        labelStyle: TextStyle(
          color: Colors.black.withOpacity(0.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Add Card Button
  Widget _addCardButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff8772FE),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text('Add Card'),
      ),
    );
  }
}
