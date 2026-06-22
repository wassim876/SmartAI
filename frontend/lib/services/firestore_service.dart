// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==========================================
  // USER OPERATIONS
  // ==========================================

  Future<UserModel> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'username': user.displayName ?? user.email?.split('@').first ?? 'user',
          'email': user.email,
          'displayName': user.displayName ?? 'User',
          'photoURL': user.photoURL,
          'isPremium': false,
          'isActive': true,
          'isAdmin': false,
          'dailyMessagesUsed': 0,
          'dailyMessagesLimit': 50,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
        final newDoc = await _firestore.collection('users').doc(user.uid).get();
        return UserModel.fromFirestore(newDoc);
      } catch (_) {
        return UserModel.fromFirebase(user);
      }
    }

    return UserModel.fromFirestore(doc);
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    await _firestore.collection('users').doc(user.uid).set(data, SetOptions(merge: true));
  }

  Future<void> incrementDailyMessages() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'dailyMessagesUsed': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  Future<void> resetDailyUsage() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'dailyMessagesUsed': 0,
    }, SetOptions(merge: true));
  }

  // ==========================================
  // CHAT OPERATIONS
  // ==========================================

  Future<void> saveChatMessage({
    required String message,
    required String response,
    String model = 'gpt-3.5-turbo',
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    await _firestore.collection('chat_messages').add({
      'userId': user.uid,
      'message': message,
      'response': response,
      'model': model,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getChatHistory({int limit = 50}) {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    return _firestore
        .collection('chat_messages')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  // ==========================================
  // IMAGE ANALYSIS OPERATIONS
  // ==========================================

  Future<void> saveImageAnalysis({
    required String imageUrl,
    required String analysisResult,
    String imageType = 'general',
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    await _firestore.collection('image_analyses').add({
      'userId': user.uid,
      'imageUrl': imageUrl,
      'analysisResult': analysisResult,
      'imageType': imageType,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getImageAnalyses({int limit = 50}) {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    return _firestore
        .collection('image_analyses')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  // ==========================================
  // SPEECH TO TEXT OPERATIONS
  // ==========================================

  Future<void> saveSpeechTranscription({
    required String audioUrl,
    required String transcription,
    double duration = 0,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    await _firestore.collection('speech_transcriptions').add({
      'userId': user.uid,
      'audioUrl': audioUrl,
      'transcription': transcription,
      'duration': duration,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getSpeechTranscriptions({int limit = 50}) {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    return _firestore
        .collection('speech_transcriptions')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  // ==========================================
  // TRANSLATION OPERATIONS
  // ==========================================

  Future<void> saveTranslation({
    required String originalText,
    required String translatedText,
    required String sourceLang,
    required String targetLang,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    await _firestore.collection('translations').add({
      'userId': user.uid,
      'originalText': originalText,
      'translatedText': translatedText,
      'sourceLang': sourceLang,
      'targetLang': targetLang,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getTranslations({int limit = 50}) {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    return _firestore
        .collection('translations')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  // ==========================================
  // ACTIVITY OPERATIONS
  // ==========================================

  Future<void> logActivity(String action, {Map<String, dynamic>? details}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('user_activities').add({
      'userId': user.uid,
      'action': action,
      'details': details ?? {},
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getUserActivities({int limit = 50}) {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    return _firestore
        .collection('user_activities')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  // ==========================================
  // ADMIN OPERATIONS
  // ==========================================

  Future<List<UserModel>> getAllUsers() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists || doc.data()?['isAdmin'] != true) {
      throw Exception('Admin access required');
    }

    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  Future<void> adminUpdateUser(String userId, Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists || doc.data()?['isAdmin'] != true) {
      throw Exception('Admin access required');
    }

    await _firestore.collection('users').doc(userId).update(data);
  }

  Future<void> adminDeleteUser(String userId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists || doc.data()?['isAdmin'] != true) {
      throw Exception('Admin access required');
    }

    await _firestore.collection('users').doc(userId).delete();

    final collections = ['chat_messages', 'image_analyses', 'speech_transcriptions', 'translations', 'user_activities'];
    for (final collection in collections) {
      final snapshot = await _firestore
          .collection(collection)
          .where('userId', isEqualTo: userId)
          .get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }
  }
}