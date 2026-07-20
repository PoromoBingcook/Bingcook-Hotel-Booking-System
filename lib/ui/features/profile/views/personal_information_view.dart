import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/features/profile/view_models/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PersonalInformationView extends StatefulWidget {
  const PersonalInformationView({
    required this.viewModel,
    required this.onBack,
    super.key,
  });

  final ProfileViewModel viewModel;
  final VoidCallback onBack;

  @override
  State<PersonalInformationView> createState() =>
      _PersonalInformationViewState();
}

class _PersonalInformationViewState extends State<PersonalInformationView> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.viewModel.fullNameValue,
    );
    _phoneController = TextEditingController(text: widget.viewModel.phoneValue);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          key: const Key('personal_information_back_button'),
          tooltip: 'Back',
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Personal Information',
          style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) => ListView(
            key: const Key('personal_information_view'),
            padding: const EdgeInsets.all(16),
            children: [
              _EditableField(
                fieldKey: const Key('personal_information_full_name_field'),
                controller: _nameController,
                icon: Icons.person_outline_rounded,
                label: 'Full Name',
                enabled: !widget.viewModel.isSavingProfile,
                maxLength: 100,
              ),
              const SizedBox(height: 12),
              _ReadOnlyField(
                icon: Icons.email_outlined,
                label: 'Email',
                value: widget.viewModel.email,
              ),
              const SizedBox(height: 12),
              _EditableField(
                fieldKey: const Key('personal_information_phone_field'),
                controller: _phoneController,
                icon: Icons.phone_outlined,
                label: 'Phone',
                enabled: !widget.viewModel.isSavingProfile,
                keyboardType: TextInputType.phone,
                inputFormatters: const [_PhoneFormatter()],
                maxLength: 20,
              ),
              const SizedBox(height: 12),
              _ReadOnlyField(
                icon: Icons.badge_outlined,
                label: 'Role',
                value: widget.viewModel.roleLabel,
              ),
              if (widget.viewModel.errorMessage != null) ...[
                const SizedBox(height: 14),
                Text(
                  widget.viewModel.errorMessage!,
                  key: const Key('personal_information_error'),
                  style: const TextStyle(color: AppColors.error),
                ),
              ],
              if (widget.viewModel.successMessage != null) ...[
                const SizedBox(height: 14),
                Text(
                  widget.viewModel.successMessage!,
                  key: const Key('personal_information_success'),
                  style: const TextStyle(
                    color: Color(0xFF168A45),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                key: const Key('personal_information_save_button'),
                onPressed: widget.viewModel.isSavingProfile
                    ? null
                    : () => widget.viewModel.updateProfile(
                        fullName: _nameController.text,
                        phone: _phoneController.text,
                      ),
                child: widget.viewModel.isSavingProfile
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditableField extends StatelessWidget {
  const _EditableField({
    required this.fieldKey,
    required this.controller,
    required this.icon,
    required this.label,
    required this.enabled,
    required this.maxLength,
    this.keyboardType,
    this.inputFormatters,
  });

  final Key fieldKey;
  final TextEditingController controller;
  final IconData icon;
  final String label;
  final bool enabled;
  final int maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: fieldKey,
      controller: controller,
      enabled: enabled,
      maxLength: maxLength,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        counterText: '',
        prefixIcon: Icon(icon, color: AppColors.gray400),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: AppColors.gray400),
        suffixIcon: const Icon(Icons.lock_outline_rounded),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _PhoneFormatter extends TextInputFormatter {
  const _PhoneFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return RegExp(r'^\+?\d*$').hasMatch(newValue.text) ? newValue : oldValue;
  }
}
