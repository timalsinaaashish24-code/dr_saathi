import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/insurance.dart';

class InsuranceFormWidget extends StatefulWidget {
  final Insurance? initialInsurance;
  final Function(Insurance?) onInsuranceChanged;
  final bool isRequired;

  const InsuranceFormWidget({
    super.key,
    this.initialInsurance,
    required this.onInsuranceChanged,
    this.isRequired = false,
  });

  @override
  State<InsuranceFormWidget> createState() => _InsuranceFormWidgetState();
}

class _InsuranceFormWidgetState extends State<InsuranceFormWidget> {
  late TextEditingController _companyController;
  late TextEditingController _policyNumberController;
  late TextEditingController _memberIdController;
  late TextEditingController _groupNumberController;
  late TextEditingController _expiryDateController;
  
  InsuranceType _selectedType = InsuranceType.health;
  DateTime? _expiryDate;
  bool _hasInsurance = false;
  
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    
    _hasInsurance = widget.initialInsurance != null;
    
    _companyController = TextEditingController(
      text: widget.initialInsurance?.company ?? ''
    );
    _policyNumberController = TextEditingController(
      text: widget.initialInsurance?.policyNumber ?? ''
    );
    _memberIdController = TextEditingController(
      text: widget.initialInsurance?.memberId ?? ''
    );
    _groupNumberController = TextEditingController(
      text: widget.initialInsurance?.groupNumber ?? ''
    );
    
    if (widget.initialInsurance?.expiryDate != null) {
      _expiryDate = widget.initialInsurance!.expiryDate;
      _expiryDateController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(_expiryDate!)
      );
    } else {
      _expiryDateController = TextEditingController();
    }
    
    if (widget.initialInsurance != null) {
      _selectedType = widget.initialInsurance!.type;
    }
    
    // Add listeners to update parent widget
    _companyController.addListener(_updateInsurance);
    _policyNumberController.addListener(_updateInsurance);
    _memberIdController.addListener(_updateInsurance);
    _groupNumberController.addListener(_updateInsurance);
  }

  @override
  void dispose() {
    _companyController.dispose();
    _policyNumberController.dispose();
    _memberIdController.dispose();
    _groupNumberController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  void _updateInsurance() {
    if (!_hasInsurance) {
      widget.onInsuranceChanged(null);
      return;
    }

    final insurance = Insurance(
      company: _companyController.text.isNotEmpty ? _companyController.text : null,
      policyNumber: _policyNumberController.text.isNotEmpty ? _policyNumberController.text : null,
      memberId: _memberIdController.text.isNotEmpty ? _memberIdController.text : null,
      groupNumber: _groupNumberController.text.isNotEmpty ? _groupNumberController.text : null,
      type: _selectedType,
      expiryDate: _expiryDate,
    );
    
    widget.onInsuranceChanged(insurance);
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      helpText: 'Select Expiry Date',
    );
    
    if (picked != null) {
      setState(() {
        _expiryDate = picked;
        _expiryDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
      _updateInsurance();
    }
  }

  void _showCompanySelectionDialog() async {
    final String? selectedCompany = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Insurance Company'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: InsuranceCompanies.nepalInsuranceCompanies.length,
              itemBuilder: (context, index) {
                final company = InsuranceCompanies.nepalInsuranceCompanies[index];
                return ListTile(
                  title: Text(company),
                  onTap: () => Navigator.of(context).pop(company),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (selectedCompany != null && selectedCompany != 'Other') {
      setState(() {
        _companyController.text = selectedCompany;
      });
      _updateInsurance();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Insurance Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.isRequired)
                  const Text(
                    ' *',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Has Insurance Checkbox
            CheckboxListTile(
              title: const Text('I have insurance coverage'),
              value: _hasInsurance,
              onChanged: (bool? value) {
                setState(() {
                  _hasInsurance = value ?? false;
                });
                _updateInsurance();
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            
            if (_hasInsurance) ...[
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Insurance Type Dropdown
                    DropdownButtonFormField<InsuranceType>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Insurance Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: InsuranceType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.displayName),
                        );
                      }).toList(),
                      onChanged: (InsuranceType? value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                          });
                          _updateInsurance();
                        }
                      },
                      validator: widget.isRequired 
                          ? (value) => value == null ? 'Please select insurance type' : null
                          : null,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Insurance Company
                    TextFormField(
                      controller: _companyController,
                      decoration: InputDecoration(
                        labelText: 'Insurance Company',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.business),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.list),
                          onPressed: _showCompanySelectionDialog,
                          tooltip: 'Select from list',
                        ),
                      ),
                      validator: widget.isRequired 
                          ? (value) => value?.isEmpty ?? true ? 'Please enter insurance company' : null
                          : null,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Policy Number and Member ID Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _policyNumberController,
                            decoration: const InputDecoration(
                              labelText: 'Policy Number',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.confirmation_number),
                            ),
                            validator: (value) {
                              if (widget.isRequired && _hasInsurance) {
                                if ((value?.isEmpty ?? true) && (_memberIdController.text.isEmpty)) {
                                  return 'Policy number or member ID required';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _memberIdController,
                            decoration: const InputDecoration(
                              labelText: 'Member ID',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (widget.isRequired && _hasInsurance) {
                                if ((value?.isEmpty ?? true) && (_policyNumberController.text.isEmpty)) {
                                  return 'Policy number or member ID required';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Group Number and Expiry Date Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _groupNumberController,
                            decoration: const InputDecoration(
                              labelText: 'Group Number (Optional)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.group),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _expiryDateController,
                            decoration: const InputDecoration(
                              labelText: 'Expiry Date (Optional)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            readOnly: true,
                            onTap: _selectExpiryDate,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Insurance Status Indicator
              if (_hasInsurance && widget.initialInsurance != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.initialInsurance!.isExpired 
                        ? Colors.red.shade50 
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: widget.initialInsurance!.isExpired 
                          ? Colors.red.shade200 
                          : Colors.green.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.initialInsurance!.isExpired 
                            ? Icons.warning 
                            : Icons.check_circle,
                        color: widget.initialInsurance!.isExpired 
                            ? Colors.red 
                            : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.initialInsurance!.isExpired
                              ? 'Insurance policy has expired'
                              : 'Insurance policy is valid',
                          style: TextStyle(
                            color: widget.initialInsurance!.isExpired 
                                ? Colors.red.shade700 
                                : Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  bool validate() {
    if (!_hasInsurance && !widget.isRequired) return true;
    if (!_hasInsurance && widget.isRequired) return false;
    return _formKey.currentState?.validate() ?? false;
  }
}
