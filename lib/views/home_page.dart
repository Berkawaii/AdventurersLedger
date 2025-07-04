import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_theme.dart';
import '../constants/icon_helper.dart';
import '../view_models/character_view_model.dart';
import '../widgets/dice_roller_widget.dart';
import 'character_create_page.dart';
import 'character/character_detail_page.dart';
import 'reference_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const CharacterListPage(),
    const ReferencePage(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize character view model
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CharacterViewModel>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adventurer\'s Ledger'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.accentColor, AppTheme.backgroundDark],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/icons/d20.png',
              width: 24,
              height: 24,
              color: AppTheme.textLight,
            ),
            tooltip: 'Roll Dice',
            onPressed: () async {
              // Show dice roller dialog
              await showDiceRoller(context);
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppTheme.backgroundDark,
          image: DecorationImage(
            image: AssetImage('assets/images/fantasy_background.jpg'),
            fit: BoxFit.cover,
            opacity: 0.2,
            colorFilter: ColorFilter.mode(
              AppTheme.backgroundDark,
              BlendMode.overlay,
            ),
          ),
        ),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/sword.png',
              width: 24,
              height: 24,
              color: AppTheme.textLight.withOpacity(0.6),
            ),
            activeIcon: Image.asset(
              'assets/icons/sword.png',
              width: 24,
              height: 24,
              color: AppTheme.secondaryColor,
            ),
            label: 'Characters',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/scroll.png',
              width: 24,
              height: 24,
              color: AppTheme.textLight.withOpacity(0.6),
            ),
            activeIcon: Image.asset(
              'assets/icons/scroll.png',
              width: 24,
              height: 24,
              color: AppTheme.secondaryColor,
            ),
            label: 'Reference',
          ),
        ],
      ),
      floatingActionButton:
          _currentIndex == 0
              ? FloatingActionButton(
                backgroundColor: AppTheme.primaryColor,
                child: const Icon(Icons.add, color: AppTheme.textLight),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  side: const BorderSide(
                    color: AppTheme.secondaryColor,
                    width: 1,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CharacterCreatePage(),
                    ),
                  );
                },
              )
              : null,
    );
  }
}

class CharacterListPage extends StatelessWidget {
  const CharacterListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CharacterViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.secondaryColor,
                  ),
                  strokeWidth: 3,
                ),
                SizedBox(height: 16),
                Text(
                  'Loading your adventure...',
                  style: TextStyle(
                    color: AppTheme.secondaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        if (viewModel.errorMessage != null) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.6),
                  width: 1.5,
                ),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'A challenge has appeared!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error: ${viewModel.errorMessage}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => viewModel.loadCharacters(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (viewModel.characters.isEmpty) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.secondaryColor.withOpacity(0.6),
                  width: 1.5,
                ),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 60,
                    color: AppTheme.secondaryColor,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your adventure awaits!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create your first character to begin your journey',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: AppTheme.textLight),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CharacterCreatePage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Character'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: viewModel.characters.length,
          itemBuilder: (context, index) {
            final character = viewModel.characters[index];
            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 6.0,
              ),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: BorderSide(
                  color: AppTheme.secondaryColor.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accentColor,
                      AppTheme.accentColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: IconHelper.getClassIcon(
                      character.characterClass,
                      size: IconHelper.sizeSmall,
                      color: AppTheme.textLight,
                    ),
                  ),
                  title: Text(
                    character.name,
                    style: const TextStyle(
                      color: AppTheme.secondaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  subtitle: Text(
                    '${character.race} ${character.characterClass} (Level ${character.level})',
                    style: const TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 14.0,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppTheme.secondaryColor,
                  ),
                  onTap: () {
                    viewModel.selectCharacter(character.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                CharacterDetailPage(characterId: character.id),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
