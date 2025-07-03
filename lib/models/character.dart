import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'character.g.dart';

@JsonSerializable()
class Character {
  final String id;
  String name;
  String race;
  String characterClass;
  int level;

  // Basic attributes
  int strength;
  int dexterity;
  int constitution;
  int intelligence;
  int wisdom;
  int charisma;

  // Derived stats
  int hitPoints;
  int armorClass;

  // Other important character info
  String? background;
  String? alignment;

  // Equipment and inventory
  List<String> equipment;

  // Spells if spellcaster
  List<String>? spells;

  // Skills and proficiencies
  List<String> skills;
  List<String> proficiencies;

  // Other traits, feats, etc.
  Map<String, dynamic> additionalTraits;

  // Keeping track of character creation status
  bool isComplete;

  // For offline sync - track if this character needs to be synced to the cloud
  bool needsSync;

  // Timestamps for auditing
  final DateTime createdAt;
  DateTime updatedAt;

  Character({
    String? id,
    required this.name,
    required this.race,
    required this.characterClass,
    this.level = 1,
    this.strength = 10,
    this.dexterity = 10,
    this.constitution = 10,
    this.intelligence = 10,
    this.wisdom = 10,
    this.charisma = 10,
    this.hitPoints = 0,
    this.armorClass = 10,
    this.background,
    this.alignment,
    List<String>? equipment,
    this.spells,
    List<String>? skills,
    List<String>? proficiencies,
    Map<String, dynamic>? additionalTraits,
    this.isComplete = false,
    this.needsSync = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       equipment = equipment ?? [],
       skills = skills ?? [],
       proficiencies = proficiencies ?? [],
       additionalTraits = additionalTraits ?? {},
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Calculate ability modifier based on ability score
  int getAbilityModifier(int abilityScore) {
    return (abilityScore - 10) ~/ 2;
  }

  // Calculate derived stats
  void calculateDerivedStats() {
    // Simple HP calculation (can be more complex based on class/level/etc)
    hitPoints = level * (8 + getAbilityModifier(constitution));

    // Simple AC calculation (10 + DEX modifier)
    armorClass = 10 + getAbilityModifier(dexterity);
  }

  // For JSON serialization - using the generated code but with extra safety
  factory Character.fromJson(Map<String, dynamic> json) {
    try {
      // Handle dynamic types that might come from Hive
      Map<String, dynamic> safeJson = Map<String, dynamic>.from(json);

      // Handle additionalTraits specifically
      if (safeJson['additionalTraits'] != null) {
        if (safeJson['additionalTraits'] is Map) {
          final Map<String, dynamic> cleanTraits = {};
          (safeJson['additionalTraits'] as Map).forEach((key, value) {
            cleanTraits[key.toString()] = value;
          });
          safeJson['additionalTraits'] = cleanTraits;
        } else {
          // If it's not a map, use an empty map
          safeJson['additionalTraits'] = <String, dynamic>{};
        }
      } else {
        safeJson['additionalTraits'] = <String, dynamic>{};
      }

      // Handle lists
      if (safeJson['equipment'] != null && safeJson['equipment'] is List) {
        final List<String> cleanEquipment = [];
        for (var item in safeJson['equipment']) {
          cleanEquipment.add(item.toString());
        }
        safeJson['equipment'] = cleanEquipment;
      }

      if (safeJson['spells'] != null && safeJson['spells'] is List) {
        final List<String> cleanSpells = [];
        for (var item in safeJson['spells']) {
          cleanSpells.add(item.toString());
        }
        safeJson['spells'] = cleanSpells;
      }

      if (safeJson['skills'] != null && safeJson['skills'] is List) {
        final List<String> cleanSkills = [];
        for (var item in safeJson['skills']) {
          cleanSkills.add(item.toString());
        }
        safeJson['skills'] = cleanSkills;
      }

      if (safeJson['proficiencies'] != null &&
          safeJson['proficiencies'] is List) {
        final List<String> cleanProf = [];
        for (var item in safeJson['proficiencies']) {
          cleanProf.add(item.toString());
        }
        safeJson['proficiencies'] = cleanProf;
      }

      return _$CharacterFromJson(safeJson);
    } catch (e) {
      print('Error in Character.fromJson: $e');
      // Return a minimal valid character if parsing fails
      return Character(
        id: json['id']?.toString() ?? const Uuid().v4(),
        name: json['name']?.toString() ?? 'Unknown Character',
        race: json['race']?.toString() ?? 'Unknown Race',
        characterClass: json['characterClass']?.toString() ?? 'Unknown Class',
      );
    }
  }

  Map<String, dynamic> toJson() {
    try {
      return _$CharacterToJson(this);
    } catch (e) {
      print('Error in Character.toJson: $e');
      // Return a minimal valid JSON if serialization fails
      return {
        'id': id,
        'name': name,
        'race': race,
        'characterClass': characterClass,
        'level': level,
        'equipment': equipment,
        'additionalTraits': <String, dynamic>{},
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
    }
  }

  // Create a copy with updated fields
  Character copyWith({
    String? name,
    String? race,
    String? characterClass,
    int? level,
    int? strength,
    int? dexterity,
    int? constitution,
    int? intelligence,
    int? wisdom,
    int? charisma,
    int? hitPoints,
    int? armorClass,
    String? background,
    String? alignment,
    List<String>? equipment,
    List<String>? spells,
    List<String>? skills,
    List<String>? proficiencies,
    Map<String, dynamic>? additionalTraits,
    bool? isComplete,
    bool? needsSync,
  }) {
    return Character(
      id: id,
      name: name ?? this.name,
      race: race ?? this.race,
      characterClass: characterClass ?? this.characterClass,
      level: level ?? this.level,
      strength: strength ?? this.strength,
      dexterity: dexterity ?? this.dexterity,
      constitution: constitution ?? this.constitution,
      intelligence: intelligence ?? this.intelligence,
      wisdom: wisdom ?? this.wisdom,
      charisma: charisma ?? this.charisma,
      hitPoints: hitPoints ?? this.hitPoints,
      armorClass: armorClass ?? this.armorClass,
      background: background ?? this.background,
      alignment: alignment ?? this.alignment,
      equipment: equipment ?? this.equipment,
      spells: spells ?? this.spells,
      skills: skills ?? this.skills,
      proficiencies: proficiencies ?? this.proficiencies,
      additionalTraits: additionalTraits ?? this.additionalTraits,
      isComplete: isComplete ?? this.isComplete,
      needsSync: needsSync ?? this.needsSync,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
