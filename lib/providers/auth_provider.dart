import 'package:flutter/foundation.dart';
import 'dart:io';
import '../core/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  Future<void> login(String email, String password) async {
    // This is a mock implementation
    // In a real app, you would call your authentication service
    _currentUser = User(
      id: '550e8400-e29b-41d4-a716-446655440000',
      name: 'John Doe',
      email: email,
      username: 'johndoe',
      photoUrl: 'https://via.placeholder.com/150',
    );
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }

  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();  }

  void updateCurrentUser(User updatedUser) {
    if (_currentUser != null && _currentUser!.id == updatedUser.id) {
      _currentUser = updatedUser;
      notifyListeners();
    }
  }

  // New method to update profile image
  Future<bool> updateProfileImage(File imageFile) async {
    try {
      if (_currentUser == null) return false;
      
      // In a real app, you would upload the image to your server/cloud storage
      // For now, we'll simulate the upload and update with a local path
      final imagePath = imageFile.path;
      
      // Update the current user with the new image
      final updatedUser = _currentUser!.copyWith(
        photoUrl: imagePath,
        avatarUrl: imagePath,
      );
      
      _currentUser = updatedUser;
      notifyListeners();
      
      // Simulate upload delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      return true;
    } catch (e) {
      print('Error updating profile image: $e');
      return false;
    }
  }

  // Method to update user profile data
  Future<bool> updateUserProfile({
    String? name,
    String? username,
    String? bio,
    Map<String, dynamic>? profileData,
  }) async {
    try {
      if (_currentUser == null) return false;
      
      // Merge existing profile data with new data
      final updatedProfileData = {
        ...?_currentUser!.profileData,
        if (bio != null) 'bio': bio,
        ...?profileData,
      };
      
      final updatedUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        username: username ?? _currentUser!.username,
        profileData: updatedProfileData,
      );
      
      _currentUser = updatedUser;
      notifyListeners();
      
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }
}