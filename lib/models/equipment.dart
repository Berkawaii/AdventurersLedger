class Equipment {
  final String index;
  final String name;
  final String url;

  // Optional detailed fields
  final String? category;
  final String? cost;
  final String? costUnit;
  final String? weight;
  final String? description;
  final List<String>? properties;

  Equipment({
    required this.index,
    required this.name,
    required this.url,
    this.category,
    this.cost,
    this.costUnit,
    this.weight,
    this.description,
    this.properties,
  });

  // Manual JSON serialization without code generation
  factory Equipment.fromJson(Map<String, dynamic> json) {
    // Handle potential properties array
    List<String>? properties;
    if (json['properties'] != null) {
      if (json['properties'] is List) {
        // API might return list of maps with 'name' field or just strings
        properties =
            (json['properties'] as List).map((item) {
              if (item is Map) {
                return (item['name'] ?? '').toString();
              }
              return item.toString();
            }).toList();
      }
    }

    // Handle description which might be a string, a list of strings, or under 'desc' field
    String? description;
    if (json['desc'] != null) {
      if (json['desc'] is List) {
        description = (json['desc'] as List).join('\n');
      } else {
        description = json['desc'].toString();
      }
    } else if (json['description'] != null) {
      if (json['description'] is List) {
        description = (json['description'] as List).join('\n');
      } else {
        description = json['description'].toString();
      }
    }

    // Handle cost which might be a map with quantity/unit or direct values
    String? cost;
    String? costUnit;

    if (json['cost'] != null) {
      if (json['cost'] is Map) {
        cost = json['cost']['quantity']?.toString();
        costUnit = json['cost']['unit']?.toString();
      } else {
        cost = json['cost'].toString();
        costUnit = json['cost_unit']?.toString() ?? '';
      }
    }

    // Handle category which might be a string or a map with 'name' field
    String? category;
    if (json['equipment_category'] != null) {
      category =
          json['equipment_category'] is Map
              ? json['equipment_category']['name']?.toString()
              : json['equipment_category'].toString();
    } else if (json['category'] != null) {
      category =
          json['category'] is Map
              ? json['category']['name']?.toString()
              : json['category'].toString();
    }

    // For weapon details and armor details
    if (description == null || description.isEmpty) {
      List<String> detailsParts = [];

      // Add weapon properties if available
      if (json['weapon_range'] != null) {
        detailsParts.add('Range: ${json['weapon_range']}');
      }

      if (json['damage'] != null && json['damage']['damage_dice'] != null) {
        final String damageType =
            json['damage']['damage_type']?['name'] ?? 'damage';
        detailsParts.add(
          'Damage: ${json['damage']['damage_dice']} $damageType',
        );
      }

      // Add armor properties if available
      if (json['armor_category'] != null) {
        detailsParts.add('Armor type: ${json['armor_category']}');
      }

      if (json['armor_class'] != null && json['armor_class']['base'] != null) {
        detailsParts.add('AC: ${json['armor_class']['base']}');

        if (json['armor_class']['dex_bonus'] == true) {
          detailsParts.add('+ Dex modifier');

          if (json['armor_class']['max_bonus'] != null) {
            detailsParts.add('(max ${json['armor_class']['max_bonus']})');
          }
        }
      }

      if (json['str_minimum'] != null && json['str_minimum'] > 0) {
        detailsParts.add('Minimum strength: ${json['str_minimum']}');
      }

      if (json['stealth_disadvantage'] == true) {
        detailsParts.add('Disadvantage on stealth checks');
      }

      // Add any gear properties
      if (json['gear_category'] != null) {
        final gearCategory =
            json['gear_category'] is Map
                ? json['gear_category']['name']
                : json['gear_category'];
        detailsParts.add('Type: $gearCategory');
      }

      if (json['contents'] != null && json['contents'] is List) {
        final List<String> contents = [];
        for (var item in json['contents']) {
          final itemName = item['item']?['name'] ?? 'Unknown item';
          final quantity = item['quantity'] ?? 1;
          contents.add('$quantity x $itemName');
        }

        if (contents.isNotEmpty) {
          detailsParts.add('Contents:\n${contents.join('\n')}');
        }
      }

      if (detailsParts.isNotEmpty) {
        description = detailsParts.join('\n');
      }
    }

    return Equipment(
      index: json['index'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Equipment',
      url: json['url'] as String? ?? '',
      category: category,
      cost: cost,
      costUnit: costUnit,
      weight: json['weight']?.toString(),
      description: description ?? 'No description available',
      properties: properties,
    );
  }

  Map<String, dynamic> toJson() => {
    'index': index,
    'name': name,
    'url': url,
    'category': category,
    'cost': cost,
    'cost_unit': costUnit,
    'weight': weight,
    'description': description,
    'properties': properties,
  };
}
