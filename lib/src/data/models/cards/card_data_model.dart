import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:security_module/security_module.dart';

part 'card_data_model.freezed.dart';
part 'card_data_model.g.dart';

@freezed
class CardDataModel with _$CardDataModel {
  @JsonSerializable(
      fieldRename: FieldRename.snake, explicitToJson: true)
  const factory CardDataModel({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'card_name', defaultValue: '')
        String? cardName,
    @JsonKey(name: 'card_number', defaultValue: '')
        String? cardNumber,
    @JsonKey(name: 'card_type', defaultValue: '')
        String? cardType,
    @JsonKey(name: 'card_expiry', defaultValue: '')
        String? cardExpiry,
    @JsonKey(name: 'bank_name', defaultValue: '')
        String? bankName,
    @JsonKey(name: 'status', defaultValue: true)
        bool? status,
  }) = _CardDataModel;

  const CardDataModel._();

  factory CardDataModel.fromJson(
          Map<String, dynamic> json) =>
      _$CardDataModelFromJson(json);

  /// toEncryptedJson
  Map<String, dynamic> toEncryptedJson() {
    return {
      'id': id,
      'card_name': Encrypter.encrypt(cardName ?? ''),
      'card_number': Encrypter.encrypt(cardNumber ?? ''),
      'card_type': Encrypter.encrypt(cardType ?? ''),
      'card_expiry': Encrypter.encrypt(cardExpiry ?? ''),
      'bank_name': Encrypter.encrypt(bankName ?? ''),
      'status': status,
    };
  }

  /// fromEncryptedJson
  factory CardDataModel.fromEncryptedJson(
      Map<String, dynamic> json) {
    return CardDataModel(
      id: json['id'] as int?,
      cardName: Encrypter.decrypt(
          json['card_name'] as String? ?? ''),
      cardNumber: Encrypter.decrypt(
          json['card_number'] as String? ?? ''),
      cardType: Encrypter.decrypt(
          json['card_type'] as String? ?? ''),
      cardExpiry: Encrypter.decrypt(
          json['card_expiry'] as String? ?? ''),
      bankName: Encrypter.decrypt(
          json['bank_name'] as String? ?? ''),
      status: json['status'] as bool? ?? true,
    );
  }
}
