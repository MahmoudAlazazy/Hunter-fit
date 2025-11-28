import 'package:fitness/common/colo_extension.dart';
import 'package:fitness/view/main_tab/select_view.dart';
import 'package:flutter/material.dart';
import '../home/home_view.dart';
import '../photo_progress/photo_progress_view.dart';
import '../profile_view.dart';
import '../../social/social_media_page.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});
  
  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int selectTab = 0;
  final PageStorageBucket pageBucket = PageStorageBucket(); 
  Widget currentTab = const HomeView();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: PageStorage(bucket: pageBucket, child: currentTab),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: 70,
        height: 70,
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: TColor.primaryG,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: TColor.primaryG[0].withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(35),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SocialMediaPage(),
                ),
              );
            },
            child: Icon(
              Icons.groups ,
              color: TColor.white,
              size: 32,
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.transparent,
        elevation: 0,
        child: Container(
          margin: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                index: 0,
                label: 'Home',
              ),
              _buildNavItem(
                icon: Icons.insights,
                selectedIcon: Icons.insights ,
                index: 1,
                label: 'Activity',
              ),
              const SizedBox(width: 60), // مساحة للزر الأوسط
              _buildNavItem(
                icon: Icons.photo_camera,
                selectedIcon: Icons.photo_camera,
                index: 2,
                label: 'Camera',
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                index: 3,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required int index,
    required String label,
  }) {
    final isSelected = selectTab == index;
    
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(36),
        onTap: () {
          setState(() {
            selectTab = index;
            switch (index) {
              case 0:
                currentTab = const HomeView();
                break;
              case 1:
                currentTab = const SelectView();
                break;
              case 2:
                currentTab = const PhotoProgressView();
                break;
              case 3:
                currentTab = const ProfileView();
                break;
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF5B67F5) : Colors.transparent,
            borderRadius: BorderRadius.circular(36),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected ? Colors.white : Colors.grey[400],
                size: 24,
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}