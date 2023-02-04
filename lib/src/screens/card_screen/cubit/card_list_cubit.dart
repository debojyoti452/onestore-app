import 'package:encrypt_db/encrypt_db.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:security_module/security_module.dart';
import 'package:wallet_ui/src/utils/global/app_cubit_status.dart';

import '../../../data/models/cards/card_data_model.dart';

part 'card_list_state.dart';

class CardListCubit extends Cubit<CardListState> {
  CardListCubit()
      : super(CardListState(status: AppCubitInitial()));

  late EncryptDb _encryptDb;
  SecurityModule securityModulePlugin = SecurityModule();

  void initialize() async {
    _encryptDb = EncryptDb();
  }

  void getCardList() async {
    try {
      emit(state.copyWith(status: AppCubitLoading()));
    } catch (e) {
      emit(state.copyWith(
          status: AppCubitError(message: e.toString())));
    } finally {}
  }
}
