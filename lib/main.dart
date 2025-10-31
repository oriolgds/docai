import 'package:flutter/material.dart';
import 'screens/chat2_screen.dart';

void main() {
  runApp(const DocAIApp());
}

class DocAIApp extends StatelessWidget {
  const DocAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const Chat2Screen(),
    );
  }
}
