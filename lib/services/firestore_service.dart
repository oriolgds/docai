import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userId;

  Future<String> getUserId() async {
    if (_userId != null) return _userId!;

    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('device_user_id');

    if (_userId == null) {
      _userId = const Uuid().v4();
      await prefs.setString('device_user_id', _userId!);
    }

    return _userId!;
  }

  Future<void> saveReport({
    required String messageId,
    required String messageContent,
    required String reason,
    String? userEmail,
  }) async {
    try {
      final userId = await getUserId();
      await _firestore.collection('reports').add({
        'messageId': messageId,
        'messageContent': messageContent,
        'reason': reason,
        'reportedAt': FieldValue.serverTimestamp(),
        'userId': userId,
        'userEmail': userEmail,
        'status': 'pending', // pending, solved, refused
        'platform': defaultTargetPlatform.toString(),
      });
    } catch (e) {
      debugPrint('Error saving report to Firestore: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot> getReports() async* {
    final userId = await getUserId();
    yield* _firestore
        .collection('reports')
        .where('userId', isEqualTo: userId)
        .orderBy('reportedAt', descending: true)
        .snapshots();
  }
}
