import 'package:flutter/material.dart';
import 'main.dart'; // استدعاء themeNotifier للتحكم بالوضع الليلي
import 'app_scaffold.dart'; // استيراد القالب المشترك الموحد

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ==========================================
    // [1] فقرة الألوان والتصميم المتجاوب مع الثيم (Theme & Colors)
    // ==========================================
    final bool isDarkMode = themeNotifier.value == ThemeMode.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.grey.shade600;
    final cardColor = isDarkMode ? Colors.grey[850] : Colors.grey.shade100;
    final accentColor = Colors.blueAccent;

    return AppScaffold(
      // ==========================================
      // [2] الشريط العلوي (AppBar) القادم من AppScaffold
      // ==========================================
      title: "About App",

      // ==========================================
      // [3] جسم الصفحة الرئيسي (Body Content)
      // ==========================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // أيقونة التطبيق مع إطار خفيف متناسق (App Logo/Icon)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accentColor.withOpacity(0.4), width: 2),
              ),
              child: CircleAvatar(
                radius: 45,
                backgroundColor: isDarkMode ? Colors.grey[800] : Colors.black,
                child: const Icon(Icons.note_alt, size: 45, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            // ==========================================
            // [4] اسم التطبيق ورقم الإصدار (App Name & Version)
            // ==========================================
            Text(
              "Smart Notes",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Version 1.0.0",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ),
            const SizedBox(height: 35),

            // ==========================================
            // [5] نبذة تعريفية داخل صندوق أنيق (App Description)
            // ==========================================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "A smart application to manage and organize notes and ideas with ease",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: subTextColor,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // ==========================================
            // [6] حقوق الطبع والنشر والتأسيس (Footer Rights)
            // ==========================================
            Text(
              "Smart Notes • All Rights Reserved © 2026",
              style: TextStyle(
                fontSize: 12,
                color: subTextColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}