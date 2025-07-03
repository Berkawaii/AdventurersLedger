// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Character _$CharacterFromJson(Map<String, dynamic> json) => Character(
  id: json['id'] as String?,
  name: json['name'] as String,
  race: json['race'] as String,
  characterClass: json['characterClass'] as String,
  level: (json['level'] as num?)?.toInt() ?? 1,
  strength: (json['strength'] as num?)?.toInt() ?? 10,
  dexterity: (json['dexterity'] as num?)?.toInt() ?? 10,
  constitution: (json['constitution'] as num?)?.toInt() ?? 10,
  intelligence: (json['intelligence'] as num?)?.toInt() ?? 10,
  wisdom: (json['wisdom'] as num?)?.toInt() ?? 10,
  charisma: (json['charisma'] as num?)?.toInt() ?? 10,
  hitPoints: (json['hitPoints'] as num?)?.toInt() ?? 0,
  armorClass: (json['armorClass'] as num?)?.toInt() ?? 10,
  background: json['background'] as String?,
  alignment: json['alignment'] as String?,
  equipment:
      (json['equipment'] as List<dynamic>?)?.map((e) => e as String).toList(),
  spells: (json['spells'] as List<dynamic>?)?.map((e) => e as String).toList(),
  skills: (json['skills'] as List<dynamic>?)?.map((e) => e as String).toList(),
  proficiencies:
      (json['proficiencies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  additionalTraits: json['additionalTraits'] as Map<String, dynamic>?,
  isComplete: json['isComplete'] as bool? ?? false,
  needsSync: json['needsSync'] as bool? ?? true,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$CharacterToJson(Character instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'race': instance.race,
  'characterClass': instance.characterClass,
  'level': instance.level,
  'strength': instance.strength,
  'dexterity': instance.dexterity,
  'constitution': instance.constitution,
  'intelligence': instance.intelligence,
  'wisdom': instance.wisdom,
  'charisma': instance.charisma,
  'hitPoints': instance.hitPoints,
  'armorClass': instance.armorClass,
  'background': instance.background,
  'alignment': instance.alignment,
  'equipment': instance.equipment,
  'spells': instance.spells,
  'skills': instance.skills,
  'proficiencies': instance.proficiencies,
  'additionalTraits': instance.additionalTraits,
  'isComplete': instance.isComplete,
  'needsSync': instance.needsSync,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
