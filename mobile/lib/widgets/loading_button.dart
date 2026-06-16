import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class LoadingButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;
  final IconData? icon;

  const LoadingButton({
    super.key,
    required this.label,
    this.isLoading = false,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon ?? Icons.send),
        label: Text(isLoading ? l.processing : label),
      ),
    );
  }
}
