import 'package:flutter/material.dart';
import 'services/patient_auth_service.dart';

class DebugPatientRegistration extends StatefulWidget {
  const DebugPatientRegistration({super.key});

  @override
  State<DebugPatientRegistration> createState() => _DebugPatientRegistrationState();
}

class _DebugPatientRegistrationState extends State<DebugPatientRegistration> {
  final PatientAuthService _authService = PatientAuthService();
  final List<String> _debugLogs = [];
  bool _isLoading = false;

  void _addLog(String message) {
    setState(() {
      _debugLogs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
    print(message);
  }

  Future<void> _testDatabaseConnection() async {
    setState(() {
      _isLoading = true;
      _debugLogs.clear();
    });

    try {
      _addLog('Testing database connection...');
      
      // Test database initialization
      final db = await _authService.database;
      _addLog('[SUCCESS] Database connection successful');
      
      // Test table creation/access
      final result = await db.query('patients_auth', limit: 1);
      _addLog('[SUCCESS] Table access successful, found ${result.length} records');
      
    } catch (e) {
      _addLog('[ERROR] Database test failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testRegistration() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _addLog('Testing patient registration...');
      
      final testEmail = 'test_patient_${DateTime.now().millisecondsSinceEpoch}@example.com';
      _addLog('Using email: $testEmail');
      
      final success = await _authService.signUp(
        email: testEmail,
        password: 'testpassword123',
        fullName: 'Test Patient',
        phoneNumber: '+977-9876543210',
        gender: 'Male',
        address: 'Test Address, Kathmandu',
      );
      
      if (success) {
        _addLog('[SUCCESS] Registration successful!');
        
        // Test login
        _addLog('Testing login with registered credentials...');
        final loginSuccess = await _authService.login(testEmail, 'testpassword123');
        
        if (loginSuccess) {
          _addLog('[SUCCESS] Login successful!');
          
          // Get patient info
          final patientInfo = await _authService.getPatientInfo();
          _addLog('Patient ID: ${patientInfo['id']}');
          _addLog('Patient Name: ${patientInfo['name']}');
          _addLog('Patient Email: ${patientInfo['email']}');
        } else {
          _addLog('[ERROR] Login failed after registration');
        }
      } else {
        _addLog('[ERROR] Registration failed');
      }
      
    } catch (e) {
      _addLog('[ERROR] Registration test failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testDemoPatient() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _addLog('Testing demo patient creation...');
      
      final success = await _authService.createSamplePatient();
      
      if (success) {
        _addLog('[SUCCESS] Demo patient created successfully!');
        
        // Test demo login
        _addLog('Testing demo login...');
        final loginSuccess = await _authService.login('patient@example.com', 'password123');
        
        if (loginSuccess) {
          _addLog('[SUCCESS] Demo login successful!');
        } else {
          _addLog('[ERROR] Demo login failed');
        }
      } else {
        _addLog('[ERROR] Demo patient creation failed');
      }
      
    } catch (e) {
      _addLog('[ERROR] Demo patient test failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Registration Debug'),
        backgroundColor: Colors.lightBlue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Patient Registration Debug Tool',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Test Buttons
            ElevatedButton(
              onPressed: _isLoading ? null : _testDatabaseConnection,
              child: const Text('Test Database Connection'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testRegistration,
              child: const Text('Test Registration Flow'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testDemoPatient,
              child: const Text('Test Demo Patient'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _debugLogs.clear();
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: const Text('Clear Logs'),
            ),
            
            const SizedBox(height: 16),
            
            // Loading Indicator
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            
            // Debug Logs
            const Text(
              'Debug Logs:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                padding: const EdgeInsets.all(12),
                child: _debugLogs.isEmpty
                  ? const Text('No logs yet. Run a test to see debug information.')
                  : ListView.builder(
                      itemCount: _debugLogs.length,
                      itemBuilder: (context, index) {
                        final log = _debugLogs[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            log,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: log.contains('[ERROR]') 
                                ? Colors.red[700]
                                : log.contains('[SUCCESS]')
                                  ? Colors.green[700]
                                  : Colors.black87,
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}