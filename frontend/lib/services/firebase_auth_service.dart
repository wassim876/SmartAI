// lib/services/firebase_auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  bool get isAuthenticated => _auth.currentUser != null;

  // ==========================================
  // SIGN UP WITH EMAIL & PASSWORD
  // ==========================================
  Future<UserModel?> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;
      
      // Update display name with error handling
      try {
        await user.updateDisplayName(username);
        await user.reload();
      } catch (_) {}

      // Create UserModel and save to Firestore
      final userModel = UserModel.fromFirebase(user);
      await _firestore.collection('users').doc(user.uid).set(
            userModel.toFirestoreForCreate(),
          );

      // Return from Firestore to get complete data
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return UserModel.fromFirestore(doc);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // ==========================================
  // SIGN IN WITH EMAIL & PASSWORD
  // ==========================================
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;
      
      // Check if user exists in Firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!doc.exists) {
        // Create user in Firestore if they don't exist
        final userModel = UserModel.fromFirebase(user);
        await _firestore.collection('users').doc(user.uid).set(
              userModel.toFirestoreForCreate(),
            );
        return userModel;
      }
      
      // Update last login
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Return from Firestore so isAdmin/isPremium are correctly loaded
      final updatedDoc = await _firestore.collection('users').doc(user.uid).get();
      return UserModel.fromFirestore(updatedDoc);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // ==========================================
  // SIGN IN WITH GOOGLE
  // ==========================================
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      // Check if user exists in Firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!doc.exists) {
        // Create new user using UserModel
        final userModel = UserModel.fromFirebase(user);
        await _firestore.collection('users').doc(user.uid).set(
              userModel.toFirestoreForCreate(),
            );
      } else {
        // Update last login
        await _firestore.collection('users').doc(user.uid).set({
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // Return fresh user data from Firestore
      final updatedDoc = await _firestore.collection('users').doc(user.uid).get();
      return UserModel.fromFirestore(updatedDoc);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  // ==========================================
  // SIGN IN WITH GITHUB
  // ==========================================
  Future<UserModel?> signInWithGitHub() async {
    try {
      final githubProvider = GithubAuthProvider();
      final userCredential = await _auth.signInWithPopup(githubProvider);
      final user = userCredential.user!;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!doc.exists) {
        // Create new user using UserModel
        final userModel = UserModel.fromFirebase(user);
        await _firestore.collection('users').doc(user.uid).set(
              userModel.toFirestoreForCreate(),
            );
      } else {
        // Update last login
        await _firestore.collection('users').doc(user.uid).set({
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // Return fresh user data from Firestore
      final updatedDoc = await _firestore.collection('users').doc(user.uid).get();
      return UserModel.fromFirestore(updatedDoc);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      throw Exception('GitHub sign in failed: $e');
    }
  }

  // ==========================================
  // SIGN OUT
  // ==========================================
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ==========================================
  // PASSWORD RESET
  // ==========================================
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found with this email address.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Please enter a valid email address.');
      } else if (e.code == 'too-many-requests') {
        throw Exception('Too many requests. Please try again later.');
      } else {
        throw Exception('Failed to send reset email: ${e.message}');
      }
    } catch (e) {
      throw Exception('An error occurred: ${e.toString()}');
    }
  }

  // ==========================================
  // UPDATE PROFILE
  // ==========================================
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
    bool clearPhoto = false,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    try {
      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      } else if (clearPhoto) {
        await user.updatePhotoURL(null);
      }

      // Update Firestore
      final Map<String, dynamic> updateData = {};
      if (displayName != null) updateData['displayName'] = displayName;
      if (photoURL != null) {
        updateData['photoURL'] = photoURL;
      } else if (clearPhoto) {
        updateData['photoURL'] = null;
      }
      
      if (updateData.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).set(
          updateData, 
          SetOptions(merge: true)
        );
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // ==========================================
  // CHANGE EMAIL
  // ==========================================
  Future<void> changeEmail(String newEmail) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    try {
      await user.verifyBeforeUpdateEmail(newEmail);
      await _firestore.collection('users').doc(user.uid).set({
        'email': newEmail,
      }, SetOptions(merge: true));
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to change email: $e');
    }
  }

  // ==========================================
  // CHANGE PASSWORD
  // ==========================================
  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    try {
      // Re-authenticate user first
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      
      // Then change password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  // ==========================================
  // REAUTHENTICATE USER
  // ==========================================
  Future<void> reauthenticate(String password) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      throw Exception('Reauthentication failed: $e');
    }
  }

  // ==========================================
  // DELETE ACCOUNT
  // ==========================================
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    try {
      // Delete user from Firestore first
      await _firestore.collection('users').doc(user.uid).delete();
      
      // Delete user data subcollections
      final subcollections = [
        'chatHistory',
        'imageAnalyses',
        'speechTranscriptions',
        'translations',
        'activities',
      ];
      
      for (final subcollection in subcollections) {
        try {
          final snapshot = await _firestore
              .collection('users')
              .doc(user.uid)
              .collection(subcollection)
              .get();
          
          if (snapshot.docs.isNotEmpty) {
            final batch = _firestore.batch();
            for (final doc in snapshot.docs) {
              batch.delete(doc.reference);
            }
            await batch.commit();
          }
        } catch (e) {
          // Continue with other subcollections
          debugPrint('Failed to delete subcollection $subcollection: $e');
        }
      }
      
      // Then delete from Firebase Auth
      await user.delete();
    } on FirebaseAuthException catch (e) {
      // If user needs recent authentication
      if (e.code == 'requires-recent-login') {
        throw Exception('Please reauthenticate before deleting your account.');
      }
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  // ==========================================
  // GET USER FROM FIRESTORE
  // ==========================================
  Future<UserModel?> getUserFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // ==========================================
  // REFRESH USER DATA
  // ==========================================
  Future<UserModel?> refreshUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      await user.reload();
      final refreshedUser = _auth.currentUser;
      if (refreshedUser == null) return null;
      
      final doc = await _firestore.collection('users').doc(refreshedUser.uid).get();
      if (!doc.exists) {
        // If user exists in Auth but not Firestore, create it
        final userModel = UserModel.fromFirebase(refreshedUser);
        await _firestore.collection('users').doc(refreshedUser.uid).set(
              userModel.toFirestoreForCreate(),
            );
        return userModel;
      }
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to refresh user data: $e');
    }
  }

  // ==========================================
  // ERROR HANDLING
  // ==========================================
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'requires-recent-login':
        return 'Please reauthenticate to perform this action.';
      case 'credential-already-in-use':
        return 'This credential is already linked to another account.';
      case 'invalid-credential':
        return 'Invalid credentials provided.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}