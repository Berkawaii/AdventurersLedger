import 'package:json_annotation/json_annotation.dart';

part 'monster.g.dart';

@JsonSerializable()
class Monster {
  final String index;
  final String name;
  final String url;

  // Monster details
  final String? size;
  final String? type;
  final String? alignment;
  final int? armorClass;
  final int? hitPoints;
  final String? hitDice;
  final Map<String, int>? speed;
  final Map<String, int>? abilityScores;
  final String? challengeRating;
  final int? xp;
  final List<Map<String, dynamic>>? actions;
  final String? description;

  Monster({
    required this.index,
    required this.name,
    required this.url,
    this.size,
    this.type,
    this.alignment,
    this.armorClass,
    this.hitPoints,
    this.hitDice,
    this.speed,
    this.abilityScores,
    this.challengeRating,
    this.xp,
    this.actions,
    this.description,
  });

  factory Monster.fromJson(Map<String, dynamic> json) =>
      _$MonsterFromJson(json);
  Map<String, dynamic> toJson() => _$MonsterToJson(this);
}
