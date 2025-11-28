import 'package:fitness/common/colo_extension.dart';
import 'package:fitness/common_widget/round_textfield.dart';
import 'package:fitness/view/login/signup_view.dart';
import 'package:fitness/view/main_tab/main_tab_view.dart';
import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
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
                image: AssetImage("assets/Signin.png"), // حط اسم الصورة هنا
                fit: BoxFit.cover,
                  alignment: Alignment(0, -0.4), // 0.5 معناها نازل لتحت

              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header section
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // White card container
                Expanded(
                  
                  child: Container(
                        margin: const EdgeInsets.only(top: 110), // نزل الكارد
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
                                hitText: "john@email.com",
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
                              
                              const SizedBox(height: 30),
                              
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
                                autofillHints: const [AutofillHints.password],
                              ),
                              
                              const SizedBox(height: 10),
                              
                              // Forget password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () async {
                                    final email = _emailController.text.trim();
                                    if (email.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('أدخل البريد الإلكتروني لاستعادة كلمة المرور')),
                                      );
                                      return;
                                    }
                                    try {
                                      await SupabaseService.resetPassword(email);
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('تم إرسال رابط الاستعادة إلى بريدك')),
                                      );
                                    } catch (e) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('خطأ: $e')),
                                      );
                                    }
                                  },
                                  child: Text(
                                    "Forget password?",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 30),
                              
                              // Sign in button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () async {
                                          if (!_formKey.currentState!.validate()) return;
                                          setState(() => _isLoading = true);
                                          try {
                                            final res = await SupabaseService.signInWithEmail(
                                              email: _emailController.text.trim(),
                                              password: _passwordController.text,
                                            );
                                            if (res.user != null) {
                                              // Check if email is verified
                                              if (res.user!.emailConfirmedAt == null) {
                                                if (!mounted) return;
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('يرجى التحقق من بريدك الإلكتروني أولاً. تم إرسال رابط التحقق.'),
                                                    duration: Duration(seconds: 5),
                                                  ),
                                                );
                                                await SupabaseService.signOut();
                                                return;
                                              }
                                              
                                              // Check if user profile exists, create if not
                                              final existingProfile = await SupabaseService.getCurrentUserProfile();
                                              if (existingProfile == null) {
                                                // Create profile from auth metadata
                                                final user = res.user!;
                                                final fullName = user.userMetadata?['full_name'] as String? ?? 
                                                                user.userMetadata?['name'] as String? ?? 
                                                                'User';
                                                final username = user.userMetadata?['username'] as String? ?? 
                                                                 user.email?.split('@')[0] ?? 
                                                                 'user';
                                                
                                                await SupabaseService.createUserProfile(
                                                  userId: user.id,
                                                  username: username,
                                                  fullName: fullName,
                                                  email: user.email ?? '',
                                                );
                                              }
                                              
                                              if (!mounted) return;
                                              
                                              // Go directly to main app after login
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(builder: (_) => const MainTabView()),
                                              );
                                            } else {
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('فشل تسجيل الدخول')),
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
                                    _isLoading ? "..." : "SIGN IN",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 40),
                              
                              // Sign up section
                              Center(
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  children: [
                                    Text(
                                      "Dont have an account?",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const SignUpView(),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        "Sign Up",
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
                              
                              const SizedBox(height: 10),
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