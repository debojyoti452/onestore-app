import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_ui/src/screens/add_card/cubit/add_card_cubit.dart';
import 'package:wallet_ui/src/screens/my_wallet_screen.dart';

Future<void> mainCommon() async {
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(create: (context) => AddCardCubit()),
    ],
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyWalletScreen(),
    );
  }
}
