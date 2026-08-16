import 'package:flutter/material.dart';
import 'main.dart';
import 'about_app.dart';
import 'about_developer.dart';
import 'onboarding.dart'; // تأكد من استيراد صفحة الـ Onboarding ليعمل الانتقال بشكل صحيح

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final bool showBackButton;
  final Widget? floatingActionButton;

  const AppScaffold({
    Key? key,
    required this.title,
    required this.body,
    this.actions,
    this.showBackButton = true,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentThemeMode, child) {
        final bool isDarkMode = currentThemeMode == ThemeMode.dark;
        final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;
        final textColor = isDarkMode ? Colors.white : Colors.black87;
        final drawerBgColor = isDarkMode ? Colors.grey[850] : Colors.white;

        return Scaffold(
          backgroundColor: backgroundColor,
          drawer: SizedBox(
            width: MediaQuery.of(context).size.width * 0.75,
            child: Drawer(
              backgroundColor: drawerBgColor,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(color: isDarkMode ? Colors.black26 : Colors.blueAccent.withOpacity(0.1)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(radius: 30, backgroundColor: isDarkMode ? Colors.grey[700] : Colors.blueAccent, child: const Icon(Icons.note_alt, size: 30, color: Colors.white)),
                        const SizedBox(height: 10),
                        Text("Smart Notes", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.info_outline, color: textColor),
                    title: Text("About App", style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutAppScreen()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.person_outline, color: textColor),
                    title: Text("About Developer", style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutDeveloperScreen()));
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode, color: isDarkMode ? Colors.amber : Colors.blueAccent),
                    title: Text(isDarkMode ? "Dark Mode" : "Light Mode", style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                    value: isDarkMode,
                    onChanged: (bool value) => themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light,
                  ),
                ],
              ),
            ),
          ),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leadingWidth: 110,
            leading: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (showBackButton)
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                      icon: Icon(Icons.arrow_back_ios, color: textColor, size: 20),
                      onPressed: () {
                        // التحقق المزدوج لضمان عدم توقف الزر أبداً
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          // إذا لم تكن هناك شاشة سابقة، يعيد توجيه المستخدم لشاشة الـ Onboarding بسلاسة
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                          );
                        }
                      },
                    ),
                  const SizedBox(width: 4),
                  Builder(
                    builder: (context) => Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.menu, color: textColor, size: 24),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
            actions: actions,
          ),
          body: body,
          floatingActionButton: floatingActionButton,
        );
      },
    );
  }
}