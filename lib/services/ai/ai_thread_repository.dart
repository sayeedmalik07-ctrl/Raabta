import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/screens/ai_chat/models/ai_chat_message.dart';
import 'package:raabta/screens/ai_chat/models/ai_chat_thread.dart';

/// Persists chat threads server-side — `users/{uid}/ai_threads/{threadId}`.
class AiThreadRepository {
  AiThreadRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  static const defaultThreadId = 'default';

  CollectionReference<Map<String, dynamic>> _threads(String uid) =>
      _db.collection('users').doc(uid).collection('ai_threads');

  Future<List<AiChatThreadSummary>> listThreads(String uid) async {
    final snap = await _threads(uid)
        .orderBy('updatedAt', descending: true)
        .limit(30)
        .get();
    return snap.docs
        .map((doc) => AiChatThreadSummary.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  Future<String> createThread(
    String uid, {
    String? title,
    String? contextSource,
    String? locale,
  }) async {
    final id = 'thread_${DateTime.now().millisecondsSinceEpoch}';
    await _threads(uid).doc(id).set({
      'title': title ?? 'New chat',
      'messages': const [],
      'contextSource': contextSource,
      'locale': locale,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return id;
  }

  Future<void> renameThread(String uid, String threadId, String title) async {
    if (uid.isEmpty || threadId.isEmpty || title.trim().isEmpty) return;
    await _threads(uid).doc(threadId).set({
      'title': title.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteThread(String uid, String threadId) async {
    if (uid.isEmpty || threadId.isEmpty) return;
    await _threads(uid).doc(threadId).delete();
  }

  Future<void> deleteAllThreads(String uid) async {
    if (uid.isEmpty) return;
    final snap = await _threads(uid).get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  Future<(int threads, int messages)> countThreadsAndMessages(String uid) async {
    if (uid.isEmpty) return (0, 0);
    final snap = await _threads(uid).get();
    var messages = 0;
    for (final doc in snap.docs) {
      final raw = doc.data()['messages'] as List<dynamic>? ?? [];
      messages += raw.length;
    }
    return (snap.size, messages);
  }

  Future<List<AiChatMessage>> loadMessages(String uid, {String? threadId}) async {
    final id = threadId ?? defaultThreadId;
    final snap = await _threads(uid).doc(id).get();
    if (!snap.exists) return const [];
    final raw = snap.data()?['messages'] as List<dynamic>? ?? [];
    return raw
        .map((e) => AiChatMessage.fromJson(Map<String, dynamic>.from(e as Map)))
        .where((m) => !m.isStreaming)
        .toList();
  }

  Future<void> saveMessages(
    String uid,
    List<AiChatMessage> messages, {
    String? threadId,
    String? locale,
    String? contextSource,
    String? rollingSummary,
  }) async {
    if (uid.isEmpty) return;
    final id = threadId ?? defaultThreadId;
    final persistable = messages.where((m) => !m.isStreaming).toList();
    final title = _deriveTitle(persistable);
    final payload = <String, dynamic>{
      'messages': persistable.map((m) => m.toJson()).toList(),
      'title': title,
      'locale': locale,
      if (contextSource != null) 'contextSource': contextSource,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (rollingSummary != null) {
      payload['rollingSummary'] = rollingSummary;
    }
    await _threads(uid).doc(id).set(payload, SetOptions(merge: true));
  }

  Future<String?> loadRollingSummary(String uid, {String? threadId}) async {
    final id = threadId ?? defaultThreadId;
    final snap = await _threads(uid).doc(id).get();
    if (!snap.exists) return null;
    return snap.data()?['rollingSummary'] as String?;
  }

  String _deriveTitle(List<AiChatMessage> messages) {
    for (final m in messages) {
      if (m.isUser && m.text.trim().isNotEmpty) {
        final t = m.text.trim();
        return t.length > 48 ? '${t.substring(0, 48)}…' : t;
      }
    }
    return 'Raabta AI';
  }
}
