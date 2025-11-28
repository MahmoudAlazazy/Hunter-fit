import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../common/colo_extension.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../common_widget/round_button.dart';
import '../../core/services/fitness_data_service.dart';
import 'meal_schedule_view.dart';

class MealPlannerView extends StatefulWidget {
  const MealPlannerView({super.key});

  @override
  State<MealPlannerView> createState() => _MealPlannerViewState();
}

class _MealPlannerViewState extends State<MealPlannerView> {
  DateTime _weekStart = _computeWeekStart(DateTime.now());
  int _selectedDayIndex = 0;
  List<Map<String, dynamic>> _weekItems = [];
  List<Map<String, dynamic>> _shoppingList = [];
  final List<String> _mealTypes = const ['breakfast', 'lunch', 'dinner', 'snack'];
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isLoading = false;

  static DateTime _computeWeekStart(DateTime now) {
    final wd = now.weekday % 7; // Sunday=0
    final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: wd));
    return start;
  }

  bool get _isArabic => Localizations.localeOf(context).languageCode.toLowerCase().startsWith('ar');
  String tr(String en, String ar) => _isArabic ? ar : en;

  @override
  void initState() {
    super.initState();
    _loadWeek();
  }

  Future<void> _loadWeek() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      final items = await FitnessDataService.getMealItemsForWeek(user.id, _weekStart);
      _weekItems = items;
      _shoppingList = await FitnessDataService.generateShoppingList(user.id, _weekStart);
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('Error loading meals', 'خطأ في تحميل الوجبات')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  DateTime _defaultTimeForMeal(DateTime day, String mealType) {
    switch (mealType) {
      case 'breakfast':
        return DateTime(day.year, day.month, day.day, 8, 0);
      case 'lunch':
        return DateTime(day.year, day.month, day.day, 13, 0);
      case 'snack':
        return DateTime(day.year, day.month, day.day, 16, 0);
      case 'dinner':
      default:
        return DateTime(day.year, day.month, day.day, 20, 0);
    }
  }

  Future<void> _addFoodToDayMeal(Map<String, dynamic> food, int dayIndex, String mealType) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final base = _weekStart.add(Duration(days: dayIndex));
    final servedAt = _defaultTimeForMeal(base, mealType);
    final meal = await FitnessDataService.addMealWithCalories(
      userId: user.id,
      mealType: mealType,
      name: food['name'] ?? mealType,
      servedAt: servedAt,
      caloriesKcal: 0,
    );
    if (meal == null) return;
    final mealId = meal['id'].toString();
    final foodId = food['id'].toString();
    await FitnessDataService.addFoodToMeal(mealId: mealId, foodId: foodId, servings: 1.0);
    await _loadWeek();
  }

  Future<void> _pickFood(int dayIndex, String mealType) async {
    _searchCtrl.clear();
    List<Map<String, dynamic>> foods = await FitnessDataService.searchFoods(limit: 50);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: TColor.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModal) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            decoration: InputDecoration(
                              hintText: tr('Search foods', 'ابحث عن وصفات'),
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: TColor.lightGray,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                            onChanged: (v) async {
                              final q = v.trim();
                              final res = await FitnessDataService.searchFoods(query: q.isEmpty ? null : q, limit: 50);
                              foods = res;
                              setModal(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: foods.length,
                      itemBuilder: (context, index) {
                        final f = foods[index];
                        return ListTile(
                          leading: CircleAvatar(backgroundColor: TColor.lightGray, child: const Icon(Icons.restaurant)),
                          title: Text(f['name'] ?? '-'),
                          subtitle: Text((f['brand'] ?? '') as String),
                          trailing: RoundButton(
                            title: tr('Add', 'إضافة'),
                            type: RoundButtonType.bgGradient,
                            onPressed: () async {
                              Navigator.pop(context);
                              await _addFoodToDayMeal(f, dayIndex, mealType);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> _savePlan() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final List<Map<String, dynamic>> items = [];
    for (final it in _weekItems) {
      final meals = it['meals'] ?? {};
      final foods = it['foods'] ?? {};
      final dt = DateTime.parse(meals['served_at']);
      final dayOffset = dt.difference(_weekStart).inDays;
      items.add({
        'food_id': foods['id']?.toString(),
        'meal_type': meals['meal_type'],
        'day_offset': dayOffset,
        'servings': it['servings'] ?? 1.0,
      });
    }
    await FitnessDataService.saveWeekPlan(user.id, _weekStart, items);
  }

  Future<void> _deleteMealItem(String mealItemId) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      
      await FitnessDataService.deleteMealItem(mealItemId);
      await _loadWeek();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('Item deleted successfully', 'تم حذف العنصر بنجاح')),
          backgroundColor: TColor.primaryColor2,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('Error deleting item', 'خطأ في حذف العنصر')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _reusePlan() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final saved = await FitnessDataService.loadWeekPlan(user.id, _weekStart);
    for (final e in saved) {
      final dayIndex = e['day_offset'] ?? 0;
      final mealType = e['meal_type'] ?? 'breakfast';
      final foodId = e['food_id'];
      Map<String, dynamic>? food;
      final all = await FitnessDataService.searchFoods(limit: 200);
      for (final f in all) {
        if (f['id'].toString() == foodId) { food = f; break; }
      }
      if (food != null) {
        await _addFoodToDayMeal(food, dayIndex, mealType);
      }
    }
    await _loadWeek();
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
          tr('Meal Planner', 'مخطط الوجبات'),
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(tr('Weekly Planner', 'مخطط أسبوعي'), style: TextStyle(color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700)),
                      Row(
                        children: [
                          IconButton(onPressed: () async { _weekStart = _weekStart.subtract(const Duration(days: 7)); await _loadWeek(); }, icon: const Icon(Icons.chevron_left)),
                          Text('${_weekStart.month}/${_weekStart.day}'),
                          IconButton(onPressed: () async { _weekStart = _weekStart.add(const Duration(days: 7)); await _loadWeek(); }, icon: const Icon(Icons.chevron_right)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(7, (i) {
                        final d = _weekStart.add(Duration(days: i));
                        final daysLabel = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
                        final arDays = ['الأحد','الإثنين','الثلاثاء','الأربعاء','الخميس','الجمعة','السبت'];
                        final label = tr(daysLabel[i], arDays[i]);
                        final selected = _selectedDayIndex == i;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(selected: selected, label: Text('$label ${d.day}'), onSelected: (_) => setState(() => _selectedDayIndex = i)),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _isLoading 
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(color: TColor.primaryColor2),
                        ),
                      )
                    : Column(
                        children: _mealTypes.map((mt) {
                          final itemsForCell = _weekItems.where((e) {
                            final meals = e['meals'] ?? {};
                            final dt = DateTime.parse(meals['served_at']);
                            return meals['meal_type'] == mt && dt.difference(_weekStart).inDays == _selectedDayIndex;
                          }).toList();
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: TColor.primaryColor2.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(tr(mt[0].toUpperCase() + mt.substring(1), _arabicLabel(mt)), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                    RoundButton(title: tr('Add', 'إضافة'), type: RoundButtonType.bgGradient, onPressed: () => _pickFood(_selectedDayIndex, mt)),
                                  ],
                                ),
                                if (itemsForCell.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  ...itemsForCell.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final item = entry.value;
                                    final food = item['foods'] ?? {};
                                    final foodName = food['name'] ?? 'Unknown Food';
                                    final brand = food['brand'] ?? '';
                                    final servings = (item['servings'] ?? 1.0).toString();
                                    
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: TColor.white.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: TColor.primaryColor2.withOpacity(0.2))
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: TColor.primaryColor2.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Icon(Icons.restaurant, color: TColor.primaryColor2, size: 20),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(foodName, style: const TextStyle(fontWeight: FontWeight.w500)),
                                                if (brand.isNotEmpty) 
                                                  Text(brand, style: TextStyle(color: TColor.gray, fontSize: 12)),
                                                Text('$servings ${tr('servings', 'حصص')}', style: TextStyle(color: TColor.primaryColor2, fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                            onPressed: () async => await _deleteMealItem(item['id']),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ] else
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Text(
                                      tr('No items added', 'لا توجد عناصر مضافة'),
                                      style: TextStyle(color: TColor.gray, fontSize: 14),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: SizedBox(height: 40, child: RoundButton(title: tr('Save Plan', 'حفظ الخطة'), type: RoundButtonType.bgGradient, onPressed: () async { await _savePlan(); }))),
                      const SizedBox(width: 12),
                      Expanded(child: SizedBox(height: 40, child: RoundButton(title: tr('Reuse Saved', 'استخدام المحفوظ'), type: RoundButtonType.bgGradient, onPressed: () async { await _reusePlan(); }))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    decoration: BoxDecoration(color: TColor.primaryColor2.withOpacity(0.3), borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tr('Daily Meal Schedule', 'جدول اليوم'), style: TextStyle(color: TColor.black, fontSize: 14, fontWeight: FontWeight.w700)),
                        SizedBox(
                          width: 90,
                          height: 30,
                          child: RoundButton(title: tr('Open', 'فتح'), type: RoundButtonType.bgGradient, fontSize: 12, fontWeight: FontWeight.w400, onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const MealScheduleView()));
                          }),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(tr('Shopping List', 'قائمة التسوق'), style: TextStyle(color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _isLoading 
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(color: TColor.primaryColor2, strokeWidth: 2),
                        ),
                      )
                    : _shoppingList.isEmpty 
                      ? Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: TColor.lightGray.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.shopping_bag_outlined, size: 48, color: TColor.gray),
                              const SizedBox(height: 8),
                              Text(
                                tr('No items in shopping list', 'لا توجد عناصر في قائمة التسوق'),
                                style: TextStyle(color: TColor.gray, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                tr('Add meals to generate shopping list', 'أضف وجبات لإنشاء قائمة التسوق'),
                                style: TextStyle(color: TColor.gray, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _shoppingList.length,
                          itemBuilder: (context, index) {
                            final s = _shoppingList[index];
                            final grams = (s['total_grams'] ?? 0.0) as double;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: TColor.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: TColor.lightGray.withOpacity(0.5)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: TColor.primaryColor2.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(Icons.shopping_bag, color: TColor.primaryColor2, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(s['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w500)),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${(s['total_servings'] ?? 0.0).toStringAsFixed(1)} ${tr('servings', 'حصص')} • ${grams.toStringAsFixed(0)} g',
                                          style: TextStyle(color: TColor.gray, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<LineChartBarData> get lineBarsData1 => [
        lineChartBarData1_1,
      ];

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
        isCurved: true,
        gradient: LinearGradient(colors: [
          TColor.primaryColor2,
          TColor.primaryColor1,
        ]),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
            radius: 3,
            color: Colors.white,
            strokeWidth: 1,
            strokeColor: TColor.primaryColor2,
          ),
        ),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(1, 35),
          FlSpot(2, 70),
          FlSpot(3, 40),
          FlSpot(4, 80),
          FlSpot(5, 25),
          FlSpot(6, 70),
          FlSpot(7, 35),
        ],
      );

  SideTitles get rightTitles => SideTitles(
        getTitlesWidget: rightTitleWidgets,
        showTitles: true,
        interval: 20,
        reservedSize: 40,
      );

  String _arabicLabel(String mealType) {
    switch (mealType) {
      case 'breakfast': return 'فطور';
      case 'lunch': return 'غداء';
      case 'dinner': return 'عشاء';
      case 'snack': return 'سناك';
      default: return mealType;
    }
  }

  Widget rightTitleWidgets(double value, TitleMeta meta) {
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0%';
        break;
      case 20:
        text = '20%';
        break;
      case 40:
        text = '40%';
        break;
      case 60:
        text = '60%';
        break;
      case 80:
        text = '80%';
        break;
      case 100:
        text = '100%';
        break;
      default:
        return Container();
    }

    return Text(text,
        style: TextStyle(
          color: TColor.gray,
          fontSize: 12,
        ),
        textAlign: TextAlign.center);
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    var style = TextStyle(
      color: TColor.gray,
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = Text('Sun', style: style);
        break;
      case 2:
        text = Text('Mon', style: style);
        break;
      case 3:
        text = Text('Tue', style: style);
        break;
      case 4:
        text = Text('Wed', style: style);
        break;
      case 5:
        text = Text('Thu', style: style);
        break;
      case 6:
        text = Text('Fri', style: style);
        break;
      case 7:
        text = Text('Sat', style: style);
        break;
      default:
        text = const Text('');
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: text,
    );
  }
}
