import 'package:diamon_rose_app/my_ar_entity/ar_dto_entity.dart';
import 'package:diamon_rose_app/my_ar_entity/collection_dto_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_ar_entity.freezed.dart';
part 'my_ar_entity.g.dart';

@freezed
class MyAREntity with _$MyAREntity {
  const factory MyAREntity({
    required ARDTOEntity myARDTO,
    required CollectionDTOEntity arCollectionDTO,
    @Default(false) bool selected,
  }) = _MyAREntity;

  factory MyAREntity.fromJson(Map<String, dynamic> json) =>
      _$MyAREntityFromJson(json);
}
