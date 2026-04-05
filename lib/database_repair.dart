import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseRepair {
  /// Repairs the database by dropping existing tables and recreating them with correct schema
  static Future<void> repairDatabase() async {
    try {
      if (kIsWeb) {
        print('Database repair not needed on web platform');
        return;
      }

      print('🔧 Starting database repair...');
      
      // Get the database path
      String databasesPath = await getDatabasesPath();
      String path = join(databasesPath, 'dr_saathi.db');
      
      print('📁 Database path: $path');
      
      // Close any existing database connections
      await databaseFactory.deleteDatabase(path);
      print('🗑️ Deleted old database');
      
      // The database will be recreated automatically with the correct schema
      // when the app next tries to access it
      
      print('[SUCCESS] Database repair completed successfully!');
      print('[INFO] Please restart the app to apply changes');
      
    } catch (e) {
      print('[ERROR] Error during database repair: $e');
      rethrow;
    }
  }

  /// Alternative method: Just delete the database file
  static Future<void> resetDatabase() async {
    try {
      if (kIsWeb) {
        print('Database reset not available on web platform');
        return;
      }

      print('🔄 Resetting database...');
      
      String databasesPath = await getDatabasesPath();
      String path = join(databasesPath, 'dr_saathi.db');
      
      // Check if database file exists
      File dbFile = File(path);
      if (await dbFile.exists()) {
        await dbFile.delete();
        print('🗑️ Database file deleted: $path');
      } else {
        print('ℹ️ Database file does not exist: $path');
      }
      
      print('[SUCCESS] Database reset completed!');
      
    } catch (e) {
      print('[ERROR] Error resetting database: $e');
      rethrow;
    }
  }

  /// Manual database migration for existing databases
  static Future<void> migrateDatabase() async {
    try {
      if (kIsWeb) {
        print('Manual migration not supported on web');
        return;
      }

      print('🔄 Starting manual database migration...');
      
      String databasesPath = await getDatabasesPath();
      String path = join(databasesPath, 'dr_saathi.db');
      
      // Open database
      Database db = await openDatabase(path);
      
      try {
        // Check if email column exists
        var result = await db.rawQuery("PRAGMA table_info(patients)");
        bool emailExists = result.any((column) => column['name'] == 'email');
        
        if (!emailExists) {
          print('[INFO] Adding missing email column...');
          await db.execute('ALTER TABLE patients ADD COLUMN email TEXT');
          print('[SUCCESS] Email column added successfully');
        } else {
          print('ℹ️ Email column already exists');
        }
        
        // Check if dateOfBirth column exists
        bool dateOfBirthExists = result.any((column) => column['name'] == 'dateOfBirth');
        
        if (!dateOfBirthExists) {
          print('[INFO] Adding missing dateOfBirth column...');
          await db.execute('ALTER TABLE patients ADD COLUMN dateOfBirth TEXT');
          print('[SUCCESS] DateOfBirth column added successfully');
        } else {
          print('ℹ️ DateOfBirth column already exists');
        }
        
        // Check if invoice tables exist
        var tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('invoices', 'billing_items')"
        );
        
        if (tables.length < 2) {
          print('[INFO] Creating missing invoice tables...');
          
          await db.execute('''
            CREATE TABLE IF NOT EXISTS invoices (
              id TEXT PRIMARY KEY,
              invoice_number TEXT UNIQUE NOT NULL,
              patient_id TEXT NOT NULL,
              patient_name TEXT NOT NULL,
              doctor_id TEXT NOT NULL,
              doctor_name TEXT NOT NULL,
              invoice_date TEXT NOT NULL,
              due_date TEXT NOT NULL,
              subtotal REAL NOT NULL,
              vat_rate REAL NOT NULL,
              vat_amount REAL NOT NULL,
              tax_rate REAL NOT NULL,
              tax_amount REAL NOT NULL,
              total_amount REAL NOT NULL,
              status TEXT NOT NULL,
              notes TEXT,
              created_at TEXT NOT NULL,
              paid_at TEXT,
              payment_method TEXT,
              payment_reference TEXT,
              FOREIGN KEY (patient_id) REFERENCES patients (id)
            )
          ''');
          
          await db.execute('''
            CREATE TABLE IF NOT EXISTS billing_items (
              id TEXT PRIMARY KEY,
              invoice_id TEXT NOT NULL,
              description TEXT NOT NULL,
              type TEXT NOT NULL,
              quantity REAL NOT NULL,
              unit_price REAL NOT NULL,
              total_amount REAL NOT NULL,
              category TEXT,
              created_at TEXT NOT NULL,
              FOREIGN KEY (invoice_id) REFERENCES invoices (id)
            )
          ''');
          
          print('[SUCCESS] Invoice tables created successfully');
        } else {
          print('ℹ️ Invoice tables already exist');
        }
        
      } finally {
        await db.close();
      }
      
      print('[SUCCESS] Database migration completed successfully!');
      
    } catch (e) {
      print('[ERROR] Error during manual migration: $e');
      rethrow;
    }
  }
}