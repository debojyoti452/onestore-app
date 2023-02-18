import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onestore_wallet_app/src/data/constants/assets_constants.dart';
import 'package:onestore_wallet_app/src/screens/about/cubit/about_us_cubit.dart';

import '../../utils/themes/color_constants.dart';

class AboutUsScreen extends StatefulWidget {
  static const id = 'ABOUT_US_SCREEN';

  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  _AboutUsScreenState createState() =>
      _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  late AboutUsCubit _aboutUsCubit;

  @override
  void initState() {
    _aboutUsCubit = context.read<AboutUsCubit>();
    _aboutUsCubit.getAppVersion();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.WHITE,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'About Us',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
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
            color: Colors.black,
          ),
        ),
      ),
      body: BlocConsumer<AboutUsCubit, AboutUsState>(
        bloc: _aboutUsCubit,
        listener: (context, state) {},
        builder: (context, state) {
          return Container(
            width: ScreenUtil().screenWidth,
            padding: EdgeInsets.symmetric(
              vertical: 10.h,
              horizontal: 20.w,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  AssetsConstants.logo,
                  width: 100.w,
                  height: 100.h,
                ),
                SizedBox(height: 10.h),
                Text(
                  'OneStore App',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Version ${state.appVersion}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  _contentDesc,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.normal,
                          color: Colors.blueAccent,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {},
                      ),
                      TextSpan(
                        text: ' | ',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.normal,
                          color: Colors.blueAccent,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {},
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '© 2023',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: ' Swing Technologies. ',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {},
                      ),
                      TextSpan(
                        text: 'All rights reserved.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
              ],
            ),
          );
        },
      ),
    );
  }

  final String _contentDesc =
      '''This is a card store for the OneStore App. It is a simple app that allows you to create a store for your cards. You can keep your card safe and secure in the app. You can also share your card with your friends and family. Card information is encrypted and stored in the app. No one can access your card information except you. Bio-metric authentication is used to protect your card information. You can also use a passcode to protect your card information.\n\n''';
}
