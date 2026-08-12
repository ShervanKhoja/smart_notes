import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // [1] استيراد حزمة Supabase للاتصال بقاعدة البيانات

import 'onboarding.dart';
import 'create_profile.dart';
import 'login_screen.dart'; // [2] استدعاء شاشة تسجيل الدخول الجديدة
import 'home.dart';
import 'edit_note.dart';

// ==========================================
// [3] متغير عام للتحكم بالوضع الليلي لكامل التطبيق
// ==========================================
// يسمح بتغيير الثيم وتحديث واجهات التطبيق فوراً عند التبديل
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  // ==========================================
  // [4] فقرة التهيئة الأولية للتطبيق
  // ==========================================
  // ضمان تهيئة عناصر الويدجتس قبل ربط السيرفر والعمليات غير المتزامنة
  WidgetsFlutterBinding.ensureInitialized();

  // [5] تهيئة الاتصال بـ Supabase بالمعرفات الخاصة بالمشروع
  await Supabase.initialize(
    url: 'https://qsixrpegrtnytxhkbden.supabase.co',
    anonKey: 'sb_publishable_1kg0lIHEewI70SNpLLYGFw_5duqoXYh',
  );

  // تشغيل التطبيق واستدعاء الويدجت الجذرية
  runApp(const SmartNotesApp());
}

class SmartNotesApp extends StatelessWidget {
  const SmartNotesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ==========================================
    // [6] مراقب تغييرات الثيم (ValueListenableBuilder)
    // ==========================================
    // يستمع لأي تغيير يحدث على متغير الوضع الليلي لتحديث تصميم التطبيق بالكامل
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Smart Notes App',
          debugShowCheckedModeBanner: false,

          // ربط الثيم الحالي بحالة الوضع الليلي أو الفاتح
          themeMode: currentMode,

          // ==========================================
          // [7] إعدادات الثيم الفاتح (Light Theme)
          // ==========================================
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            canvasColor: Colors.white,
            textTheme: GoogleFonts.poppinsTextTheme(
              ThemeData.light().textTheme,
            ),
          ),

          // ==========================================
          // [8] إعدادات الثيم الليلي (Dark Theme)
          // ==========================================
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.grey[900],
            canvasColor: Colors.grey[900],
            textTheme: GoogleFonts.poppinsTextTheme(
              ThemeData.dark().textTheme,
            ),
          ),

          // ==========================================
          // [9] خريطة مسارات التنقل بين صفحات التطبيق (Routes)
          // ==========================================
          initialRoute: '/',
          routes: {
            '/': (context) => const OnboardingScreen(), // الشاشة الافتتاحية الأولى
            '/create-profile': (context) => const CreateProfileScreen(), // شاشة إنشاء الحساب
            '/login': (context) => LoginScreen(), // شاشة تسجيل الدخول (بدون const لتجنب الأخطاء مع الـ controllers)
            '/home': (context) => const HomeScreen(), // الشاشة الرئيسية للملاحظات
            '/edit-note': (context) => const EditNoteScreen(), // شاشة تعديل الملاحظات
          },
        );
      },
    );
  }
}