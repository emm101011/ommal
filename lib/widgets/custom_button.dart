import 'package:flutter/material.dart';
import '../theme/app_styles.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool expanded;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: onPressed,
      style: AppStyles.primaryButton,
      child: Text(label),
    );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
