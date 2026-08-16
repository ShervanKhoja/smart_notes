import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'app_scaffold.dart'; // استدعاء القالب المشترك الموحد

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تحديد لون الزر بناءً على الوضع الحالي (ليلي أو نهاري)
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final buttonColor = isDarkMode ? Colors.grey[800] : Colors.black;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.grey.shade700;

    return AppScaffold(
      title: "", // العنوان في الشريط العلوي
      showBackButton: false, // تم إخفاء زر الرجوع لأنها الصفحة الأولى

      // ==========================================
      // [6] جسم الصفحة الرئيسي (Body Content)
      // ==========================================
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              const Spacer(flex: 1),

              // ==========================================
              // [7] حركة الأنيميشن المتحرك (Lottie Animation)
              // ==========================================
              // عرض أنيميشن الملاحظات المتحرك في منتصف الشاشة
              SizedBox(
                height: 260,
                width: double.infinity,
                child: Lottie.asset(
                  'assets/take_note.json',
                  fit: BoxFit.contain,
                ),
              ),
              const Spacer(flex: 1),

              // ==========================================
              // [8] فقرة النصوص والعناوين الرئيسية
              // ==========================================
              // العنوان الرئيسي البارز في الصفحة
              Text(
                "Refine Your Life\nManagement",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // النص التوضيحي الفرعي تحت العنوان
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  "Smart Notes",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: subTextColor,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // ==========================================
              // [9] زر البدء الرئيسي (Let's Start Button)
              // ==========================================
              // الزر الكبير أسفل الصفحة مع تأثير الظل والانحناء للانتقال لصفحة تسجيل الدخول
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    // الانتقال لصفحة تسجيل الدخول عند الضغط على الزر
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text(
                    "Let's Start",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }
}