import 'package:freezed_annotation/freezed_annotation.dart';

part 'purchase_history.freezed.dart';
part 'purchase_history.g.dart';

@freezed
class PurchaseHistory with _$PurchaseHistory {
  const factory PurchaseHistory({
    @Default(0) int id,
    @Default(0) int userId,
    @Default(0) int videoId,
    @Default(0) int fontId,
    @Default(0) int soundId,
    @Default(0) int paymentMethodId,
    double? moneyAmount,
    bool? deleteFlag,
    int? createBy,
    String? createdAt,
    int? updateBy,
    String? updatedAt,
  }) = _PurchaseHistory;

  factory PurchaseHistory.fromJson(Map<String, dynamic> json) =>
      _$PurchaseHistoryFromJson(json);
}
