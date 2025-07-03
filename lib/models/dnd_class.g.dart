// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dnd_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DndClass _$DndClassFromJson(Map<String, dynamic> json) => DndClass(
  index: json['index'] as String,
  name: json['name'] as String,
  url: json['url'] as String,
  hitDie: (json['hitDie'] as num?)?.toInt(),
  proficiencies:
      (json['proficiencies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  savingThrows:
      (json['savingThrows'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  startingEquipment: json['startingEquipment'] as Map<String, dynamic>?,
  description: json['description'] as String?,
);

Map<String, dynamic> _$DndClassToJson(DndClass instance) => <String, dynamic>{
  'index': instance.index,
  'name': instance.name,
  'url': instance.url,
  'hitDie': instance.hitDie,
  'proficiencies': instance.proficiencies,
  'savingThrows': instance.savingThrows,
  'startingEquipment': instance.startingEquipment,
  'description': instance.description,
};
