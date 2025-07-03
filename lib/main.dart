import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'view_models/character_view_model.dart';
import 'view_models/class_view_model.dart';
import 'view_models/race_view_model.dart';
import 'view_models/spell_view_model.dart';
import 'view_models/equipment_view_model.dart';
import 'view_models/monster_view_model.dart';
import 'views/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize Firebase - uncomment when ready to use Firebase
  // await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CharacterViewModel()),
        ChangeNotifierProvider(create: (_) => ClassViewModel()),
        ChangeNotifierProvider(create: (_) => RaceViewModel()),
        ChangeNotifierProvider(create: (_) => SpellViewModel()),
        ChangeNotifierProvider(create: (_) => EquipmentViewModel()),
        ChangeNotifierProvider(create: (_) => MonsterViewModel()),
      ],
      child: MaterialApp(
        title: 'Adventurer\'s Ledger',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const HomePage(),
      ),
    );
  }
}
