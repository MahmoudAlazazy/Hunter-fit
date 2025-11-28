import 'package:fitness/view/meal_planner/meal_planner_view.dart';
import 'package:fitness/view/workout_tracker/workout_tracker_view.dart';
import 'package:fitness/view/sleep_tracker/sleep_tracker_view.dart';
import 'package:flutter/material.dart';

class SelectView extends StatelessWidget {
  const SelectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildModernCard(
              context,
              title: "Workout Tracker",
              imagePath: "assets/bg.png",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WorkoutTrackerView()),
              ),
            ),
            const SizedBox(height: 22),
            buildModernCard(
              context,
              title: "Meal Planner",
              imagePath: "assets/meal.png",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MealPlannerView()),
              ),
            ),
            const SizedBox(height: 22),
            buildModernCard(
              context,
              title: "Sleep Tracker",
              imagePath: "assets/sleep.png",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SleepTrackerView()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildModernCard(
    BuildContext context, {
    required String title,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    final height = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        height: height * 0.22,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // الخلفية
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
              ),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.2),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),

              // النص
              Center(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
