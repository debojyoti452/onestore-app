import 'package:freezed_annotation/freezed_annotation.dart';

part 'card_data_model.freezed.dart';
part 'card_data_model.g.dart';

@freezed
class CardDataModel with _$CardDataModel {
  @JsonSerializable(
      fieldRename: FieldRename.snake, explicitToJson: true)
  const factory CardDataModel({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'card_name') String? cardName,
    @JsonKey(name: 'card_number') String? cardNumber,
    @JsonKey(name: 'card_type') String? cardType,
    @JsonKey(name: 'card_expiry') String? cardExpiry,
    @JsonKey(name: 'bank_name') String? bankName,
    @JsonKey(name: 'status') bool? status,
  }) = _CardDataModel;

  factory CardDataModel.fromJson(
          Map<String, dynamic> json) =>
      _$CardDataModelFromJson(json);
}
