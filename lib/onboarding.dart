import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'main.dart'; // استدعاء themeNotifier للتحكم بالوضع الليلي لكل التطبيق
import 'about_app.dart'; // استيراد صفحة عن البرنامج
import 'about_developer.dart'; // استيراد صفحة عن المطور

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    // ==========================================
    // [1] فقرة تهيئة الثيم والألوان المتجاوبة
    // ==========================================
    // معرفة هل الوضع الحالي ليلي أم لا بناءً على الثيم العام للتطبيق
    final bool isDarkMode = themeNotifier.value == ThemeMode.dark;

    // تحديد الألوان المتغيرة (دنانيميكياً) بناءً على ما إذا كان الوضع ليلياً أو نهارياً
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.grey.shade700;
    final buttonColor = isDarkMode ? Colors.grey[800] : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,

      // ==========================================
      // [2] فقرة القائمة الجانبية (Drawer)
      // ==========================================
      // القائمة الجانبية المنسدلة من الجانب وتحتوي على الروابط والوضع الليلي
      drawer: Drawer(
        backgroundColor: backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // رأس القائمة الجانبية (معلومات التطبيق والشعار)
            UserAccountsDrawerHeader(
              accountName: Text(
                "Smart Notes",
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                "Version 1.0.0",
                style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: isDarkMode ? Colors.grey[800] : Colors.black,
                child: const Icon(Icons.note_alt, size: 30, color: Colors.white),
              ),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black : Colors.grey.shade200,
              ),
            ),

            // ==========================================
            // [3] فقرة أزرار التنقل داخل القائمة
            // ==========================================
            // [زر عن البرنامج]: عند النقر عليه يتم إغلاق القائمة والانتقال لصفحة AboutAppScreen
            ListTile(
              leading: Icon(Icons.info_outline, color: textColor),
              title: Text('عن البرنامج', style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.pop(context); // حركة إغلاق القائمة الجانبية
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutAppScreen()),
                );
              },
            ),

            // [زر عن المطور]: عند النقر عليه يتم إغلاق القائمة والانتقال لصفحة AboutDeveloperScreen
            ListTile(
              leading: Icon(Icons.person, color: textColor),
              title: Text('عن المطور', style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.pop(context); // حركة إغلاق القائمة الجانبية
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutDeveloperScreen()),
                );
              },
            ),

            Divider(color: isDarkMode ? Colors.grey[700] : Colors.grey.shade300),

            // ==========================================
            // [4] زر حركة التبديل للوضع الليلي (Switch)
            // ==========================================
            // يتحكم بالوضع الليلي لكامل التطبيق، وتتغير أيقونته ديناميكياً (شمس في النهار، قمر في الليل)
            SwitchListTile(
              secondary: Icon(
                isDarkMode ? Icons.nights_stay : Icons.wb_sunny_outlined,
                color: textColor,
              ),
              title: Text('الوضع الليلي', style: TextStyle(color: textColor)),
              value: isDarkMode,
              onChanged: (bool value) {
                setState(() {
                  // حركة تغيير الثيم وتحديث حالة التطبيق بالكامل
                  themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                });
              },
            ),
          ],
        ),
      ),

      // ==========================================
      // [5] الشريط العلوي (AppBar)
      // ==========================================
      // يحتوي على زر فتح القائمة الجانبية (ثلاثة خطوط) المتكيف مع لون النص
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),

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
              // [8] فقرة العصوص والعناوين الرئيسية
              // ==========================================
              // العنوان الرئيسي البارز في الصفحة
              Text(
                "Refine Your Life\nManagement",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textColor,
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
              // الزر الكبير أسفل الصفحة مع تأثير الظل والانحناء للانتقال لصفحة إنشاء الحساب
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
                    // حركة الانتقال لصفحة التسجيل عند الضغط على الزر
                    Navigator.pushNamed(context, '/create-profile');
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
              const SizedBox(height: 25),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}