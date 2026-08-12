import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart'; // استدعاء themeNotifier للتحكم بالوضع الليلي
import 'login_screen.dart'; // استدعاء شاشة تسجيل الدخول

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({Key? key}) : super(key: key);

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  // ==========================================
  // [1] متغيرات وحالات الشاشة (States & Controllers)
  // ==========================================
  bool _obscurePassword = true; // يتحكم بإظهار أو إخفاء كلمة المرور
  bool _isLoading = false;      // مؤشر التحميل أثناء عملية إنشاء الحساب

  // تعريف الـ Controllers لمتابعة النصوص المدخلة من المستخدم
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ==========================================
  // [2] دالة التحقق من المدخلات وإنشاء الحساب في Supabase (Validation & Sign Up)
  // ==========================================
  Future<void> _validateAndContinue() async {
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    // الشرط الأول: التأكد من وجود @gmail.com في البريد الإلكتروني
    if (!email.endsWith('@gmail.com') && !email.contains('@gmail.com')) {
      _showErrorDialog("يجب أن يحتوي البريد الإلكتروني على @gmail.com");
      return;
    }

    // الشرط الثاني: كلمة المرور لا تقل عن 5 أحرف أو أرقام
    if (password.length < 5) {
      _showErrorDialog("كلمة المرور يجب ألا تقل عن 5 أحرف أو أرقام");
      return;
    }

    setState(() {
      _isLoading = true; // بدء مؤشر التحميل
    });

    try {
      // 1. إنشاء الحساب في نظام المصادقة Supabase Auth
      final AuthResponse res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      final User? user = res.user;

      if (user != null) {
        // 2. تخزين معلومات الحساب الإضافية (اسم المستخدم والبريد) في جدول الـ profiles
        await Supabase.instance.client.from('profiles').upsert({
          'id': user.id,
          'username': username,
          'email': email,
        });

        if (!mounted) return;

        // الانتقال للشاشة الرئيسية بعد نجاح التسجيل وحذف هذه الصفحة من الـ Stack
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on AuthException catch (e) {
      _showErrorDialog(e.message); // إظهار خطأ المصادقة القادم من Supabase
    } catch (e) {
      _showErrorDialog("Error: $e"); // إظهار أي خطأ عام آخر
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // إيقاف مؤشر التحميل
        });
      }
    }
  }

  // ==========================================
  // [3] دالة إظهار رسائل الأخطاء (Error Dialog/SnackBar)
  // ==========================================
  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ==========================================
    // [4] فقرة الألوان والتصميم المتجاوب مع الثيم (Theme & Colors)
    // ==========================================
    final bool isDarkMode = themeNotifier.value == ThemeMode.dark;

    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    final inputFillColor = isDarkMode ? Colors.grey[850] : Colors.grey.shade100;
    final buttonColor = isDarkMode ? Colors.white : Colors.black;
    final buttonTextColor = isDarkMode ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,

      // ==========================================
      // [5] الشريط العلوي (AppBar)
      // ==========================================
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Create Profile",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      // ==========================================
      // [6] جسم الصفحة الرئيسي وحقول الإدخال (Body Content)
      // ==========================================
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة أو حركة الأنيميشن العلوية (Lottie Animation)
              Center(
                child: SizedBox(
                  height: 140,
                  child: Lottie.asset('assets/create_account.json'),
                ),
              ),
              const SizedBox(height: 20),

              // حقل إدخال اسم المستخدم (Username Field)
              Text("Username", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person_outline, color: subTextColor),
                  hintText: "Pulakit Bararia",
                  hintStyle: TextStyle(color: isDarkMode ? Colors.grey[500] : Colors.grey),
                  filled: true,
                  fillColor: inputFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // حقل إدخال البريد الإلكتروني (Email Field)
              Text("Email", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined, color: subTextColor),
                  hintText: "barariapulakit@gmail.com",
                  hintStyle: TextStyle(color: isDarkMode ? Colors.grey[500] : Colors.grey),
                  filled: true,
                  fillColor: inputFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // حقل إدخال كلمة المرور (Password Field)
              Text("Password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword, // إخفاء أو إظهار النص
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline, color: subTextColor),
                  // زر أيقونة العين لإظهار وإخفاء كلمة المرور
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: subTextColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  hintText: "********",
                  hintStyle: TextStyle(color: isDarkMode ? Colors.grey[500] : Colors.grey),
                  filled: true,
                  fillColor: inputFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // ==========================================
              // [7] زر الاستمرار الرئيسي (Continue Button)
              // ==========================================
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _isLoading ? null : _validateAndContinue, // تعطيل الزر أثناء التحميل
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.blueAccent) // مؤشر تحميل داخل الزر
                      : Text(
                    "Continue",
                    style: TextStyle(fontSize: 18, color: buttonTextColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // ==========================================
              // [8] زر الانتقال لتسجيل الدخول (Log In Button)
              // ==========================================
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isDarkMode ? Colors.white54 : Colors.black26,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    // الانتقال لشاشة تسجيل الدخول
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text(
                    "Already have an account? Log in",
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
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