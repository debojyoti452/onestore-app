import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_ui/src/global/app_cubit_status.dart';

part 'add_card_state.dart';

class AddCardCubit extends Cubit<AddCardState> {
  AddCardCubit()
      : super(
          AddCardState(appCubitStatus: AppCubitInitial()),
        );
}
