import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import 'providers/leads_provider.dart';

class CreateLeadScreen extends ConsumerStatefulWidget {
  const CreateLeadScreen({super.key});

  @override
  ConsumerState<CreateLeadScreen> createState() => _CreateLeadScreenState();
}

class _CreateLeadScreenState extends ConsumerState<CreateLeadScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();

  Future<void> _saveLead() async {
    final success = await ref.read(leadsProvider.notifier).createLead({
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
      'notes': _notesController.text,
    });

    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Lead', style: TextStyle(fontWeight: FontWeight.bold)),
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
            const Text('LEAD ACQUISITION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('Capture Potential', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 16),
            Container(width: 48, height: 4, decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(2))),
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
              ],
            ),

            const SizedBox(height: 100), // Space for bottom buttons
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          border: Border(top: BorderSide(color: AppColors.outlineVariant.withOpacity(0.2))),
        ),
        child: SafeArea(
          child: Row(
            children: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Discard Draft', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saveLead,
                  icon: const Icon(Icons.verified_user),
                  label: const Text('Save Lead Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryContainer),
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
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: type,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText,
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
