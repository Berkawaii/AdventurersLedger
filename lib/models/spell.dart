import 'package:json_annotation/json_annotation.dart';

part 'spell.g.dart';

@JsonSerializable()
class Spell {
  final String index;
  final String name;
  final String url;

  // Spell details
  final String? level;
  final String? school;
  final String? castingTime;
  final String? range;
  final List<String>? components;
  final String? material;
  final String? duration;
  final String? description;
  final String? higherLevel; // Changed from List<String>? to String?
  final List<String>? classes;
  final bool? ritual;
  final bool? concentration;

  Spell({
    required this.index,
    required this.name,
    required this.url,
    this.level,
    this.school,
    this.castingTime,
    this.range,
    this.components,
    this.material,
    this.duration,
    this.description,
    this.higherLevel,
    this.classes,
    this.ritual,
    this.concentration,
  });

  factory Spell.fromJson(Map<String, dynamic> json) => _$SpellFromJson(json);
  Map<String, dynamic> toJson() => _$SpellToJson(this);
}
