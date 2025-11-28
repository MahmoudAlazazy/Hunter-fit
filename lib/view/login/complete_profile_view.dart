import 'package:fitness/common/colo_extension.dart';
import 'package:fitness/view/login/what_your_goal_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';

import '../../common_widget/round_button.dart';
import '../../common_widget/round_textfield.dart';

class CompleteProfileView extends StatefulWidget {
  const CompleteProfileView({super.key});

  @override
  State<CompleteProfileView> createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends State<CompleteProfileView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _birthController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  String? _gender; // 'male'/'female'
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final prof = await SupabaseService.getProfileById(user.id);
    if (prof != null) {
      setState(() {
        _gender = (prof['gender'] as String?) == 'female' ? 'Female' : 'Male';
        final birth = prof['birth_date'] as String?;
        if (birth != null) _birthController.text = birth;
        final w = prof['weight_kg'] as num?;
        final h = prof['height_cm'] as num?;
        if (w != null) _weightController.text = w.toString();
        if (h != null) _heightController.text = h.toString();
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = now.subtract(const Duration(days: 365 * 20));
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: now,
      initialDate: initial,
    );
    if (picked != null) {
      _birthController.text = picked.toIso8601String().split('T')[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Image.asset(
                  "assets/img/complete_profile.png",
                  width: media.width,
                  fit: BoxFit.fitWidth,
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Text(
                  "لنُكمل ملفك الشخصي",
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                Text(
                  "سيساعدنا ذلك على معرفة المزيد عنك!",
                  style: TextStyle(color: TColor.gray, fontSize: 12),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Form(
                  key: _formKey,
                  child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    children: [
                      Container(
                          decoration: BoxDecoration(
                              color: TColor.lightGray,
                              borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            children: [
                              Container(
                                  alignment: Alignment.center,
                                  width: 50,
                                  height: 50,
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  
                                  child: Image.asset(
                                    "assets/img/gender.png",
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.contain,
                                    color: TColor.gray,
                                  )),
                            
                              Expanded(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    value: _gender,
                                    items: ["Male", "Female"]
                                        .map((name) => DropdownMenuItem(
                                              value: name,
                                              child: Text(
                                                name,
                                                style: TextStyle(
                                                    color: TColor.gray,
                                                    fontSize: 14),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _gender = value;
                                      });
                                    },
                                    isExpanded: true,
                                    hint: Text(
                                      "اختر الجنس",
                                      style: TextStyle(
                                          color: TColor.gray, fontSize: 12),
                                    ),
                                  ),
                                ),
                              ),

                             const SizedBox(width: 8,)

                            ],
                          ),
                        ),
                      SizedBox(
                        height: media.width * 0.04,
                      ),
                      GestureDetector(
                        onTap: _pickDate,
                        child: AbsorbPointer(
                          child: RoundTextField(
                            controller: _birthController,
                            hitText: "تاريخ الميلاد",
                            icon: "assets/img/date.png",
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'تاريخ الميلاد مطلوب';
                              return null;
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: media.width * 0.04,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RoundTextField(
                              controller: _weightController,
                              hitText: "وزنك",
                              icon: "assets/img/weight.png",
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]'))],
                              validator: (v) {
                                final val = double.tryParse(v ?? '');
                                if (val == null) return 'أدخل وزناً صحيحاً';
                                if (val < 10 || val > 400) return 'الوزن بين 10 و 400 كجم';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: TColor.secondaryG,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              "KG",
                              style:
                                  TextStyle(color: TColor.white, fontSize: 12),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: media.width * 0.04,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RoundTextField(
                              controller: _heightController,
                              hitText: "طولك",
                              icon: "assets/img/hight.png",
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]'))],
                              validator: (v) {
                                final val = double.tryParse(v ?? '');
                                if (val == null) return 'أدخل طولاً صحيحاً';
                                if (val < 50 || val > 300) return 'الطول بين 50 و 300 سم';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: TColor.secondaryG,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              "CM",
                              style:
                                  TextStyle(color: TColor.white, fontSize: 12),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: media.width * 0.07,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: RoundButton(
                          title: _isLoading ? "..." : "التالي >",
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  if (!_formKey.currentState!.validate() || _gender == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('يرجى إكمال البيانات المطلوبة')),
                                    );
                                    return;
                                  }
                                  setState(() => _isLoading = true);
                                  try {
                                    final user = Supabase.instance.client.auth.currentUser;
                                    if (user == null) {
                                      // User not authenticated, redirect to login
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('يرجى تسجيل الدخول للمتابعة'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                      await Future.delayed(const Duration(seconds: 2));
                                      if (!mounted) return;
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (_) => const WhatYourGoalView()),
                                      );
                                      return;
                                    }
                                    final fields = {
                                      'gender': _gender == 'Female' ? 'female' : 'male',
                                      'birth_date': _birthController.text,
                                      'weight_kg': double.parse(_weightController.text),
                                      'height_cm': double.parse(_heightController.text),
                                    };
                                    final ok = await SupabaseService.updateProfileFields(user.id, fields);
                                    if (!mounted) return;
                                    if (ok) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (_) => const WhatYourGoalView()),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('تعذر حفظ الملف الشخصي')),
                                      );
                                    }
                                  } catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('خطأ: $e')),
                                    );
                                  } finally {
                                    if (mounted) setState(() => _isLoading = false);
                                  }
                                },
                        ),
                      ),
                    ],
                  ),
                ),
            )],
            ),
          ),
        ),
      ),
    );
  }
}
