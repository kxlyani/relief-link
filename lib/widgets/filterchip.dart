import 'package:flutter/material.dart';

class FilterChip extends StatelessWidget {
  final Widget label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const FilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: selected ? Colors.blue : Colors.grey[200],
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: InkWell(
        onTap: () => onSelected(!selected),
        child: DefaultTextStyle(
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontSize: 14.0,
          ),
          child: label,
        ),
      ),
    );
  }
}