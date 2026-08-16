import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'create_profile.dart';
import 'app_scaffold.dart';
import 'onboarding.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ==========================================
  // [2] دالة تسجيل الدخول الاحترافية مع التحقق ومعالجة الأخطاء
  // ==========================================
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 1. التحقق من الحقول الفارغة
    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackBar("Please fill in all fields.");
      return;
    }

    // 2. التحقق من صحة صيغة البريد الإلكتروني
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _showErrorSnackBar("Please enter a valid email address (e.g., example@gmail.com).");
      return;
    }

    // 3. التحقق من طول كلمة المرور (أقل من 6 محارف)
    if (password.length < 6) {
      _showErrorSnackBar("Password must be at least 6 characters long.");
      return;
    }

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on AuthException catch (e) {
      // معالجة أخطاء Supabase المحددة وعرض رسائل مفهومة للمستخدم
      String message = "An error occurred during login.";
      if (e.message.contains("Invalid login credentials")) {
        message = "Incorrect email or password. Please check your credentials.";
      } else {
        message = e.message;
      }
      _showErrorSnackBar(message);
    } catch (e) {
      _showErrorSnackBar("An unexpected error occurred. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // دالة مساعدة لإظهار التنبيهات بتصميم موحد
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.grey : Colors.grey[700];
    final inputFillColor = isDarkMode ? const Color(0xFF2C2C2E) : Colors.grey[200];
    final iconColor = isDarkMode ? Colors.grey : Colors.grey[600];
    final buttonColor = isDarkMode ? Colors.white : Colors.black;
    final buttonTextColor = isDarkMode ? Colors.black : Colors.white;

    return AppScaffold(
      title: "",
      showBackButton: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SizedBox(
                  height: 130,
                  child: Lottie.asset('assets/welcome_back.json'),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "Welcome Back!",
                style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Log in to access your saved notes",
                style: TextStyle(color: subTextColor, fontSize: 14),
              ),
              const SizedBox(height: 25),
              Text("Email", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildTextField(_emailController, "Enter your email", Icons.email_outlined, inputFillColor, iconColor, textColor),
              const SizedBox(height: 16),
              Text("Password", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildTextField(
                _passwordController,
                "********",
                Icons.lock_outline,
                inputFillColor,
                iconColor,
                textColor,
                obscure: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: iconColor),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: buttonTextColor)
                      : Text("Log In", style: TextStyle(color: buttonTextColor, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreateProfileScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: isDarkMode ? Colors.grey[700]! : Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text("Don't have an account? Sign Up", style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, Color? fillColor, Color? iconColor, Color? textColor, {bool obscure = false, Widget? suffixIcon}) {
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }
}