import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _licenseController = TextEditingController();
  final _specializationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();
  final _bankNameController = TextEditingController();
  String _selectedGender = 'Male';
  final _bankAccountController = TextEditingController();
  final _bankBranchController = TextEditingController();
  
  bool _isLoading = true;
  bool _isEditing = false;
  String? _doctorId;

  @override
  void initState() {
    super.initState();
    _loadDoctorProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _licenseController.dispose();
    _specializationController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _bankNameController.dispose();
    _bankAccountController.dispose();
    _bankBranchController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctorProfile() async {
    setState(() => _isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('doctor_email') ?? '';
      
      final db = await DatabaseService().database;
      final result = await db.query(
        'doctors',
        where: 'email = ?',
        whereArgs: [email],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final doctor = result.first;
        _doctorId = doctor['id'].toString();
        _nameController.text = doctor['name']?.toString() ?? '';
        _emailController.text = doctor['email']?.toString() ?? '';
        _licenseController.text = doctor['license_number']?.toString() ?? '';
        _specializationController.text = doctor['specialization']?.toString() ?? '';
        _phoneController.text = doctor['phone']?.toString() ?? '';
        _ageController.text = doctor['age']?.toString() ?? '';
        _selectedGender = doctor['gender']?.toString() ?? 'Male';
        _addressController.text = doctor['address']?.toString() ?? '';
        _bankNameController.text = doctor['bank_name']?.toString() ?? '';
        _bankAccountController.text = doctor['bank_account_number']?.toString() ?? '';
        _bankBranchController.text = doctor['bank_branch']?.toString() ?? '';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final db = await DatabaseService().database;
      await db.update(
        'doctors',
        {
          'name': _nameController.text.trim(),
          'specialization': _specializationController.text.trim(),
          'phone': _phoneController.text.trim(),
          'age': int.tryParse(_ageController.text.trim()),
          'gender': _selectedGender,
          'address': _addressController.text.trim(),
          'bank_name': _bankNameController.text.trim(),
          'bank_account_number': _bankAccountController.text.trim(),
          'bank_branch': _bankBranchController.text.trim(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [_doctorId],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.teal[700],
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() => _isEditing = true);
              },
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _loadDoctorProfile();
                setState(() => _isEditing = false);
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture Placeholder
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.teal[100],
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.teal[700],
                            ),
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.teal[700],
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Personal Information Section
                    _buildSectionTitle('Personal Information'),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person,
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email,
                      enabled: false, // Email cannot be changed
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone,
                      enabled: _isEditing,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _ageController,
                      label: 'Age',
                      icon: Icons.cake,
                      enabled: _isEditing,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final age = int.tryParse(value);
                          if (age == null || age < 18 || age > 100) {
                            return 'Please enter a valid age (18-100)';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    _isEditing
                        ? DropdownButtonFormField<String>(
                            value: _selectedGender,
                            decoration: InputDecoration(
                              labelText: 'Gender',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            items: ['Male', 'Female', 'Other'].map((String gender) {
                              return DropdownMenuItem<String>(
                                value: gender,
                                child: Text(gender),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedGender = newValue;
                                });
                              }
                            },
                          )
                        : _buildTextField(
                            controller: TextEditingController(text: _selectedGender),
                            label: 'Gender',
                            icon: Icons.person_outline,
                            enabled: false,
                          ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _addressController,
                      label: 'Address',
                      icon: Icons.location_on,
                      enabled: _isEditing,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),

                    // Professional Information Section
                    _buildSectionTitle('Professional Information'),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _licenseController,
                      label: 'License Number',
                      icon: Icons.badge,
                      enabled: false, // License cannot be changed
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _specializationController,
                      label: 'Specialization',
                      icon: Icons.medical_services,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 24),

                    // Bank Details Section
                    _buildSectionTitle('Bank Details'),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _bankNameController,
                      label: 'Bank Name',
                      icon: Icons.account_balance,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _bankAccountController,
                      label: 'Account Number',
                      icon: Icons.credit_card,
                      enabled: _isEditing,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _bankBranchController,
                      label: 'Branch',
                      icon: Icons.location_city,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    if (_isEditing)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.teal[700],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      validator: validator,
    );
  }
}
