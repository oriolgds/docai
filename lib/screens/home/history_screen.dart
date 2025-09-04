import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockHistory = [
      HistoryItem(
        title: 'Headache symptoms',
        preview: 'I\'ve been having persistent headaches...',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      HistoryItem(
        title: 'Medication side effects',
        preview: 'What are the side effects of aspirin?',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      HistoryItem(
        title: 'Natural remedies for cold',
        preview: 'Looking for natural ways to treat common cold...',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: mockHistory.isEmpty
          ? const Center(
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
                    'No chat history yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF6B6B6B),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your conversations will appear here',
                    style: TextStyle(
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mockHistory.length,
              itemBuilder: (context, index) {
                final item = mockHistory[index];
                return _buildHistoryCard(context, item);
              },
            ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, HistoryItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.chat_outlined,
            color: Colors.black,
            size: 20,
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              item.preview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF6B6B6B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatTimestamp(item.timestamp),
              style: const TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert_outlined),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 20),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          // Navigate to chat with this history
        },
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

class HistoryItem {
  final String title;
  final String preview;
  final DateTime timestamp;

  HistoryItem({
    required this.title,
    required this.preview,
    required this.timestamp,
  });
}