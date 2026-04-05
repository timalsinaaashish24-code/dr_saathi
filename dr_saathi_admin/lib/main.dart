import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';
import 'screens/admin_home.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize web database factory if running on web
  if (kIsWeb) {
    try {
      databaseFactory = databaseFactoryFfiWeb;
    } catch (e) {
      print('Warning: Web database initialization failed: $e');
    }
  }
  
  // Initialize database
  try {
    final databaseService = DatabaseService();
    await databaseService.database;
    print('Database initialized successfully');
  } catch (e) {
    print('Warning: Database initialization failed: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dr. Saathi Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const AdminHome(),
    );
  }
}
