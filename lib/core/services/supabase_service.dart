import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

// Define ResendType enum locally if not available
enum _ResendType { signup, recovery }

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  static SupabaseClient get client => _client;

  static Future<User?> getCurrentUser() async {
    return _client.auth.currentUser;
  }

  static String? getCurrentUserId() {
    return _client.auth.currentUser?.id;
  }

  static bool isAuthenticated() {
    return _client.auth.currentUser != null;
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static Future<AuthResponse> signInWithEmail({required String email, required String password}) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<AuthResponse> signUpWithEmail({required String email, required String password, Map<String, dynamic>? data}) async {
    return await _client.auth.signUp(email: email, password: password, data: data);
  }

  static Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  static Future<void> resendEmailConfirmation() async {
    final user = _client.auth.currentUser;
    if (user != null && user.email != null) {
      try {
        await _client.auth.resetPasswordForEmail(user.email!);
      } catch (e) {
        // Try alternative method
        await _client.auth.signUp(email: user.email!, password: 'temp');
      }
    }
  }

  // Profile Picture Methods
  static Future<String?> uploadProfilePicture(String filePath, String userId) async {
    try {
      print('Starting profile picture upload for user: $userId');
      print('File path: $filePath');
      
      final fileName = 'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$userId/$fileName';
      
      print('Upload path: $path');
      
      Uint8List fileBytes;
      
      // Handle blob URLs (web) vs file paths (mobile/desktop)
      if (filePath.startsWith('blob:http')) {
        print('Detected blob URL, converting to bytes...');
        // For web blob URLs, we need to read the bytes differently
        final uri = Uri.parse(filePath);
        fileBytes = await http.readBytes(uri);
        print('Blob converted to bytes, length: ${fileBytes.length}');
      } else {
        // For regular file paths
        final file = File(filePath);
        if (!await file.exists()) {
          print('File does not exist at path: $filePath');
          return null;
        }
        
        final fileSize = await file.length();
        print('File size: $fileSize bytes');
        
        fileBytes = await file.readAsBytes();
        print('File bytes length: ${fileBytes.length}');
      }
      
      // Upload to profile_pictures bucket using bytes
      await _client.storage.from('profile_pictures').uploadBinary(
        path, 
        fileBytes,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: true,
        ),
      );
      
      final response = _client.storage.from('profile_pictures').getPublicUrl(path);
      print('Upload successful, public URL: $response');
      return response;
    } catch (e) {
      print('Error uploading profile picture: $e');
      print('Error type: ${e.runtimeType}');
      return null;
    }
  }

  static Future<bool> updateProfilePicture(String userId, String imageUrl) async {
    try {
      await _client.from('profiles').update({
        'avatar_url': imageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      return true;
    } catch (e) {
      print('Error updating profile picture: $e');
      return false;
    }
  }

  static Future<bool> deleteProfilePicture(String userId) async {
    try {
      await _client.from('profiles').update({
        'avatar_url': null,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      return true;
    } catch (e) {
      print('Error deleting profile picture: $e');
      return false;
    }
  }

  static Future<void> resendEmailConfirmationForEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      // Try alternative method
      await _client.auth.signUp(email: email, password: 'temp');
    }
  }

  static Future<void> signInWithProvider(OAuthProvider provider) async {
    await _client.auth.signInWithOAuth(provider);
  }

  static Future<void> updateProfileIfExists({required String userId, String? username, String? fullName}) async {
    final updatePayload = <String, dynamic>{};
    if (username != null) updatePayload['username'] = username;
    if (fullName != null) updatePayload['full_name'] = fullName;
    if (updatePayload.isEmpty) return;
    try {
      await _client
          .from('profiles')
          .update(updatePayload)
          .eq('id', userId);
    } catch (_) {}
  }

  static Future<Map<String, dynamic>?> getProfileById(String userId) async {
    try {
      final res = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .limit(1);
      
      if (res.isEmpty) return null;
      return res.first;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> updateProfileFields(String userId, Map<String, dynamic> fields) async {
    try {
      await _client
          .from('profiles')
          .update(fields)
          .eq('id', userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> setUserGoal(String userId, String goal) async {
    try {
      await _client
          .from('profiles')
          .update({'goal': goal})
          .eq('id', userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> createUserProfile({
    required String userId,
    required String username,
    required String fullName,
    String? email,
  }) async {
    try {
      print('Creating profile for user: $userId');
      print('  username: $username');
      print('  fullName: $fullName');
      print('  email: $email');
      
      // Validate input data
      if (userId.isEmpty) {
        print('Error: userId is empty');
        return false;
      }
      if (username.isEmpty) {
        print('Error: username is empty');
        return false;
      }
      if (fullName.isEmpty) {
        print('Error: fullName is empty');
        return false;
      }
      
      final data = {
        'id': userId,
        'username': username,
        'full_name': fullName,
        'email': email,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      print('Inserting data: $data');
      
      await _client.from('profiles').insert(data);
      print('Profile created successfully');
      return true;
    } catch (e) {
      print('Error creating profile: $e');
      if (e.toString().contains('violates row-level security')) {
        print('RLS Policy violation detected! Make sure RLS policies allow INSERT for this user.');
      }
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final userId = getCurrentUserId();
    if (userId == null) return null;
    return await getProfileById(userId);
  }

  // Progress Photos Methods
  static Future<String?> uploadProgressPhoto(String filePath, String userId) async {
    try {
      print('Starting progress photo upload for user: $userId');
      print('File path: $filePath');
      
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$userId/$fileName'; // Use userId/filename structure to match RLS policy
      
      print('Upload path: $path');
      
      Uint8List fileBytes;
      
      // Handle blob URLs (web) vs file paths (mobile/desktop)
      if (filePath.startsWith('blob:http')) {
        print('Detected blob URL, converting to bytes...');
        final uri = Uri.parse(filePath);
        fileBytes = await http.readBytes(uri);
        print('Blob converted to bytes, length: ${fileBytes.length}');
      } else {
        // For regular file paths
        final file = File(filePath);
        if (!await file.exists()) {
          print('File does not exist at path: $filePath');
          return null;
        }
        
        final fileSize = await file.length();
        print('File size: $fileSize bytes');
        
        fileBytes = await file.readAsBytes();
        print('File bytes length: ${fileBytes.length}');
      }
      
      // Upload to progress_photos bucket using bytes
      await _client.storage.from('progress_photos').uploadBinary(
        path, 
        fileBytes,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: true,
        ),
      );
      
      // Try to get signed URL instead of public URL to bypass RLS issues
      String? response;
      try {
        response = _client.storage.from('progress_photos').getPublicUrl(path);
        print('Public URL: $response');
      } catch (e) {
        print('Error getting public URL: $e');
        // Fallback to signed URL
        try {
          final signedUrl = await _client.storage.from('progress_photos').createSignedUrl(path, 31536000); // 1 year expiry
          response = signedUrl;
          print('Signed URL: $response');
        } catch (e2) {
          print('Error creating signed URL: $e2');
          return null;
        }
      }
      return response;
    } catch (e) {
      print('Error uploading photo: $e');
      print('Error type: ${e.runtimeType}');
      if (e.toString().contains('violates row-level security')) {
        print('RLS Policy violation detected! Check storage policies for progress_photos bucket.');
      }
      return null;
    }
  }

  static Future<bool> saveProgressPhoto({
    required String userId,
    required String photoUrl,
    required String photoType,
    String? notes,
  }) async {
    try {
      await _client.from('progress_photos').insert({
        'user_id': userId,
        'date': DateTime.now().toIso8601String().split('T')[0], // Only date part
        'photo_url': photoUrl,
        'photo_type': photoType,
        'notes': notes,
        // Remove created_at as it's auto-generated by database
      });
      return true;
    } catch (e) {
      print('Error saving photo record: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getProgressPhotos(String userId) async {
    try {
      final response = await _client
          .from('progress_photos')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching progress photos: $e');
      return [];
    }
  }

  static Future<bool> deleteProgressPhoto(String photoId) async {
    try {
      await _client.from('progress_photos').delete().eq('id', photoId);
      return true;
    } catch (e) {
      print('Error deleting photo: $e');
      return false;
    }
  }

  static Future<String?> getProgressPhotoUrl(String photoUrl) async {
    try {
      print('Converting URL to signed URL: $photoUrl');
      
      // Extract path from the public URL
      final uri = Uri.parse(photoUrl);
      final pathSegments = uri.pathSegments;
      
      // Find the index where 'progress_photos' appears
      int progressPhotosIndex = pathSegments.indexOf('progress_photos');
      if (progressPhotosIndex != -1 && progressPhotosIndex + 1 < pathSegments.length) {
        // Get the path after 'progress_photos'
        final path = pathSegments.sublist(progressPhotosIndex + 1).join('/');
        print('Extracted path: $path');
        
        // Try to create a signed URL
        final signedUrl = await _client.storage.from('progress_photos').createSignedUrl(path, 31536000); // 1 year expiry
        print('Generated signed URL for path: $path');
        print('Signed URL: $signedUrl');
        return signedUrl;
      }
      
      // Fallback to original URL if we can't extract path
      print('Could not extract path from URL, returning original: $photoUrl');
      return photoUrl;
    } catch (e) {
      print('Error creating signed URL for existing photo: $e');
      return photoUrl; // Return original URL as fallback
    }
  }

  static Future<DateTime?> getNextReminderDate() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) return null;
      
      final response = await _client
          .from('progress_photos')
          .select('date')
          .eq('user_id', userId)
          .order('date', ascending: false)
          .limit(1);
      
      if (response.isEmpty) {
        return DateTime.now().add(const Duration(days: 7));
      }
      
      final lastPhotoDate = DateTime.parse(response[0]['date']);
      return lastPhotoDate.add(const Duration(days: 7));
    } catch (e) {
      return DateTime.now().add(const Duration(days: 7));
    }
  }
}
