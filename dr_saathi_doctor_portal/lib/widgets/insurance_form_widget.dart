import 'package:flutter/material.dart';
import '../models/insurance.dart';

class InsuranceFormWidget extends StatefulWidget {
  final Insurance? initialInsurance;
  final ValueChanged<Insurance?> onInsuranceChanged;
  final bool isRequired;

  const InsuranceFormWidget({
    Key? key,
    this.initialInsurance,
    required this.onInsuranceChanged,
    this.isRequired = false,
  }) : super(key: key);

  @override
  State<InsuranceFormWidget> createState() => _InsuranceFormWidgetState();
}

class _InsuranceFormWidgetState extends State<InsuranceFormWidget> {
  final _companyController = TextEditingController();
  final _policyNumberController = TextEditingController();
  final _memberIdController = TextEditingController();
  final _groupNumberController = TextEditingController();
  bool _hasInsurance = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialInsurance != null) {
      _hasInsurance = true;
      _companyController.text = widget.initialInsurance!.company ?? '';
      _policyNumberController.text = widget.initialInsurance!.policyNumber ?? '';
      _memberIdController.text = widget.initialInsurance!.memberId ?? '';
      _groupNumberController.text = widget.initialInsurance!.groupNumber ?? '';
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _policyNumberController.dispose();
    _memberIdController.dispose();
    _groupNumberController.dispose();
    super.dispose();
  }

  void _updateInsurance() {
    if (!_hasInsurance) {
      widget.onInsuranceChanged(null);
      return;
    }
    widget.onInsuranceChanged(Insurance(
      company: _companyController.text.isNotEmpty ? _companyController.text : null,
      policyNumber: _policyNumberController.text.isNotEmpty ? _policyNumberController.text : null,
      memberId: _memberIdController.text.isNotEmpty ? _memberIdController.text : null,
      groupNumber: _groupNumberController.text.isNotEmpty ? _groupNumberController.text : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Has Insurance'),
          value: _hasInsurance,
          onChanged: (value) {
            setState(() {
              _hasInsurance = value;
            });
            _updateInsurance();
          },
        ),
        if (_hasInsurance) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: _companyController,
            decoration: const InputDecoration(
              labelText: 'Insurance Company',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _updateInsurance(),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _policyNumberController,
            decoration: const InputDecoration(
              labelText: 'Policy Number',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _updateInsurance(),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _memberIdController,
            decoration: const InputDecoration(
              labelText: 'Member ID',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _updateInsurance(),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _groupNumberController,
            decoration: const InputDecoration(
              labelText: 'Group Number',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _updateInsurance(),
          ),
        ],
      ],
    );
  }
}
