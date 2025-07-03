import 'package:json_annotation/json_annotation.dart';

part 'dnd_class.g.dart';

@JsonSerializable()
class DndClass {
  final String index;
  final String name;
  final String url;

  // Optional detailed fields when available
  final int? hitDie;
  final List<String>? proficiencies;
  final List<String>? savingThrows;
  final Map<String, dynamic>? startingEquipment;
  final String? description;

  DndClass({
    required this.index,
    required this.name,
    required this.url,
    this.hitDie,
    this.proficiencies,
    this.savingThrows,
    this.startingEquipment,
    this.description,
  });

  factory DndClass.fromJson(Map<String, dynamic> json) =>
      _$DndClassFromJson(json);
  Map<String, dynamic> toJson() => _$DndClassToJson(this);
}
