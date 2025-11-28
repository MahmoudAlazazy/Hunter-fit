import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';

class ProfileDebugView extends StatefulWidget {
  const ProfileDebugView({super.key});

  @override
  State<ProfileDebugView> createState() => _ProfileDebugViewState();
}

class _ProfileDebugViewState extends State<ProfileDebugView> {
  Map<String, dynamic>? userProfile;
  String? currentUserId;
  String? error;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _debugLoadProfile();
  }

  Future<void> _debugLoadProfile() async {
    try {
      setState(() => isLoading = true);
      
      // Get current user ID
      currentUserId = SupabaseService.getCurrentUserId();
      print('Current User ID: $currentUserId');
      
      if (currentUserId == null) {
        setState(() {
          error = 'No user logged in';
          isLoading = false;
        });
        return;
      }
      
      // Try to get profile
      final profile = await SupabaseService.getCurrentUserProfile();
      print('Profile data: $profile');
      
      // Also try direct query
      final directProfile = await SupabaseService.getProfileById(currentUserId!);
      print('Direct profile data: $directProfile');
      
      setState(() {
        userProfile = profile;
        error = null;
        isLoading = false;
      });
      
    } catch (e, stackTrace) {
      print('Error loading profile: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Debug'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (error != null)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.red[100],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Error:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                    Text(error!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _debugLoadProfile,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.green[100],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Profile Data Found!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    const SizedBox(height: 16),
                    Text('User ID: $currentUserId'),
                    const SizedBox(height: 8),
                    if (userProfile != null) ...[
                      Text('Full Name: ${userProfile!['full_name'] ?? 'Not set'}'),
                      Text('Username: ${userProfile!['username'] ?? 'Not set'}'),
                      Text('Email: ${userProfile!['email'] ?? 'Not set'}'),
                      Text('Avatar: ${userProfile!['avatar_url'] ?? 'Not set'}'),
                    ] else
                      const Text('No profile data found'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _debugLoadProfile,
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
            
            // Test buttons
            const Text('Test Actions:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: () async {
                try {
                  final user = SupabaseService.client.auth.currentUser;
                  print('Current auth user: ${user?.id}, email: ${user?.email}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Auth user: ${user?.id ?? "None"}')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Check Auth Status'),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton(
              onPressed: () async {
                try {
                  final userId = SupabaseService.getCurrentUserId();
                  if (userId != null) {
                    // Try to create a test profile
                    final success = await SupabaseService.createUserProfile(
                      userId: userId,
                      username: 'test_user',
                      fullName: 'Test User',
                      email: 'test@example.com',
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Profile creation: $success')),
                    );
                    if (success) {
                      _debugLoadProfile();
                    }
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error creating profile: $e')),
                  );
                }
              },
              child: const Text('Create Test Profile'),
            ),
          ],
        ),
      ),
    );
  }
}