import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wallet_ui/src/utils/helper/helper.dart';
import 'package:wallet_ui/src/utils/themes/color_constants.dart';

class CreditCardWidget extends StatelessWidget {
  const CreditCardWidget({
    Key? key,
    required this.index,
  }) : super(key: key);

  final int index;

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
            'ICICI Bank',
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
                text: '4520 **** **** 1234',
              );
            },
            child: Text(
              '4520 **** **** 1234',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: ColorConstants.WHITE,
              ),
            ),
          ),
          SizedBox(height: 40.h),
          Text(
            'Debojyoti Singha',
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
                text: 'Valid Thru: 12/22',
              );
            },
            child: Text(
              'Valid Thru: 12/22',
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
