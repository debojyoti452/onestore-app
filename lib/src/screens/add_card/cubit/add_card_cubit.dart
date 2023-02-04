import 'dart:convert';
import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:encrypt_db/encrypt_db.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_ui/src/data/models/cards/card_data_model.dart';
import 'package:wallet_ui/src/utils/global/app_cubit_status.dart';
import 'package:wallet_ui/src/utils/validator/card_validator.dart';

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
      var updatedCardDataModel =
          state.cardDataModel.copyWith(
        id: DateTime.now().millisecondsSinceEpoch,
        status: true,
        cardType: CardEnum.DEBIT_CARD.name,
      );
      emit(state.copyWith(
          cardDataModel: updatedCardDataModel));

      _encryptDb.write(
        key: '${state.cardDataModel.id ?? 0}',
        value: jsonEncode(
            state.cardDataModel.toEncryptedJson()),
      );

      log('addCard: ${state.cardDataModel.toEncryptedJson()}');

      emit(state.copyWith(
          appCubitStatus:
              AppCubitSuccess(message: 'card_added')));
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
