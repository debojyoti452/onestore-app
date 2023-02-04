import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onestore_wallet_app/src/screens/add_card/cubit/add_card_cubit.dart';
import 'package:onestore_wallet_app/src/screens/card_screen/cubit/card_list_cubit.dart';
import 'package:onestore_wallet_app/src/utils/global/secure_state_wrapper.dart';
import 'package:onestore_wallet_app/src/utils/themes/color_constants.dart';

import '../../utils/global/app_cubit_status.dart';
import '../../utils/validator/card_number_formatter.dart';
import '../../utils/validator/card_validator.dart';
import '../../utils/validator/card_year_month_formatter.dart';
import '../widgets/misc_extension_widget.dart';

class AddCardScreen extends StatefulWidget {
  static const id = 'ADD_CARD_SCREEN';

  const AddCardScreen({Key? key}) : super(key: key);

  @override
  _AddCardScreenState createState() =>
      _AddCardScreenState();
}

class _AddCardScreenState
    extends SecureStateWrapper<AddCardScreen> {
  CardType cardType = CardType.unknown;
  late AddCardCubit _addCardCubit;

  @override
  void onInit() {
    _addCardCubit = context.read<AddCardCubit>();
    _addCardCubit.initialize();
  }

  @override
  Widget onBuild(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstants.WHITE,
        elevation: 0,
        title: Text(
          'Add Card',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: ColorConstants.BLACK,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20.w,
            color: ColorConstants.BLACK,
          ),
        ),
      ),
      backgroundColor: ColorConstants.WHITE,
      body: BlocConsumer<AddCardCubit, AddCardState>(
        bloc: _addCardCubit,
        listener: (context, state) {
          if (state.appCubitStatus is AppCubitSuccess &&
              (state.appCubitStatus as AppCubitSuccess)
                      .message ==
                  'card_added') {
            Navigator.pop(context, () {
              context.read<CardListCubit>().getCardList();
            });
          }

          if (state.appCubitStatus is AppCubitError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  (state.appCubitStatus as AppCubitError)
                      .message,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20),
              margin: const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  _cardNumberInput(onChanged: (value) {
                    _addCardCubit.updateInformation(
                      state.cardDataModel.copyWith(
                        cardNumber: value,
                      ),
                    );
                    // setState(() {
                    //   cardType =
                    //       CardValidator.getCardType(value);
                    // });
                  }),
                  separatorWidget(),
                  _cardHolderNameInput(onChanged: (value) {
                    _addCardCubit.updateInformation(
                      state.cardDataModel.copyWith(
                        cardName: value,
                      ),
                    );
                  }),
                  separatorWidget(),
                  _cardMonthYearInput(onChanged: (value) {
                    _addCardCubit.updateInformation(
                      state.cardDataModel.copyWith(
                        cardExpiry: value,
                      ),
                    );
                  }),
                  separatorWidget(),
                  _bankNameInput(onChanged: (value) {
                    _addCardCubit.updateInformation(
                      state.cardDataModel.copyWith(
                        bankName: value,
                      ),
                    );
                  }),
                  separatorWidget(height: 30.h),
                  _addCardButton(onPressed: () {
                    _addCardCubit.addCard();
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Card Month/Year Input
  Widget _cardMonthYearInput({
    required Function(String) onChanged,
  }) {
    return TextFormField(
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'Month/Year',
        hintText: 'MM/YY',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.r),
          ),
        ),
        filled: true,
        fillColor: ColorConstants.GREY,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(
            color: ColorConstants.BLACK,
          ),
        ),
        labelStyle: const TextStyle(
          color: ColorConstants.BLACK,
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
  Widget _cardNumberInput({
    required Function(String) onChanged,
  }) {
    return TextFormField(
      onChanged: onChanged,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        CardNumberFormatter(),
        LengthLimitingTextInputFormatter(19),
      ],
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.number,
      validator:
          CardValidator.validateCardNumWithLuhnAlgorithm,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 12.w, right: 12.w),
          child: CardValidator.getCardIcon(cardType),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.r),
          ),
        ),
        hintText: 'XXXX-XXXX-XXXX-XXXX',
        labelText: 'Card Number',
        counterText: '',
        filled: true,
        fillColor: ColorConstants.GREY,
        labelStyle: const TextStyle(
          color: ColorConstants.BLACK,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(
            color: ColorConstants.BLACK,
          ),
        ),
      ),
      maxLength: 19,
    );
  }

  /// Card Name Holder Input Text Field
  Widget _cardHolderNameInput({
    required Function(String) onChanged,
  }) {
    return TextFormField(
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'Card Holder Name',
        labelStyle: const TextStyle(
          color: ColorConstants.BLACK,
        ),
        filled: true,
        fillColor: ColorConstants.GREY,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(
            color: ColorConstants.BLACK,
          ),
        ),
      ),
    );
  }

  /// Bank Name Input Text Field
  Widget _bankNameInput({
    required Function(String) onChanged,
  }) {
    return TextFormField(
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'Bank Name',
        labelStyle: const TextStyle(
          color: ColorConstants.BLACK,
        ),
        filled: true,
        fillColor: ColorConstants.GREY,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(
            color: ColorConstants.BLACK,
          ),
        ),
      ),
    );
  }

  /// Add Card Button
  Widget _addCardButton({
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorConstants.BLACK,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'Add Card',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }

  @override
  void onDestroy() {}

  @override
  void onDispose() {}

  @override
  void onPause() {}

  @override
  void onResume() {}

  @override
  void onStop() {}
}
