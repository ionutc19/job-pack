import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/language_provider.dart';

class LanguageDropdown extends StatelessWidget {
  const LanguageDropdown({super.key});

  static const _languages = [
    _LangOption('en', 'EN', '🇬🇧'),
    _LangOption('ro', 'RO', '🇷🇴'),
  ];

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final current = langProvider.locale.languageCode;

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: current,
        icon: const Icon(Icons.arrow_drop_down, size: 20),
        borderRadius: BorderRadius.circular(12),
        items: _languages
            .map((lang) => DropdownMenuItem<String>(
                  value: lang.code,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(lang.flag, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Text(
                        lang.label,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ],
                  ),
                ))
            .toList(),
        onChanged: (code) {
          if (code != null) {
            langProvider.setLocale(Locale(code));
          }
        },
      ),
    );
  }
}

class _LangOption {
  final String code;
  final String label;
  final String flag;

  const _LangOption(this.code, this.label, this.flag);
}
