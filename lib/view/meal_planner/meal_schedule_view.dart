import 'package:calendar_agenda/calendar_agenda.dart';
import 'package:flutter/material.dart';

import '../../common/colo_extension.dart';
import '../../common_widget/meal_food_schedule_row.dart';
import '../../common_widget/nutritions_row.dart';
import '../../core/services/fitness_data_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';

class MealScheduleView extends StatefulWidget {
  const MealScheduleView({super.key});

  @override
  State<MealScheduleView> createState() => _MealScheduleViewState();
}

class _MealScheduleViewState extends State<MealScheduleView> {
  final CalendarAgendaController _calendarAgendaControllerAppBar =
      CalendarAgendaController();

  late DateTime _selectedDateAppBBar;

  List breakfastArr = [];
  List lunchArr = [];
  List snacksArr = [];
  List dinnerArr = [];
  bool _showInputCard = false;
  String _inputMealType = 'breakfast';
  final TextEditingController _mealNameController = TextEditingController();
  final TextEditingController _mealCaloriesController = TextEditingController();
  TimeOfDay _mealTime = TimeOfDay.now();

  List nutritionArr = [];

  @override
  void initState() {
    super.initState();
    _selectedDateAppBBar = DateTime.now();
    _loadDataForDate(_selectedDateAppBBar);
  }

