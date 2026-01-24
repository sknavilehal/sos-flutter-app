import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class LabeledTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final int? maxLength;
  final TextStyle? textStyle;
  final String? counterText;
  final EdgeInsetsGeometry contentPadding;

  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.textStyle,
    this.counterText,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppTheme.neutralGrey,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          style: textStyle ??
              const TextStyle(
                fontSize: 18,
                color: AppTheme.primaryBlack,
              ),
          decoration: InputDecoration(
            counterText: counterText,
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryBlack, width: 1),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryBlack, width: 1),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryBlack, width: 1),
            ),
            contentPadding: contentPadding,
          ),
        ),
      ],
    );
  }
}
