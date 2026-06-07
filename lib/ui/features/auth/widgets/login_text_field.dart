import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginTextField extends StatelessWidget {
  const LoginTextField({
    required this.fieldKey,
    required this.controller,
    required this.label,
    required this.hint,
    required this.iconAsset,
    super.key,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
  });

  final Key fieldKey;
  final TextEditingController controller;
  final String label;
  final String hint;
  final String iconAsset;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 1),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.slate700,
              fontFamily: 'Manrope',
              fontSize: 14,
              height: 1.43,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: 58,
          child: TextField(
            key: fieldKey,
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: const TextStyle(
              color: AppColors.slate700,
              fontFamily: 'Manrope',
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppColors.slate400,
                fontFamily: 'Manrope',
                fontSize: 16,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 45,
                minHeight: 58,
              ),
              prefixIcon: Align(
                alignment: Alignment.centerLeft,
                widthFactor: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: SvgPicture.asset(iconAsset, width: 20, height: 20),
                ),
              ),
              suffixIcon: suffixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
