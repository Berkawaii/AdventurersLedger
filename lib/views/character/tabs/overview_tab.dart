import 'package:flutter/material.dart';
import '../../../constants/app_theme.dart';
import '../../../models/character.dart';
import '../widgets/stat_column_widget.dart';
import '../dialogs/hp_dialog.dart';

class OverviewTab extends StatelessWidget {
  final Character character;
  final Function(BuildContext, String, int) updateHP;
  final Function(BuildContext, String, int) updateInspiration;
  final String Function(DateTime) formatDate;

  const OverviewTab({
    Key? key,
    required this.character,
    required this.updateHP,
    required this.updateInspiration,
    required this.formatDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Character header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    child: Text(
                      character.name[0],
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          character.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${character.race} ${character.characterClass}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text('Level ${character.level}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // HP Management
          Card(
            color: AppTheme.accentColor,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: AppTheme.secondaryColor.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hit Points',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${character.currentHitPoints} / ${character.hitPoints}',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color:
                          character.currentHitPoints <=
                                  character.hitPoints * 0.25
                              ? Colors.red
                              : character.currentHitPoints <=
                                  character.hitPoints * 0.5
                              ? Colors.orange
                              : AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          updateHP(context, character.id, -1);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: const CircleBorder(),
                          minimumSize: const Size(40, 40),
                        ),
                        child: const Icon(Icons.remove, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          HPDialog.show(context, character);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          'Update HP',
                          style: TextStyle(color: AppTheme.backgroundDark),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          updateHP(context, character.id, 1);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: const CircleBorder(),
                          minimumSize: const Size(40, 40),
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Basic stats
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StatColumnWidget(
                    label: 'AC',
                    value: character.armorClass.toString(),
                  ),
                  StatColumnWidget(
                    label: 'Prof',
                    value: '+${(character.level / 4).ceil() + 1}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Inspiration Management
          Card(
            color: AppTheme.accentColor,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: AppTheme.secondaryColor.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Inspiration',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final isActive = index < character.inspiration;
                      return GestureDetector(
                        onTap: () {
                          updateInspiration(context, character.id, index + 1);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(
                            Icons.star,
                            size: 40,
                            color:
                                isActive
                                    ? AppTheme.secondaryColor
                                    : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to set inspiration level',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textLight.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Character details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Character Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow('Background', character.background ?? 'None'),
                  _buildDetailRow('Alignment', character.alignment ?? 'None'),
                  _buildDetailRow('Created', formatDate(character.createdAt)),
                  _buildDetailRow(
                    'Last Updated',
                    formatDate(character.updatedAt),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Character backstory section
          if (character.additionalTraits.containsKey('backstory') &&
              character.additionalTraits['backstory'] != null &&
              character.additionalTraits['backstory'].toString().isNotEmpty)
            Card(
              color: AppTheme.accentColor.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: AppTheme.secondaryColor.withOpacity(0.5),
                  width: 1,
                ),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Backstory',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1, color: AppTheme.primaryColor),
                    const SizedBox(height: 12),
                    Text(
                      character.additionalTraits['backstory'].toString(),
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textLight,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
