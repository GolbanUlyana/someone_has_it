import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/database_service.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbService = DatabaseService();
  await dbService.init();
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => dbService,
      child: const SomeoneHasItApp(),
    ),
  );
}

class SomeoneHasItApp extends StatelessWidget {
  const SomeoneHasItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Хтось має це',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}