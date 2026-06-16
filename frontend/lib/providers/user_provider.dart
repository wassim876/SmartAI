// lib/providers/user_provider.dart
import 'package:flutter/material.dart';
import 'dart:typed_data';

class UserProvider extends ChangeNotifier {
  String _userName = 'John Doe';
  String _userRole = 'Administrator';
  Uint8List? _profileImageBytes;  

  String get userName => _userName;
  String get userRole => _userRole;
  Uint8List? get profileImageBytes => _profileImageBytes;

  void updateUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  void updateUserRole(String role) {
    _userRole = role;
    notifyListeners();
  }

  void updateProfileImage(Uint8List? imageBytes) {
    _profileImageBytes = imageBytes;
    notifyListeners();
  }

  // For testing - reset to default
  void resetToDefault() {
    _userName = 'John Doe';
    _userRole = 'Administrator';
    _profileImageBytes = null;
    notifyListeners();
  }
}