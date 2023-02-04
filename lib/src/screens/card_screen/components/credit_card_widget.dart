import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onestore_wallet_app/src/data/models/cards/card_data_model.dart';
import 'package:onestore_wallet_app/src/utils/helper/helper.dart';
import 'package:onestore_wallet_app/src/utils/themes/color_constants.dart';

class CreditCardWidget extends StatelessWidget {
  const CreditCardWidget({
    Key? key,
    required this.index,
    required this.card,
  }) : super(key: key);

  final int index;
  final CardDataModel card;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().screenWidth,
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 20.h,
      ),
      margin: EdgeInsets.symmetric(
        vertical: 10.h,
        horizontal: 10.w,
      ),
      decoration: BoxDecoration(
        color: Helper.getRandomColor(index),
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 6.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${card.bankName}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: ColorConstants.WHITE,
            ),
          ),
          SizedBox(height: 40.h),
          InkWell(
            onTap: () {
              Helper.copyToClipboard(
                context: context,
                text: '${card.cardNumber}',
              );
            },
            child: Text(
              Helper.cardNumberToAsterisk(
                  (card.cardNumber ?? '').trim()),
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: ColorConstants.WHITE,
              ),
            ),
          ),
          SizedBox(height: 40.h),
          Text(
            Helper.cardHolderNameToAsterisk(
                card.cardName ?? ''),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: ColorConstants.WHITE,
            ),
          ),
          SizedBox(height: 10.h),
          InkWell(
            onTap: () {
              Helper.copyToClipboard(
                context: context,
                text: card.cardExpiry ?? '',
              );
            },
            child: Text(
              'Valid Thru: ${Helper.monthYearToAsterisk(card.cardExpiry ?? '')}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: ColorConstants.WHITE,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
