// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monster.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Monster _$MonsterFromJson(Map<String, dynamic> json) => Monster(
      index: json['index'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      size: json['size'] as String?,
      type: json['type'] as String?,
      alignment: json['alignment'] as String?,
      armorClass: (json['armorClass'] as num?)?.toInt(),
      hitPoints: (json['hitPoints'] as num?)?.toInt(),
      hitDice: json['hitDice'] as String?,
      speed: (json['speed'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      abilityScores: (json['abilityScores'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      challengeRating: json['challengeRating'] as String?,
      xp: (json['xp'] as num?)?.toInt(),
      actions: (json['actions'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$MonsterToJson(Monster instance) => <String, dynamic>{
      'index': instance.index,
      'name': instance.name,
      'url': instance.url,
      'size': instance.size,
      'type': instance.type,
      'alignment': instance.alignment,
      'armorClass': instance.armorClass,
      'hitPoints': instance.hitPoints,
      'hitDice': instance.hitDice,
      'speed': instance.speed,
      'abilityScores': instance.abilityScores,
      'challengeRating': instance.challengeRating,
      'xp': instance.xp,
      'actions': instance.actions,
      'description': instance.description,
    };
