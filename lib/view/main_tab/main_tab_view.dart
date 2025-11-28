import 'package:fitness/common/colo_extension.dart';
import 'package:fitness/common_widget/tab_button.dart';
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
    var media = MediaQuery.of(context).size;
    
    // Responsive breakpoint
    final bool isSmallScreen = media.width < 600;
    final bool isTabletScreen = media.width >= 600 && media.width < 900;
    final bool isLargeScreen = media.width >= 900;
    
    return Scaffold(
      backgroundColor: TColor.white,
      body: PageStorage(bucket: pageBucket, child: currentTab),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: isSmallScreen ? 45 : 55,
        height: isSmallScreen ? 45 : 55,
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: TColor.primaryG,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(isSmallScreen ? 25 : 30),
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
            borderRadius: BorderRadius.circular(isSmallScreen ? 25 : 30),
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
              size: isSmallScreen ? 16 : 18,
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
          margin: const EdgeInsets.only(left: 3, right: 3, bottom: 3),
          height: isSmallScreen ? 65 : 70,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(isSmallScreen ? 25 : 30),
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
              SizedBox(width: isSmallScreen ? 35 : 40), // مساحة للزر الأوسط
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
    var media = MediaQuery.of(context).size;
    final bool isSmallScreen = media.width < 600;
    
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 30),
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
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 6 : 8, vertical: isSmallScreen ? 4 : 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF5B67F5) : Colors.transparent,
            borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Icon(
                  isSelected ? selectedIcon : icon,
                  color: isSelected ? Colors.white : Colors.grey[400],
                  size: isSmallScreen ? 16 : 18,
                ),
              ),
              if (isSelected) ...[
                SizedBox(width: isSmallScreen ? 2 : 3),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 8 : 10,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
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