part of 'card_list_cubit.dart';

class CardListState extends Equatable {
  const CardListState({
    required this.status,
    this.cardList = const [],
  });

  final AppCubitStatus status;
  final List<CardDataModel> cardList;

  @override
  List<Object?> get props => [
        status,
        cardList,
      ];

  CardListState copyWith({
    AppCubitStatus? status,
    List<CardDataModel>? cardList,
  }) {
    return CardListState(
      status: status ?? this.status,
      cardList: cardList ?? this.cardList,
    );
  }
}
