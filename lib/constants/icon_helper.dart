import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Bu sınıf, uygulamanın genelinde kullanılan ikonlar için yardımcı fonksiyonlar içerir.
class IconHelper {
  // İkon boyutları
  static const double sizeSmall = 18.0;
  static const double sizeMedium = 24.0;
  static const double sizeLarge = 32.0;
  static const double sizeXLarge = 48.0;

  /// Fantasy karakter sınıfları için ikonlar
  static Widget getClassIcon(
    String characterClass, {
    double size = sizeMedium,
    Color? color,
  }) {
    color ??= AppTheme.secondaryColor;

    switch (characterClass.toLowerCase()) {
      case 'warrior':
      case 'fighter':
      case 'barbarian':
        return Image.asset(
          'assets/icons/sword.png',
          width: size,
          height: size,
          color: color,
        );
      case 'paladin':
      case 'cleric':
        return Image.asset(
          'assets/icons/shield.png',
          width: size,
          height: size,
          color: color,
        );
      case 'wizard':
      case 'sorcerer':
      case 'warlock':
        return Image.asset(
          'assets/icons/scroll.png',
          width: size,
          height: size,
          color: color,
        );
      case 'rogue':
      case 'bard':
        return Icon(Icons.catching_pokemon, size: size, color: color);
      case 'ranger':
      case 'druid':
        return Icon(Icons.forest, size: size, color: color);
      case 'monk':
        return Icon(Icons.self_improvement, size: size, color: color);
      default:
        return Icon(Icons.person, size: size, color: color);
    }
  }

  /// Fantasy ırk/türler için ikonlar
  static Widget getRaceIcon(
    String race, {
    double size = sizeMedium,
    Color? color,
  }) {
    color ??= AppTheme.secondaryColor;

    switch (race.toLowerCase()) {
      case 'human':
        return Icon(Icons.person, size: size, color: color);
      case 'elf':
        return Icon(Icons.emoji_nature, size: size, color: color);
      case 'dwarf':
        return Icon(Icons.engineering, size: size, color: color);
      case 'halfling':
        return Icon(Icons.child_care, size: size, color: color);
      case 'orc':
        return Icon(
          Icons.sentiment_very_dissatisfied,
          size: size,
          color: color,
        );
      case 'tiefling':
        return Icon(Icons.whatshot, size: size, color: color);
      case 'dragonborn':
        return Icon(Icons.pest_control_rodent, size: size, color: color);
      default:
        return Icon(Icons.people, size: size, color: color);
    }
  }

  /// Özellik ikonları
  static Widget getAbilityIcon(
    String ability, {
    double size = sizeMedium,
    Color? color,
  }) {
    color ??= AppTheme.secondaryColor;

    switch (ability.toLowerCase()) {
      case 'strength':
        return Icon(Icons.fitness_center, size: size, color: color);
      case 'dexterity':
        return Icon(Icons.speed, size: size, color: color);
      case 'constitution':
        return Icon(Icons.favorite, size: size, color: color);
      case 'intelligence':
        return Icon(Icons.psychology, size: size, color: color);
      case 'wisdom':
        return Icon(Icons.lightbulb, size: size, color: color);
      case 'charisma':
        return Icon(Icons.record_voice_over, size: size, color: color);
      default:
        return Icon(Icons.stars, size: size, color: color);
    }
  }

  /// Eşya tipleri için ikonlar
  static Widget getItemIcon(
    String itemType, {
    double size = sizeMedium,
    Color? color,
  }) {
    color ??= AppTheme.secondaryColor;

    switch (itemType.toLowerCase()) {
      case 'weapon':
        return Image.asset(
          'assets/icons/sword.png',
          width: size,
          height: size,
          color: color,
        );
      case 'armor':
        return Image.asset(
          'assets/icons/shield.png',
          width: size,
          height: size,
          color: color,
        );
      case 'potion':
        return Image.asset(
          'assets/icons/potion.png',
          width: size,
          height: size,
          color: color,
        );
      case 'scroll':
      case 'spell':
        return Image.asset(
          'assets/icons/scroll.png',
          width: size,
          height: size,
          color: color,
        );
      default:
        return Icon(Icons.inventory_2, size: size, color: color);
    }
  }
}
