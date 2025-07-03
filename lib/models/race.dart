import 'package:json_annotation/json_annotation.dart';

part 'race.g.dart';

@JsonSerializable()
class Race {
  final String index;
  final String name;
  final String url;

  // Optional detailed fields when available
  final String? size;
  final String? speed;
  final List<Map<String, dynamic>>? abilityBonuses;
  final List<String>? languages;
  final List<String>? traits;
  final String? description;

  Race({
    required this.index,
    required this.name,
    required this.url,
    this.size,
    this.speed,
    this.abilityBonuses,
    this.languages,
    this.traits,
    this.description,
  });

  factory Race.fromJson(Map<String, dynamic> json) => _$RaceFromJson(json);
  Map<String, dynamic> toJson() => _$RaceToJson(this);
}
