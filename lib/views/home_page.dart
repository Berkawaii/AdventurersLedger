import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/character_view_model.dart';
import 'character_create_page.dart';
import 'character_detail_page.dart';
import 'reference_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

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
      appBar: AppBar(title: const Text('Adventurer\'s Ledger')),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Characters',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Reference'),
        ],
      ),
      floatingActionButton:
          _currentIndex == 0
              ? FloatingActionButton(
                child: const Icon(Icons.add),
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
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Error: ${viewModel.errorMessage}',
                  style: const TextStyle(color: Colors.red),
                ),
                ElevatedButton(
                  onPressed: () => viewModel.loadCharacters(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (viewModel.characters.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('No characters yet'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CharacterCreatePage(),
                      ),
                    );
                  },
                  child: const Text('Create Character'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: viewModel.characters.length,
          itemBuilder: (context, index) {
            final character = viewModel.characters[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: CircleAvatar(child: Text(character.name[0])),
                title: Text(character.name),
                subtitle: Text(
                  '${character.race} ${character.characterClass} (Level ${character.level})',
                ),
                trailing: const Icon(Icons.chevron_right),
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
            );
          },
        );
      },
    );
  }
}
