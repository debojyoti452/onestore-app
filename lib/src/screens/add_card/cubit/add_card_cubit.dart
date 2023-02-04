import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:encrypt_db/encrypt_db.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_ui/src/data/models/cards/card_data_model.dart';
import 'package:wallet_ui/src/utils/global/app_cubit_status.dart';

part 'add_card_state.dart';

class AddCardCubit extends Cubit<AddCardState> {
  AddCardCubit()
      : super(AddCardState(
            appCubitStatus: AppCubitInitial()));

  final EncryptDb _encryptDb = EncryptDb();

  void initialize() async {
    try {
      BotToast.showLoading();
      emit(state.copyWith(
          appCubitStatus: AppCubitLoading()));
      _encryptDb.initializeEncryptDb();

      emit(state.copyWith(
          appCubitStatus: AppCubitSuccess()));
    } catch (e) {
      emit(state.copyWith(
          appCubitStatus: AppCubitError(message: '$e')));
    } finally {
      BotToast.closeAllLoading();
    }
  }

  void addCard() async {
    try {
      BotToast.showLoading();
      emit(state.copyWith(
          appCubitStatus: AppCubitLoading()));
      log('addCard: ${state.cardDataModel.toJson()}');
      _encryptDb.writeData(key: '', value: '');
      emit(state.copyWith(
          appCubitStatus: AppCubitSuccess()));
    } catch (e) {
      emit(state.copyWith(
          appCubitStatus: AppCubitError(message: '$e')));
    } finally {
      BotToast.closeAllLoading();
    }
  }

  void updateInformation(CardDataModel dataModel) {
    emit(state.copyWith(cardDataModel: dataModel));
  }
}
