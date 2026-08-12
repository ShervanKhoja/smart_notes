import 'package:flutter/material.dart';
import 'main.dart'; // استدعاء themeNotifier للتحكم بالوضع الليلي

class AboutDeveloperScreen extends StatelessWidget {
  const AboutDeveloperScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ==========================================
    // [1] فقرة الألوان والتصميم المتجاوب مع الثيم (Theme & Colors)
    // ==========================================
    final bool isDarkMode = themeNotifier.value == ThemeMode.dark;
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.grey.shade600;
    final cardColor = isDarkMode ? Colors.grey[850] : Colors.grey.shade100;
    final accentColor = Colors.blueAccent;

    return Scaffold(
      backgroundColor: backgroundColor,

      // ==========================================
      // [2] الشريط العلوي (AppBar)
      // ==========================================
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "عن المطور",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      // ==========================================
      // [3] جسم الصفحة الرئيسي (Body Content)
      // ==========================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            // أيقونة المطور الرئيسية في الأعلى (Profile Avatar)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accentColor.withOpacity(0.5), width: 2),
              ),
              child: CircleAvatar(
                radius: 45,
                backgroundColor: isDarkMode ? Colors.grey[800] : Colors.black,
                child: const Icon(Icons.person, size: 45, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),

            // ==========================================
            // [4] بطاقة اسم المطور (Developer Name Card)
            // ==========================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person, color: accentColor, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "المطور",
                          style: TextStyle(
                            fontSize: 15,
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Shervan Khoja",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ==========================================
            // [5] بطاقة اسم الاستوديو (Studio Card)
            // ==========================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.apartment, color: Colors.orangeAccent, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "استوديو التطوير",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "KSK",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.orangeAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // ==========================================
            // [6] نبذة تعريفية قصيرة عن التطبيق (Bio/Description)
            // ==========================================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "تم تطوير هذا التطبيق بعناية فائقة لتسهيل إدارة مهامك اليومية وتنظيم أفكارك بكل احترافية.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: subTextColor,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // ==========================================
            // [7] حقوق الطبع والنشر والتطبيق (Footer Rights)
            // ==========================================
            Text(
              "Smart Notes • All Rights Reserved © 2026",
              style: TextStyle(
                fontSize: 12,
                color: subTextColor?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}