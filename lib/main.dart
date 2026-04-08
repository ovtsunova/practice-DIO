import 'package:flutter/material.dart';
import 'core/di/service_locator.dart';
import 'features/dogs/presentation/dogs_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const DogExplorerApp());
}

class DogExplorerApp extends StatelessWidget {
  const DogExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dog Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      ),
      home: const DogsPage(),
    );
  }
}