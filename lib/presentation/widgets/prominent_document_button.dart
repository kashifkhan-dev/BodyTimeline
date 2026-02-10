import 'package:flutter/cupertino.dart';
import 'package:cupertino_native_better/cupertino_native_better.dart';
import '../../../core/theme/color_palette.dart';

class ProminentDocumentButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final AppColors colors;

  const ProminentDocumentButton({super.key, required this.label, required this.onTap, required this.colors});

  @override
  Widget build(BuildContext context) {
    return CNButton(
      label: label,
      onPressed: onTap,
      icon: const CNSymbol('gift', size: 20),
      config: const CNButtonConfig(style: CNButtonStyle.prominentGlass),
    );
  }
}
