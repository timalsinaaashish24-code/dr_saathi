import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/patient_auth_service.dart';
import '../utils/nepali_number_utils.dart';

class PatientLoginScreen extends StatefulWidget {
  const PatientLoginScreen({super.key});

  @override
  State<PatientLoginScreen> createState() => _PatientLoginScreenState();
}

class _PatientLoginScreenState extends State<PatientLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  
  bool _isLoading = false;
  bool _isSignUp = false;
  bool _obscurePassword = true;
  String _errorMessage = '';
  String _selectedGender = '';
  DateTime? _selectedDateOfBirth;
  
  bool _isNepali(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ne';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authService = PatientAuthService();
      final success = await authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success) {
        // Save login state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_patient_logged_in', true);
        await prefs.setString('patient_email', _emailController.text.trim());
        
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/patient_dashboard');
        }
      } else {
        setState(() {
          _errorMessage = _isNepali(context) 
              ? 'अमान्य इमेल वा पासवर्ड'
              : 'Invalid email or password';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = _isNepali(context)
            ? 'लगइन असफल भयो। कृपया पुन: प्रयास गर्नुहोस्।'
            : 'Login failed. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authService = PatientAuthService();
      final success = await authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isNotEmpty 
          ? _phoneController.text.trim() 
          : null,
        dateOfBirth: _selectedDateOfBirth?.toIso8601String().substring(0, 10),
        gender: _selectedGender.isNotEmpty ? _selectedGender : null,
        address: _addressController.text.trim().isNotEmpty 
          ? _addressController.text.trim() 
          : null,
      );

      if (success) {
        // Auto-login after successful signup
        setState(() {
          _errorMessage = '';
        });
        await _handleLogin();
      } else {
        setState(() {
          _errorMessage = _isNepali(context)
              ? 'दर्ता असफल भयो। इमेल पहिले नै अवस्थित हुन सक्छ वा डाटाबेस त्रुटि थियो। कृपया फरक इमेलको साथ पुन: प्रयास गर्नुहोस्।'
              : 'Registration failed. Email might already exist or there was a database error. Please try again with a different email.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = _isNepali(context)
            ? 'त्रुटिको कारण दर्ता असफल भयो: $e। कृपया पुन: प्रयास गर्नुहोस् वा सहयोगलाई सम्पर्क गर्नुहोस्।'
            : 'Registration failed due to an error: $e. Please try again or contact support.';
      });
      print('Patient registration error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNepali = _isNepali(context);
    
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Logo and Title
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.lightBlue[100],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.lightBlue.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 15,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/dr_saathi_icon.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                _isSignUp 
                    ? (isNepali ? 'बिरामी दर्ता' : 'Patient Registration')
                    : (isNepali ? 'बिरामी लगइन' : 'Patient Login'),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue[800],
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                _isSignUp 
                  ? (isNepali ? 'आफ्नो बिरामी खाता सिर्जना गर्नुहोस्' : 'Create your patient account')
                  : (isNepali ? 'आफ्नो चिकित्सा रेकर्ड र बिलहरू पहुँच गर्नुहोस्' : 'Access your medical records and invoices'),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.lightBlue[600],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Login/SignUp Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Full Name field (only for sign up)
                    if (_isSignUp) ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: isNepali ? 'पूरा नाम' : 'Full Name',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return isNepali ? 'कृपया आफ्नो पूरा नाम प्रविष्ट गर्नुहोस्' : 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: isNepali ? 'इमेल' : 'Email',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return isNepali ? 'कृपया आफ्नो इमेल प्रविष्ट गर्नुहोस्' : 'Please enter your email';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return isNepali ? 'कृपया मान्य इमेल प्रविष्ट गर्नुहोस्' : 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: isNepali ? 'पासवर्ड' : 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return isNepali ? 'कृपया आफ्नो पासवर्ड प्रविष्ट गर्नुहोस्' : 'Please enter your password';
                        }
                        if (_isSignUp && value.length < 6) {
                          return isNepali 
                              ? 'पासवर्ड कम्तिमा ${NepaliNumberUtils.formatNumber(6, isNepali)} वर्ण हुनुपर्छ'
                              : 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    
                    // Additional fields for sign up
                    if (_isSignUp) ...[
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: isNepali ? 'फोन नम्बर (ऐच्छिक)' : 'Phone Number (Optional)',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Date of Birth field
                      TextFormField(
                        controller: _dobController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: isNepali ? 'जन्म मिति (ऐच्छिक)' : 'Date of Birth (Optional)',
                          prefixIcon: const Icon(Icons.calendar_today),
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: isNepali ? 'आफ्नो जन्म मिति चयन गर्नुहोस्' : 'Select your date of birth',
                        ),
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDateOfBirth ?? DateTime(2000),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: Colors.lightBlue[600]!,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null && picked != _selectedDateOfBirth) {
                            setState(() {
                              _selectedDateOfBirth = picked;
                              final dateStr = '${picked.day}/${picked.month}/${picked.year}';
                              _dobController.text = isNepali ? NepaliNumberUtils.toNepaliNumber(dateStr) : dateStr;
                            });
                          }
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<String>(
                        value: _selectedGender.isEmpty ? null : _selectedGender,
                        decoration: InputDecoration(
                          labelText: isNepali ? 'लिङ्ग (ऐच्छिक)' : 'Gender (Optional)',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: [
                          DropdownMenuItem(value: 'Male', child: Text(isNepali ? 'पुरुष' : 'Male')),
                          DropdownMenuItem(value: 'Female', child: Text(isNepali ? 'महिला' : 'Female')),
                          DropdownMenuItem(value: 'Other', child: Text(isNepali ? 'अन्य' : 'Other')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value ?? '';
                          });
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: isNepali ? 'ठेगाना (ऐच्छिक)' : 'Address (Optional)',
                          prefixIcon: const Icon(Icons.location_on),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        maxLines: 2,
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Error message
                    if (_errorMessage.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red[600]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage,
                                style: TextStyle(color: Colors.red[600]),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Login/SignUp Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : (_isSignUp ? _handleSignUp : _handleLogin),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _isSignUp 
                                  ? (isNepali ? 'खाता सिर्जना गर्नुहोस्' : 'Create Account')
                                  : (isNepali ? 'लगइन' : 'Login'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Toggle between login and signup
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSignUp = !_isSignUp;
                          _errorMessage = '';
                        });
                      },
                      child: Text(
                        _isSignUp
                          ? (isNepali ? 'पहिले नै खाता छ? लगइन' : 'Already have an account? Login')
                          : (isNepali ? 'खाता छैन? दर्ता गर्नुहोस्' : 'Don\'t have an account? Sign Up'),
                        style: TextStyle(color: Colors.lightBlue[600]),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Demo Login Button
                    if (!_isSignUp) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : () async {
                            // Create sample patient if doesn't exist
                            final authService = PatientAuthService();
                            await authService.createSamplePatient();
                            
                            // Auto-fill with demo credentials
                            _emailController.text = 'patient@example.com';
                            _passwordController.text = 'password123';
                            
                            // Perform login
                            await _handleLogin();
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.lightBlue[600]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isNepali ? 'डेमो लगइन' : 'Demo Login',
                            style: TextStyle(
                              color: Colors.lightBlue[600],
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Back to app button
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_back, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            isNepali ? 'एपमा फर्किनुहोस्' : 'Back to App',
                            style: TextStyle(color: Colors.lightBlue[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}