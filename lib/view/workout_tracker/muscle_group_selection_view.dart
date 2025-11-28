import 'package:fitness/common/colo_extension.dart';
import 'package:fitness/common_widget/round_button.dart';
import 'package:fitness/core/models/muscle_group_model.dart';
import 'package:fitness/core/services/muscle_group_service.dart';
import 'package:flutter/material.dart';

import 'exercise_list_view.dart';

class MuscleGroupSelectionView extends StatefulWidget {
  const MuscleGroupSelectionView({super.key});

  @override
  State<MuscleGroupSelectionView> createState() => _MuscleGroupSelectionViewState();
}

class _MuscleGroupSelectionViewState extends State<MuscleGroupSelectionView> {
  List<MuscleGroupModel> muscleGroups = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMuscleGroups();
  }

  Future<void> _loadMuscleGroups() async {
    try {
      final groups = await MuscleGroupService.getMuscleGroups();
      setState(() {
        muscleGroups = groups;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading muscle groups: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(10)),
            child: Image.asset(
              "assets/img/closed_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Select Muscle Group",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: TColor.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : muscleGroups.isEmpty
              ? Center(
                  child: Text(
                    "No muscle groups found",
                    style: TextStyle(color: TColor.gray, fontSize: 14),
                  ),
                )
              : SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "What do you want to train?",
                          style: TextStyle(
                              color: TColor.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 20),
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: muscleGroups.length,
                          itemBuilder: (context, index) {
                            var muscleGroup = muscleGroups[index];
                            return _buildMuscleGroupCard(muscleGroup, media);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildMuscleGroupCard(MuscleGroupModel muscleGroup, Size media) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseListView(muscleGroup: muscleGroup),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              TColor.primaryColor2.withValues(alpha: 0.3),
              TColor.primaryColor1.withValues(alpha: 0.3)
            ]),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      muscleGroup.displayName,
                      style: TextStyle(
                          color: TColor.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${muscleGroup.exerciseCount} Exercises",
                      style: TextStyle(
                        color: TColor.gray,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: 100,
                      height: 30,
                      child: RoundButton(
                        title: "Select",
                        fontSize: 10,
                        type: RoundButtonType.textGradient,
                        elevation: 0.05,
                        fontWeight: FontWeight.w400,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExerciseListView(muscleGroup: muscleGroup),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.54),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(
                      muscleGroup.imagePath ?? "assets/img/what_1.png",
                      width: 90,
                      height: 90,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}