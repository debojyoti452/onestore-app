import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onestore_wallet_app/src/utils/global/app_cubit_status.dart';
import 'package:onestore_wallet_app/src/utils/services/android_method_channel.dart';

part 'about_us_state.dart';

class AboutUsCubit extends Cubit<AboutUsState> {
  AboutUsCubit()
      : super(AboutUsState(
          status: AppCubitInitial(),
        ));
  final AndroidMethodChannel _androidMethodChannel =
      AndroidMethodChannel();

  void getAppVersion() async {
    try {
      BotToast.showLoading();
      emit(AboutUsState(
        status: AppCubitLoading(),
        appVersion: '',
      ));
      var appVersion =
          await _androidMethodChannel.platformVersion();

      log('appVersion: $appVersion');

      emit(AboutUsState(
        status: AppCubitSuccess(),
        appVersion: appVersion,
      ));
    } catch (e) {
      emit(AboutUsState(
        status: AppCubitError(message: e.toString()),
      ));
    } finally {
      BotToast.closeAllLoading();
    }
  }
}
