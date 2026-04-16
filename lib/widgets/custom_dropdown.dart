import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String   label;
  final String?  value;
  final List<Map<String, dynamic>> items;
  final String   displayKey;
  final String   valueKey;        // clé utilisée comme valeur — défaut 'id'
  final void Function(String?) onChanged;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.displayKey,
    required this.onChanged,
    this.valueKey = 'id',         // rétrocompatible avec l'ancien code
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue:  value,
      onChanged:     onChanged,
      dropdownColor: const Color(0xFF1A1D27),
      style:         const TextStyle(color: Colors.white),
      icon: const Icon(Icons.keyboard_arrow_down,
          color: Color(0xFF8A8F9E)),
      decoration: InputDecoration(
        labelText:  label,
        labelStyle: const TextStyle(color: Color(0xFF8A8F9E)),
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
      ),
      items: items.map((item) => DropdownMenuItem<String>(
        value: item[valueKey] as String,
        child: Text(
          item[displayKey] as String,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      )).toList(),
      validator: (v) => v == null ? 'Sélection obligatoire' : null,
    );
  }
}
