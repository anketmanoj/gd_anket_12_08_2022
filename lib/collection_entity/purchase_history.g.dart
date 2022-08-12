// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_PurchaseHistory _$_$_PurchaseHistoryFromJson(Map<String, dynamic> json) {
  return _$_PurchaseHistory(
    id: json['id'] as int? ?? 0,
    userId: json['userId'] as int? ?? 0,
    videoId: json['videoId'] as int? ?? 0,
    fontId: json['fontId'] as int? ?? 0,
    soundId: json['soundId'] as int? ?? 0,
    paymentMethodId: json['paymentMethodId'] as int? ?? 0,
    moneyAmount: (json['moneyAmount'] as num?)?.toDouble(),
    deleteFlag: json['deleteFlag'] as bool?,
    createBy: json['createBy'] as int?,
    createdAt: json['createdAt'] as String?,
    updateBy: json['updateBy'] as int?,
    updatedAt: json['updatedAt'] as String?,
  );
}

Map<String, dynamic> _$_$_PurchaseHistoryToJson(_$_PurchaseHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'videoId': instance.videoId,
      'fontId': instance.fontId,
      'soundId': instance.soundId,
      'paymentMethodId': instance.paymentMethodId,
      'moneyAmount': instance.moneyAmount,
      'deleteFlag': instance.deleteFlag,
      'createBy': instance.createBy,
      'createdAt': instance.createdAt,
      'updateBy': instance.updateBy,
      'updatedAt': instance.updatedAt,
    };
