import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String     label;
  final String     hint;
  final bool       readOnly;
  final VoidCallback? onTap;
  final Widget?    suffix;
  final String?    Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.readOnly  = false,
    this.onTap,
    this.suffix,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly:   readOnly,
      onTap:      onTap,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText:  label,
        labelStyle: const TextStyle(color: Color(0xFF8A8F9E)),
        hintText:   hint,
        hintStyle:  const TextStyle(color: Color(0xFF3D4155)),
        suffixIcon: suffix,
        filled:     true,
        fillColor:  const Color(0xFF1A1D27),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2D3142)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2D3142)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3ECF8E)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      validator: validator ??
          (v) => (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
    );
  }
}
