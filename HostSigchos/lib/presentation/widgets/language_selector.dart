import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/l10n/app_localizations.dart';
import '../viewmodels/locale_viewmodel.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key, this.iconColor = Colors.white});

  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeVm = context.watch<LocaleViewModel>();
    final isSpanish = localeVm.locale.languageCode == 'es';

    return PopupMenuButton<String>(
      icon: Icon(Icons.language, color: iconColor),
      onSelected: (value) {
        if (value == 'es') {
          context.read<LocaleViewModel>().setLocale(const Locale('es'));
        } else {
          context.read<LocaleViewModel>().setLocale(const Locale('en'));
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'es',
          child: Row(
            children: [
              Text(l10n.spanish),
              if (isSpanish) ...[
                const Spacer(),
                const Icon(Icons.check, size: 16, color: Colors.green),
              ]
            ],
          ),
        ),
        PopupMenuItem(
          value: 'en',
          child: Row(
            children: [
              Text(l10n.english),
              if (!isSpanish) ...[
                const Spacer(),
                const Icon(Icons.check, size: 16, color: Colors.green),
              ]
            ],
          ),
        ),
      ],
    );
  }
}
