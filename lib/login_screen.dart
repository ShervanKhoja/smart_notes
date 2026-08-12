import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // تأكد من وجود هذه المكتبة
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ==========================================
  // [1] متحكمات الحقول وحالات الشاشة (Controllers & States)
  // ==========================================
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // يتحكم بظهور مؤشر التحميل أثناء تسجيل الدخول
  bool _obscurePassword = true; // يتحكم بإخفاء أو إظهار كلمة المرور

  // ==========================================
  // [2] دالة تسجيل الدخول عبر Supabase (Auth Function)
  // ==========================================
  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      // إرسال الإيميل وكلمة المرور للتحقق عبر Supabase
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      // الانتقال للشاشة الرئيسية عند نجاح تسجيل الدخول
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      // إظهار رسالة خطأ في حال فشل تسجيل الدخول
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ==========================================
    // [3] فقرة تحديد الألوان المتجاوبة مع الثيم (Themes & Colors)
    // ==========================================
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.grey : Colors.grey[700];
    final inputFillColor = isDarkMode ? const Color(0xFF2C2C2E) : Colors.grey[200];
    final iconColor = isDarkMode ? Colors.grey : Colors.grey[600];
    final buttonColor = isDarkMode ? Colors.white : Colors.black;
    final buttonTextColor = isDarkMode ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // ==========================================
      // [4] الشريط العلوي (AppBar)
      // ==========================================
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // زر الرجوع للخلف المتكيف مع لون الثيم
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: textColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // ==========================================
      // [5] جسم الصفحة الرئيسي (Body Content)
      // ==========================================
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان الرئيسي (Welcome Back!)
              Text(
                "Welcome Back!",
                style: TextStyle(
                  color: textColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // النص التوضيحي الفرعي تحت العنوان
              Text(
                "Log in to access your saved notes",
                style: TextStyle(color: subTextColor, fontSize: 14),
              ),
              const SizedBox(height: 25),

              // ==========================================
              // [6] حقل إدخال اسم المستخدم (Username Field)
              // ==========================================
              Text("Username", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildTextField(
                _usernameController,
                "Enter your name",
                Icons.person_outline,
                inputFillColor,
                iconColor,
                textColor,
              ),
              const SizedBox(height: 16),

              // ==========================================
              // [7] حقل إدخال البريد الإلكتروني (Email Field)
              // ==========================================
              Text("Email", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildTextField(
                _emailController,
                "Enter your email",
                Icons.email_outlined,
                inputFillColor,
                iconColor,
                textColor,
              ),
              const SizedBox(height: 16),

              // ==========================================
              // [8] حقل إدخال كلمة المرور (Password Field)
              // ==========================================
              Text("Password", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildTextField(
                _passwordController,
                "********",
                Icons.lock_outline,
                inputFillColor,
                iconColor,
                textColor,
                obscure: _obscurePassword, // إخفاء أو إظهار النص
                // زر أيقونة العين لإظهار/إخفاء كلمة المرور
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: iconColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword; // تبديل الحالة عند الضغط
                    });
                  },
                ),
              ),

              const SizedBox(height: 30),

              // ==========================================
              // [9] زر تسجيل الدخول (Log In Button)
              // ==========================================
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login, // تعطيل الزر أثناء التحميل
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: buttonTextColor) // عرض مؤشر تحميل داخل الزر
                      : Text(
                    "Log In",
                    style: TextStyle(
                      color: buttonTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40), // مسافة فاصلة قبل الأنيميشن

              // ==========================================
              // [10] حركة الأنيميشن السفلية (Lottie Animation)
              // ==========================================
              Center(
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: Lottie.asset(
                    'assets/welcome_back.json', // ملف الأنيميشن الموجود في الأصول
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // [11] دالة مساعدة لتصميم حقول الإدخال (Custom Text Field Widget)
  // ==========================================
  Widget _buildTextField(
      TextEditingController controller,
      String hint,
      IconData icon,
      Color? fillColor,
      Color? iconColor,
      Color? textColor, {
        bool obscure = false,
        Widget? suffixIcon,
      }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: iconColor),
        suffixIcon: suffixIcon,
        hintText: hint,
        hintStyle: TextStyle(color: iconColor),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }
}