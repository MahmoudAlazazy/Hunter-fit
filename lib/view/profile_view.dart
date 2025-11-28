import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../common/colo_extension.dart';
import '../../core/services/supabase_service.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool lockScreenEnabled = false;
  Map<String, dynamic>? userProfile;
  bool isLoading = true;
  bool isUploadingImage = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => isLoading = true);
    try {
      print('Loading user profile...'); // Debug log
      final profile = await SupabaseService.getCurrentUserProfile();
      print('Profile loaded: $profile'); // Debug log
      
      if (profile == null) {
        print('No profile found, attempting to create one...');
        // Try to create profile from auth data
        final user = SupabaseService.client.auth.currentUser;
        if (user != null) {
          print('Creating profile for user: ${user.id}');
          final success = await SupabaseService.createUserProfile(
            userId: user.id,
            username: user.email?.split('@')[0] ?? 'user_${user.id.substring(0, 8)}',
            fullName: user.userMetadata?['full_name'] ?? user.email?.split('@')[0] ?? 'User',
            email: user.email,
          );
          
          if (success) {
            print('Profile created successfully, reloading...');
            // Reload profile after creation
            final newProfile = await SupabaseService.getCurrentUserProfile();
            if (mounted) {
              setState(() {
                userProfile = newProfile;
                isLoading = false;
              });
            }
          } else {
            print('Failed to create profile');
            if (mounted) {
              setState(() => isLoading = false);
            }
          }
        } else {
          print('No authenticated user found');
          if (mounted) {
            setState(() => isLoading = false);
          }
        }
      } else {
        if (mounted) {
          setState(() {
            userProfile = profile;
            isLoading = false;
          });
        }
      }
    } catch (e, stackTrace) {
      print('Error loading profile: $e'); // Debug log
      print('Stack trace: $stackTrace');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        await _uploadProfilePicture();
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

  Future<void> _uploadProfilePicture() async {
    if (_selectedImage == null || userProfile == null) return;

    setState(() {
      isUploadingImage = true;
    });

    try {
      final userId = SupabaseService.getCurrentUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
        return;
      }

      // Upload image to storage
      final imageUrl = await SupabaseService.uploadProfilePicture(
        _selectedImage!.path,
        userId,
      );

      if (imageUrl != null) {
        // Update profile with new image URL
        final success = await SupabaseService.updateProfilePicture(
          userId,
          imageUrl,
        );

        if (success) {
          // Reload profile to show new image
          await _loadUserProfile();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile picture')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image')),
        );
      }
    } catch (e) {
      print('Error uploading profile picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    } finally {
      setState(() {
        isUploadingImage = false;
        _selectedImage = null;
      });
    }
  }

  Future<void> _showImageOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Upload New Picture'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              if (userProfile?['avatar_url'] != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Picture', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _showRemoveConfirmation();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showRemoveConfirmation() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Profile Picture'),
          content: const Text('Are you sure you want to remove your profile picture?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _removeProfilePicture();
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeProfilePicture() async {
    final userId = SupabaseService.getCurrentUserId();
    if (userId == null) return;

    setState(() {
      isUploadingImage = true;
    });

    try {
      final success = await SupabaseService.deleteProfilePicture(userId);
      if (success) {
        await _loadUserProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture removed')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove profile picture')),
        );
      }
    } catch (e) {
      print('Error removing profile picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing image: $e')),
      );
    } finally {
      setState(() {
        isUploadingImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : userProfile == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No profile found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please log in to view your profile',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Picture
                      Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[300],
                              border: Border.all(
                                color: TColor.primaryColor1,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: userProfile?['avatar_url'] != null
                                  ? Image.network(
                                      userProfile!['avatar_url'],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return _buildDefaultAvatar();
                                      },
                                    )
                                  : _buildDefaultAvatar(),
                            ),
                          ),
                          // Upload button overlay
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: isUploadingImage ? null : _showImageOptions,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: TColor.primaryColor1,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: isUploadingImage
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.camera_alt,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Name
                      Text(
                        userProfile?['full_name'] ?? "User Name",
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Username
                      Text(
                        "@${userProfile?['username'] ?? 'username'}",
                        style: TextStyle(
                          color: TColor.gray,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Email
                      Text(
                        userProfile?['email'] ?? "user@example.com",
                        style: TextStyle(
                          color: TColor.gray,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Steps Counter Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: TColor.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              "7421",
                              style: TextStyle(
                                color: TColor.black,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Steps today",
                              style: TextStyle(
                                color: TColor.gray,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Menu Items
                      _buildMenuItem(
                        icon: Icons.people,
                        title: "Friends",
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.bar_chart,
                        title: "Statistics",
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.location_on,
                        title: "Locations",
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.fitness_center,
                        title: "Strength log",
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.lock,
                        title: "Lock Screen",
                        onTap: () {
                          setState(() {
                            lockScreenEnabled = !lockScreenEnabled;
                          });
                        },
                        showToggle: true,
                        toggleValue: lockScreenEnabled,
                      ),
                    ],
                  ),
                ),
              ));
  }

  Widget _buildDefaultAvatar() {
    return Icon(
      Icons.person,
      size: 50,
      color: Colors.grey[600],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showToggle = false,
    bool toggleValue = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: TColor.primaryColor1.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: TColor.primaryColor1,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: TColor.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: showToggle
            ? Switch(
                value: toggleValue,
                onChanged: (value) => onTap(),
                activeThumbColor: TColor.primaryColor1,
              )
            : Icon(
                Icons.arrow_forward_ios,
                color: TColor.gray,
                size: 16,
              ),
        onTap: onTap,
      ),
    );
  }

}

