part of 'add_card_cubit.dart';

class AddCardState extends Equatable {
  const AddCardState({
    required this.appCubitStatus,
  });

  final AppCubitStatus appCubitStatus;

  @override
  List<Object?> get props => [
        appCubitStatus,
      ];

  AddCardState copyWith({
    AppCubitStatus? appCubitStatus,
  }) {
    return AddCardState(
      appCubitStatus: appCubitStatus ?? this.appCubitStatus,
    );
  }
}
