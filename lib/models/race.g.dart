// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'race.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Race _$RaceFromJson(Map<String, dynamic> json) => Race(
      index: json['index'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      size: json['size'] as String?,
      speed: json['speed'] as String?,
      abilityBonuses: (json['abilityBonuses'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      languages: (json['languages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      traits:
          (json['traits'] as List<dynamic>?)?.map((e) => e as String).toList(),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$RaceToJson(Race instance) => <String, dynamic>{
      'index': instance.index,
      'name': instance.name,
      'url': instance.url,
      'size': instance.size,
      'speed': instance.speed,
      'abilityBonuses': instance.abilityBonuses,
      'languages': instance.languages,
      'traits': instance.traits,
      'description': instance.description,
    };
