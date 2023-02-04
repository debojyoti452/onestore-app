part of 'add_card_cubit.dart';

class AddCardState extends Equatable {
  const AddCardState({
    required this.appCubitStatus,
    this.cardDataModel = const CardDataModel(),
  });

  final AppCubitStatus appCubitStatus;
  final CardDataModel cardDataModel;

  @override
  List<Object?> get props => [
        appCubitStatus,
        cardDataModel,
      ];

  AddCardState copyWith({
    AppCubitStatus? appCubitStatus,
    CardDataModel? cardDataModel,
  }) {
    return AddCardState(
      appCubitStatus: appCubitStatus ?? this.appCubitStatus,
      cardDataModel: cardDataModel ?? this.cardDataModel,
    );
  }
}
