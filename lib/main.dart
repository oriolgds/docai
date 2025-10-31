import 'package:flutter/material.dart';
import 'package:docai/l10n/app_localizations.dart';
import 'screens/chat2_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const DocAIApp());
}

class DocAIApp extends StatelessWidget {
  const DocAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Chat2Screen(),
    );
  }
}
