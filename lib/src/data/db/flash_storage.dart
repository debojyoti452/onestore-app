class FlashStorage {
  static final FlashStorage _obj = FlashStorage._internal();

  factory FlashStorage() => _obj;

  FlashStorage._internal();

  int lastId = 0;

  void copyWith({
    int? lastId,
  }) {
    this.lastId = lastId ?? this.lastId;
  }
}
