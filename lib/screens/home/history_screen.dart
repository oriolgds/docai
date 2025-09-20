import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Docai'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_outlined,
              size: 64,
              color: Color(0xFFE0E0E0),
            ),
            SizedBox(height: 16),
            Text(
              'No hay historial',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF6B6B6B),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tus conversaciones aparecerán aquí',
              style: TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}