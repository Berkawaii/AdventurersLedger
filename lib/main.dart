import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'firebase_options.dart';
import 'constants/app_theme.dart';
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

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Firebase Analytics için
    final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    final FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
      analytics: analytics,
    );

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
        theme: AppTheme.fantasyTheme,
        navigatorObservers: [observer], // Analytics için observer eklendi
        home: const HomePage(),
      ),
    );
  }
}
