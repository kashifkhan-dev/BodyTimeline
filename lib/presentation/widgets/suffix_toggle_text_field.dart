import 'package:flutter/cupertino.dart';
import '../../core/theme/color_palette.dart';

class SuffixToggleTextField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final String suffix;
  final VoidCallback onSuffixTap;
  final AppColors colors;
  final TextInputType keyboardType;
  final bool isLarge;

  const SuffixToggleTextField({
    super.key,
    required this.controller,
    required this.placeholder,
    required this.suffix,
    required this.onSuffixTap,
    required this.colors,
    this.keyboardType = const TextInputType.numberWithOptions(decimal: true),
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      keyboardType: keyboardType,
      textAlign: isLarge ? TextAlign.center : TextAlign.start,
      style: TextStyle(
        color: colors.textPrimary,
        fontSize: isLarge ? 32 : 17,
        fontWeight: isLarge ? FontWeight.bold : FontWeight.normal,
      ),
      padding: isLarge
          ? const EdgeInsets.symmetric(vertical: 24, horizontal: 20)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      suffix: GestureDetector(
        onTap: onSuffixTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Text(
            suffix,
            style: TextStyle(color: colors.primary, fontSize: isLarge ? 24 : 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
