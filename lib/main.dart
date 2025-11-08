import 'package:flutter/material.dart';
import 'package:docai/l10n/app_localizations.dart';
import 'package:docai/state/locale_scope.dart';
import 'screens/chat2_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localeController = LocaleController();
  await localeController.loadSavedLocale();

  runApp(
    LocaleScope(
      controller: localeController,
      child: const DocAIApp(),
    ),
  );
}

class DocAIApp extends StatelessWidget {
  const DocAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeController = LocaleScope.of(context);

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      locale: localeController.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Chat2Screen(),
    );
  }
}
