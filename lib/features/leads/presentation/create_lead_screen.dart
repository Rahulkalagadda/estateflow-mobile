import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import 'providers/leads_provider.dart';
import 'providers/pipeline_provider.dart';

import '../../../core/models/lead_model.dart';

class CreateLeadScreen extends ConsumerStatefulWidget {
  final LeadModel? existingLead;
  
  const CreateLeadScreen({super.key, this.existingLead});

  @override
  ConsumerState<CreateLeadScreen> createState() => _CreateLeadScreenState();
}

class _CreateLeadScreenState extends ConsumerState<CreateLeadScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _notesController;
  late final TextEditingController _budgetController;
  late final TextEditingController _sourceController;
  late final TextEditingController _propertyController;
  late final TextEditingController _preapprovalController;
  late final TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    final lead = widget.existingLead;
    _firstNameController = TextEditingController(text: lead?.firstName ?? '');
    _lastNameController = TextEditingController(text: lead?.lastName ?? '');
    _phoneController = TextEditingController(text: lead?.phone ?? '');
    _emailController = TextEditingController(text: lead?.email ?? '');
    _notesController = TextEditingController(text: lead?.notes ?? '');
    _budgetController = TextEditingController(text: lead?.budget?.toString() ?? '');
    _sourceController = TextEditingController(text: lead?.source ?? 'Mobile App');
    _propertyController = TextEditingController(text: lead?.interestedProperty ?? '');
    _preapprovalController = TextEditingController(text: lead?.preapprovalStatus ?? '');
    _locationController = TextEditingController(text: lead?.location ?? '');
  }

  Future<void> _saveLead() async {
    final pipelineState = ref.read(pipelineProvider);
    if (pipelineState.stages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait for pipeline stages to load...')),
      );
      return;
    }

    final data = {
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
      'notes': _notesController.text,
      'budget': double.tryParse(_budgetController.text),
      'source': _sourceController.text,
      'interestedProperty': _propertyController.text,
      'preapprovalStatus': _preapprovalController.text,
      'location': _locationController.text,
    };

    bool success;
    if (widget.existingLead != null) {
      success = await ref.read(leadsProvider.notifier).updateLead(widget.existingLead!.id, data);
    } else {
      data['stageId'] = pipelineState.stages.first.id;
      success = await ref.read(leadsProvider.notifier).createLead(data);
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.existingLead != null ? 'Lead updated successfully!' : 'Lead created successfully!'), backgroundColor: Colors.green),
        );
        context.pop();
      } else {
        final error = ref.read(leadsProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Failed to create lead. Please check the required fields.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(leadsProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingLead != null ? 'Edit Lead' : 'Create New Lead', style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text('LEAD ACQUISITION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: context.colors.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text(widget.existingLead != null ? 'Update Profile' : 'Capture Potential', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 16),
            Container(width: 48, height: 4, decoration: BoxDecoration(color: context.colors.primaryContainer, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 32),

            // Form Sections
            _buildSection(
              context,
              title: 'Personal Details',
              icon: Icons.person,
              children: [
                _buildInputField('FIRST NAME', 'e.g. Alexander', controller: _firstNameController),
                const SizedBox(height: 16),
                _buildInputField('LAST NAME', 'e.g. Thorne', controller: _lastNameController),
                const SizedBox(height: 16),
                _buildInputField('PHONE NUMBER', '+1 (555) 000-0000', type: TextInputType.phone, controller: _phoneController),
                const SizedBox(height: 16),
                _buildInputField('EMAIL ADDRESS', 'alex@concierge.com', type: TextInputType.emailAddress, controller: _emailController),
              ],
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              title: 'Additional Info',
              icon: Icons.notes,
              children: [
                _buildInputField('NOTES', 'Interested in luxury properties...', controller: _notesController),
                const SizedBox(height: 16),
                _buildInputField('BUDGET', 'e.g. 5000000', type: TextInputType.number, controller: _budgetController),
                const SizedBox(height: 16),
                _buildInputField('LEAD SOURCE', 'e.g. Web, Referral, Instagram', controller: _sourceController),
                const SizedBox(height: 16),
                _buildInputField('INTERESTED PROPERTY', 'e.g. Skyline Penthouse', controller: _propertyController),
                const SizedBox(height: 16),
                _buildInputField('PRE-APPROVAL STATUS', 'e.g. Verified ₹10 Cr', controller: _preapprovalController),
                const SizedBox(height: 16),
                _buildInputField('LOCATION', 'e.g. Los Angeles, CA', controller: _locationController),
              ],
            ),

            const SizedBox(height: 100), // Space for bottom buttons
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.colors.background,
          border: Border(top: BorderSide(color: context.colors.outlineVariant)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              TextButton(
                onPressed: () => context.pop(),
                child: Text('Discard Changes', style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.onSurfaceVariant)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isSaving ? null : _saveLead,
                  icon: isSaving 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.verified_user),
                  label: Text(isSaving ? 'Saving...' : (widget.existingLead != null ? 'Update Lead Profile' : 'Save Lead Profile'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: context.colors.primaryContainer),
              const SizedBox(width: 12),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String hint, {TextInputType? type, String? prefixText, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: context.colors.onSurfaceVariant)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: type,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText,
          ),
        ),
      ],
    );
  }
}
