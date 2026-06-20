import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final IconData prefixIcon;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool isPassword;
  final TextInputType keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    required this.label,
    required this.prefixIcon,
    required this.controller,
    this.hint,
    this.validator,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        validator: validator,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(prefixIcon),
        ),
      ),
    );
  }
}
