import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveReport({
    required String messageId,
    required String messageContent,
    required String reason,
    required String userId, // Ideally from auth, or anonymous ID
    String? userEmail,
  }) async {
    try {
      await _firestore.collection('reports').add({
        'messageId': messageId,
        'messageContent': messageContent,
        'reason': reason,
        'reportedAt': FieldValue.serverTimestamp(),
        'userId': userId,
        'userEmail': userEmail,
        'status': 'pending', // pending, reviewed, resolved
        'platform': defaultTargetPlatform.toString(),
      });
    } catch (e) {
      debugPrint('Error saving report to Firestore: $e');
      rethrow;
    }
  }
}
