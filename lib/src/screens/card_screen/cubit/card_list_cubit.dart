import 'dart:convert';
import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:encrypt_db/encrypt_db.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onestore_wallet_app/src/data/db/flash_storage.dart';
import 'package:onestore_wallet_app/src/utils/global/app_cubit_status.dart';
import 'package:security_module/security_module.dart';

import '../../../data/models/cards/card_data_model.dart';

part 'card_list_state.dart';

class CardListCubit extends Cubit<CardListState> {
  CardListCubit()
      : super(CardListState(
          status: AppCubitInitial(),
        ));

  late EncryptDb _encryptDb;
  SecurityModule securityModulePlugin = SecurityModule();

  void initialize() async {
    BotToast.showLoading();
    _encryptDb = EncryptDb();
    _encryptDb.initializeEncryptDb();
    getCardList();
  }

  void getCardList() async {
    try {
      emit(state.copyWith(
        status: AppCubitLoading(),
        cardList: [],
      ));
      var cardList = jsonEncode(await _encryptDb.readAll());
      if (cardList.isEmpty || cardList.toString() == '{}') {
        FlashStorage().copyWith(
            lastId: DateTime.now().millisecondsSinceEpoch);
        emit(state.copyWith(
          status: AppCubitSuccess(),
          cardList: [],
        ));
      } else {
        var cardDataModelList = <CardDataModel>[];
        var cardListMap = jsonDecode(cardList);
        log('cardListMap: $cardListMap');
        cardListMap.forEach((key, value) {
          cardDataModelList.add(
            CardDataModel.fromEncryptedJson(
              jsonDecode(value.toString()),
            ),
          );
        });

        FlashStorage().copyWith(
          lastId: cardDataModelList.last.id,
        );

        emit(state.copyWith(
          status: AppCubitSuccess(),
          cardList: cardDataModelList,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
          status: AppCubitError(message: e.toString())));
    } finally {
      BotToast.closeAllLoading();
    }
  }

  void clearCard({required int id}) async {
    try {
      BotToast.showLoading();
      emit(state.copyWith(
        status: AppCubitLoading(),
      ));
      await _encryptDb.clear(key: id.toString());
      getCardList();
    } catch (e) {
      emit(state.copyWith(
          status: AppCubitError(message: e.toString())));
    } finally {
      BotToast.closeAllLoading();
    }
  }
}
