import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    required this.fieldKey,
    required this.controller,
    required this.label,
    required this.hint,
    required this.iconAsset,
    super.key,
    this.iconKey,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.errorText,
    this.suffixIcon,
  });

  final Key fieldKey;
  final TextEditingController controller;
  final String label;
  final String hint;
  final String iconAsset;
  final Key? iconKey;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final String? errorText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        TextField(
          key: fieldKey,
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          textInputAction: TextInputAction.next,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            height: 1.2,
          ),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
            prefixIcon: Align(
              key: iconKey,
              alignment: Alignment.centerLeft,
              widthFactor: 1,
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: SvgPicture.asset(
                  iconAsset,
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
