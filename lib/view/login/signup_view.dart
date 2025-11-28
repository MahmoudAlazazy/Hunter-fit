import 'package:fitness/common/colo_extension.dart';
import 'package:fitness/common_widget/round_textfield.dart';
import 'package:fitness/view/login/complete_profile_view.dart';
import 'package:fitness/view/login/login_view.dart';
import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  bool isCheck = false;
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/SignUp.png"), // حط اسم الصورة هنا
                fit: BoxFit.cover,
                      alignment: Alignment(0, -0.5), // 0.5 معناها نازل لتحت
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header section
                const Padding(
                  padding: EdgeInsets.only(left: 30, top: 50),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // White card container
                Expanded(
                  child: Container(
                        margin: const EdgeInsets.only(top: 100), // نزل الكارد
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 40),
                              
                              // First Name field
                              const Text(
                                "First Name",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              RoundTextField(
                                controller: _firstNameController,
                                hitText: "........",
                                icon: "assets/img/user_text.png",
                                validator: (v) {
                                  final value = v?.trim() ?? '';
                                  if (value.isEmpty) return 'الاسم مطلوب';
                                  return null;
                                },
                                autofillHints: const [AutofillHints.name],
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Last Name field
                              const Text(
                                "Last Name",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              RoundTextField(
                                controller: _lastNameController,
                                hitText: "......",
                                icon: "assets/img/user_text.png",
                                validator: (v) {
                                  final value = v?.trim() ?? '';
                                  if (value.isEmpty) return 'اسم العائلة مطلوب';
                                  return null;
                                },
                                autofillHints: const [AutofillHints.familyName],
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Email field
                              const Text(
                                "Email",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              RoundTextField(
                                controller: _emailController,
                                hitText: "email@gmail.com",
                                icon: "assets/img/email.png",
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  final value = v?.trim() ?? '';
                                  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                                  if (value.isEmpty) return 'البريد الإلكتروني مطلوب';
                                  if (!emailRegex.hasMatch(value)) return 'صيغة بريد إلكتروني غير صحيحة';
                                  return null;
                                },
                                autofillHints: const [AutofillHints.email],
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Username field
                              const Text(
                                "Username",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              RoundTextField(
                                controller: _usernameController,
                                hitText: "johndoe",
                                icon: "assets/img/user_text.png",
                                validator: (v) {
                                  final value = v?.trim() ?? '';
                                  if (value.isEmpty) return 'اسم المستخدم مطلوب';
                                  if (value.length < 3) return 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل';
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Password field
                              const Text(
                                "Password",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              RoundTextField(
                                controller: _passwordController,
                                hitText: "••••••",
                                icon: "assets/img/lock.png",
                                obscureText: _obscure,
                                rigtIcon: IconButton(
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                  icon: Image.asset(
                                    "assets/img/show_password.png",
                                    width: 20,
                                    height: 20,
                                    color: TColor.gray,
                                  ),
                                ),
                                validator: (v) {
                                  final value = v ?? '';
                                  if (value.isEmpty) return 'كلمة المرور مطلوبة';
                                  if (value.length < 8) return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                                  return null;
                                },
                                autofillHints: const [AutofillHints.newPassword],
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Confirm Password field
                              const Text(
                                "Confirm Password",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              RoundTextField(
                                controller: _confirmController,
                                hitText: "••••••",
                                icon: "assets/img/lock.png",
                                obscureText: _obscureConfirm,
                                rigtIcon: IconButton(
                                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                  icon: Image.asset(
                                    "assets/img/show_password.png",
                                    width: 20,
                                    height: 20,
                                    color: TColor.gray,
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'تأكيد كلمة المرور مطلوب';
                                  if (v != _passwordController.text) return 'كلمتا المرور غير متطابقتين';
                                  return null;
                                },
                                autofillHints: const [AutofillHints.password],
                              ),
                              
                              const SizedBox(height: 10),
                              
                              // Terms and conditions checkbox
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isCheck = !isCheck;
                                      });
                                    },
                                    icon: Icon(
                                      isCheck
                                          ? Icons.check_box_outlined
                                          : Icons.check_box_outline_blank_outlined,
                                      color: TColor.gray,
                                      size: 20,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "By continuing you accept our Privacy Policy and Term of Use",
                                      style: TextStyle(color: TColor.gray, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Register button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () async {
                                          if (!_formKey.currentState!.validate() || !isCheck) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('يرجى إكمال البيانات والموافقة على الشروط')),
                                            );
                                            return;
                                          }
                                          setState(() => _isLoading = true);
                                          try {
                                            final email = _emailController.text.trim();
                                            final password = _passwordController.text;
                                            final username = _usernameController.text.trim();
                                            final fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'.trim();
                                            final res = await SupabaseService.signUpWithEmail(
                                              email: email,
                                              password: password,
                                              data: {
                                                'username': username,
                                                'full_name': fullName,
                                              },
                                            );
                                            final user = res.user;
                                            final session = res.session;
                                            
                                            if (user != null) {
                                              // Create profile immediately after signup
                                              await SupabaseService.createUserProfile(
                                                userId: user.id,
                                                username: username,
                                                fullName: fullName,
                                                email: email,
                                              );
                                              
                                              // Check if we have a valid session (email confirmed)
                                              if (session == null) {
                                                // Email confirmation required, redirect to login
                                                if (!mounted) return;
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('تم إنشاء الحساب بنجاح! يرجى التحقق من بريدك الإلكتروني والنقر على رابط التحقق للمتابعة.'),
                                                    duration: Duration(seconds: 5),
                                                  ),
                                                );
                                                await Future.delayed(const Duration(seconds: 3));
                                                if (!mounted) return;
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(builder: (_) => const CompleteProfileView()),
                                                );
                                              } 
                                            } else {
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('فشل إنشاء الحساب')),
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
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0A1F44),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    _isLoading ? "..." : "REGISTER",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 30),
                              
                              // Sign in section
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      "Already have an account?",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const LoginView()),
                                        );
                                      },
                                      child: const Text(
                                        "Sign In",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}