import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wallet_ui/src/screens/card_screen/cubit/card_list_cubit.dart';
import 'package:wallet_ui/src/utils/constants/app_constants.dart';
import 'package:wallet_ui/src/utils/routes/app_routes.dart';

import 'src/screens/add_card/cubit/add_card_cubit.dart';
import 'src/screens/card_screen/card_list_screen.dart';

Future<void> mainCommon() async {
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(create: (context) => AddCardCubit()),
      BlocProvider(create: (context) => CardListCubit()),
    ],
    child: BaseApp(),
  ));
}

class BaseApp extends StatelessWidget {
  BaseApp({super.key});

  final botToastBuilder = BotToastInit();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: AppConstants.appName,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            textTheme: GoogleFonts.montserratTextTheme(),
          ),
          onGenerateRoute: AppRoutes.onGenerateRoute,
          builder: (context, children) {
            children = botToastBuilder(context, children);
            return children;
          },
          navigatorObservers: [BotToastNavigatorObserver()],
          home: child,
        );
      },
      child: const CardListScreen(),
    );
  }
}
