// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spell.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Spell _$SpellFromJson(Map<String, dynamic> json) => Spell(
  index: json['index'] as String,
  name: json['name'] as String,
  url: json['url'] as String,
  level: json['level'] as String?,
  school: json['school'] as String?,
  castingTime: json['castingTime'] as String?,
  range: json['range'] as String?,
  components:
      (json['components'] as List<dynamic>?)?.map((e) => e as String).toList(),
  material: json['material'] as String?,
  duration: json['duration'] as String?,
  description: json['description'] as String?,
  higherLevel: json['higherLevel'] as String?,
  classes:
      (json['classes'] as List<dynamic>?)?.map((e) => e as String).toList(),
  ritual: json['ritual'] as bool?,
  concentration: json['concentration'] as bool?,
);

Map<String, dynamic> _$SpellToJson(Spell instance) => <String, dynamic>{
  'index': instance.index,
  'name': instance.name,
  'url': instance.url,
  'level': instance.level,
  'school': instance.school,
  'castingTime': instance.castingTime,
  'range': instance.range,
  'components': instance.components,
  'material': instance.material,
  'duration': instance.duration,
  'description': instance.description,
  'higherLevel': instance.higherLevel,
  'classes': instance.classes,
  'ritual': instance.ritual,
  'concentration': instance.concentration,
};