  Future<void> _loadDataForDate(DateTime date) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final meals = await FitnessDataService.getMealsForDate(user.id, date);
    String fmtTime(dynamic servedAt) {
      try {
        final dt = DateTime.parse(servedAt as String);
        final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        final ampm = dt.hour >= 12 ? 'pm' : 'am';
        final mm = dt.minute.toString().padLeft(2, '0');
        return '${h.toString().padLeft(2, '0')}:$mm$ampm';
      } catch (_) {
        return '';
      }
    }
    List<Map<String, dynamic>> toDisplay(List<Map<String, dynamic>> list) => list.map((m) => {
      'name': m['name'] ?? '-',
      'time': fmtTime(m['served_at'] ?? DateTime(date.year, date.month, date.day).toIso8601String()),
      'image': m['image_url'] ?? 'assets/img/meal.png',
    }).toList();
    breakfastArr = toDisplay(meals.where((m) => m['meal_type'] == 'breakfast').toList());
    lunchArr = toDisplay(meals.where((m) => m['meal_type'] == 'lunch').toList());
    snacksArr = toDisplay(meals.where((m) => m['meal_type'] == 'snack').toList());
    dinnerArr = toDisplay(meals.where((m) => m['meal_type'] == 'dinner').toList());
    final nutrition = await FitnessDataService.getNutritionForDate(user.id, date);
    final caloriesConsumed = (nutrition?.caloriesConsumed ?? 0).toStringAsFixed(0);
    final caloriesTarget = (nutrition?.caloriesTarget ?? 2000).toStringAsFixed(0);
    nutritionArr = [
      {
        "title": "Calories",
        "image": "assets/img/burn.png",
        "unit_name": "kCal",
        "value": caloriesConsumed,
        "max_value": caloriesTarget,
      },
    ];
    if (mounted) setState(() {});
  }

  void _toggleAddMealCard({String? presetMealType}) {
    setState(() {
      _showInputCard = true;
      _inputMealType = presetMealType ?? 'breakfast';
      _mealNameController.clear();
      _mealCaloriesController.clear();
      _mealTime = TimeOfDay.now();
    });
  }

  Future<void> _pickMealTime() async {
    final picked = await showTimePicker(context: context, initialTime: _mealTime);
    if (picked != null) setState(() => _mealTime = picked);
  }

  Widget _buildAddMealCard() {
    if (!_showInputCard) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: TColor.lightGray, borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _inputMealType,
                      items: const [
                        DropdownMenuItem(value: 'breakfast', child: Text('Breakfast')),
                        DropdownMenuItem(value: 'lunch', child: Text('Lunch')),
                        DropdownMenuItem(value: 'dinner', child: Text('Dinner')),
                        DropdownMenuItem(value: 'snack', child: Text('Snack')),
                      ],
                      onChanged: (v) { if (v != null) setState(() => _inputMealType = v); },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: _pickMealTime,
                  child: Text('${_mealTime.hour.toString().padLeft(2,'0')}:${_mealTime.minute.toString().padLeft(2,'0')}'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _mealNameController,
              decoration: const InputDecoration(labelText: 'Meal name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _mealCaloriesController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9\. ]'))],
              decoration: const InputDecoration(labelText: 'Calories (kCal)'),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => setState(() => _showInputCard = false),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(gradient: LinearGradient(colors: TColor.primaryG), borderRadius: BorderRadius.circular(10)),
                  child: MaterialButton(
                    onPressed: () async {
                      final user = Supabase.instance.client.auth.currentUser;
                      if (user == null) return;
                      final name = _mealNameController.text.trim();
                      final cals = double.tryParse(_mealCaloriesController.text.replaceAll(',', '.')) ?? 0;
                      if (name.isEmpty || cals <= 0) return;
                      final dt = DateTime(_selectedDateAppBBar.year, _selectedDateAppBBar.month, _selectedDateAppBBar.day, _mealTime.hour, _mealTime.minute);
                      await FitnessDataService.addMealWithCalories(
                        userId: user.id,
                        mealType: _inputMealType,
                        name: name,
                        servedAt: dt,
                        caloriesKcal: cals,
                      );
                      await _loadDataForDate(_selectedDateAppBBar);
                      if (mounted) setState(() => _showInputCard = false);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meal added')));
                    },
                    color: Colors.transparent,
                    elevation: 0,
                    textColor: Colors.white,
                    child: const Text('Add Meal'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
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
              "assets/img/black_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Meal  Schedule",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: () => _toggleAddMealCard(),
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: TColor.lightGray,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.add, size: 18, color: Colors.black),
            ),
          ),
          InkWell(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: TColor.lightGray,
                  borderRadius: BorderRadius.circular(10)),
              child: Image.asset(
                "assets/img/more_btn.png",
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      backgroundColor: TColor.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalendarAgenda(
            controller: _calendarAgendaControllerAppBar,
            appbar: false,
            selectedDayPosition: SelectedDayPosition.center,
            leading: IconButton(
                onPressed: () {},
                icon: Image.asset(
                  "assets/img/ArrowLeft.png",
                  width: 15,
                  height: 15,
                )),
            training: IconButton(
                onPressed: () {},
                icon: Image.asset(
                  "assets/img/ArrowRight.png",
                  width: 15,
                  height: 15,
                )),
            weekDay: WeekDay.short,
            dayNameFontSize: 12,
            dayNumberFontSize: 16,
            dayBGColor: Colors.grey.withOpacity(0.15),
            titleSpaceBetween: 15,
            backgroundColor: Colors.transparent,
            // fullCalendar: false,
            fullCalendarScroll: FullCalendarScroll.horizontal,
            fullCalendarDay: WeekDay.short,
            selectedDateColor: Colors.white,
            dateColor: Colors.black,
            locale: 'en',

            initialDate: DateTime.now(),
            calendarEventColor: TColor.primaryColor2,
            firstDate: DateTime.now().subtract(const Duration(days: 140)),
            lastDate: DateTime.now().add(const Duration(days: 60)),

            onDateSelected: (date) {
              _selectedDateAppBBar = date;
              _loadDataForDate(date);
            },
            selectedDayLogo: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: TColor.primaryG,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAddMealCard(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "BreakFast",
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "${breakfastArr.length} Items | 230 calories",
                          style: TextStyle(color: TColor.gray, fontSize: 12),
                        ),
                      )
                    ],
                  ),
                ),
                ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: breakfastArr.length,
                    itemBuilder: (context, index) {
                      var mObj = breakfastArr[index] as Map? ?? {};
                      return MealFoodScheduleRow(
                        mObj: mObj,
                        index: index,
                      );
                    }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Lunch",
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "${lunchArr.length} Items | 500 calories",
                          style: TextStyle(color: TColor.gray, fontSize: 12),
                        ),
                      )
                    ],
                  ),
                ),
                ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: lunchArr.length,
                    itemBuilder: (context, index) {
                      var mObj = lunchArr[index] as Map? ?? {};
                      return MealFoodScheduleRow(
                        mObj: mObj,
                        index: index,
                      );
                    }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Snacks",
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "${snacksArr.length} Items | 140 calories",
                          style: TextStyle(color: TColor.gray, fontSize: 12),
                        ),
                      )
                    ],
                  ),
                ),
                ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snacksArr.length,
                    itemBuilder: (context, index) {
                      var mObj = snacksArr[index] as Map? ?? {};
                      return MealFoodScheduleRow(
                        mObj: mObj,
                        index: index,
                      );
                    }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Dinner",
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "${dinnerArr.length} Items | 120 calories",
                          style: TextStyle(color: TColor.gray, fontSize: 12),
                        ),
                      )
                    ],
                  ),
                ),
                ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: dinnerArr.length,
                    itemBuilder: (context, index) {
                      var mObj = dinnerArr[index] as Map? ?? {};
                      return MealFoodScheduleRow(
                        mObj: mObj,
                        index: index,
                      );
                    }),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today Meal Nutritions",
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: nutritionArr.length,
                    itemBuilder: (context, index) {
                      var nObj = nutritionArr[index] as Map? ?? {};

                      return NutritionRow(
                        nObj: nObj,
                      );
                    }),
                SizedBox(
                  height: media.width * 0.05,
                )
              ],
            ),
          ))
        ],
      ),
    );
  }
}
