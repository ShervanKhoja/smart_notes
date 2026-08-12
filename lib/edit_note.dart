import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';

class EditNoteScreen extends StatefulWidget {
  final Map<String, dynamic>? note; // استقبال الملاحظة في حال التعديل (تكون فارغة في حال الإضافة)

  const EditNoteScreen({Key? key, this.note}) : super(key: key);

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  // ==========================================
  // [1] متحكمات الحقول وحالات الشاشة (Controllers & States)
  // ==========================================
  late TextEditingController titleController;
  late TextEditingController contentController;
  bool _isSaving = false; // مؤشر لحالة الحفظ لمنع الضغط المزدوج

  @override
  void initState() {
    super.initState();
    // تهيئة الحقول بالبيانات السابقة إذا كانت الملاحظة موجودة، أو تركها فارغة للإضافة الجديدة
    titleController = TextEditingController(text: widget.note?['title'] ?? '');
    contentController = TextEditingController(text: widget.note?['content'] ?? '');
  }

  @override
  void dispose() {
    // التخلص من المتحكمات لتحرير الذاكرة عند إغلاق الصفحة
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  // ==========================================
  // [2] دالة الحفظ والتعديل في قاعدة بيانات Supabase (Save/Update Function)
  // ==========================================
  Future<void> _saveNote() async {
    if (_isSaving) return;

    final title = titleController.text.trim();
    final content = contentController.text.trim();

    // إذا كانت الحقول فارغة تماماً، يتم الخروج دون حفظ
    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context, false);
      return;
    }

    setState(() {
      _isSaving = true; // بدء التحميل وتفعيل مؤشر الحفظ
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (widget.note == null) {
        // [إضافة]: إضافة ملاحظة جديدة إلى جدول notes مع ربطها بمعرف المستخدم الحالي
        await Supabase.instance.client.from('notes').insert({
          'title': title,
          'content': content,
          'user_id': user?.id ?? '',
        });
      } else {
        // [تعديل]: تحديث ملاحظة موجودة مسبقاً بناءً على معرف الملاحظة (id)
        await Supabase.instance.client.from('notes').update({
          'title': title,
          'content': content,
        }).eq('id', widget.note!['id']);
      }

      if (mounted) {
        Navigator.pop(context, true); // إرجاع true لإخبار الشاشة الرئيسية بإعادة تحميل القائمة
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("حدث خطأ أثناء الحفظ: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false; // إيقاف مؤشر الحفظ
        });
      }
    }
  }

  // ==========================================
  // [3] دالة التعامل مع الرجوع التلقائي وحفظ التغييرات (WillPopScope)
  // ==========================================
  Future<bool> _onWillPop() async {
    // إذا كانت الحقول فارغة، يتم السماح بالرجوع فوراً دون حفظ
    if (titleController.text.isEmpty && contentController.text.isEmpty) {
      return true;
    }

    // حفظ الملاحظة تلقائياً عند محاولة الخروج من الصفحة
    await _saveNote();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // تحديد الثيم والألوان ديناميكياً
    final bool isDarkMode = themeNotifier.value == ThemeMode.dark;

    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final inputFillColor = isDarkMode ? Colors.grey[850] : Colors.grey.shade100;
    final buttonColor = isDarkMode ? Colors.white : Colors.black;
    final buttonTextColor = isDarkMode ? Colors.black : Colors.white;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: backgroundColor,

        // ==========================================
        // [4] الشريط العلوي (AppBar)
        // ==========================================
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: textColor),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context, false);
              }
            },
          ),
          // عنوان الصفحة يتغير ديناميكياً (إضافة أو تعديل)
          title: Text(
            widget.note == null ? "Add Note" : "Edit Note",
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),

        // ==========================================
        // [5] جسم الصفحة الرئيسي وحقول الإدخال (Body Content)
        // ==========================================
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // حقل عنوان الملاحظة (Title Field)
              Text("Name Note", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: "Enter note title...",
                  hintStyle: TextStyle(color: isDarkMode ? Colors.grey[500] : Colors.grey),
                  filled: true,
                  fillColor: inputFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // حقل محتوى الملاحظة (Content Field)
              Text("Content", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
              const SizedBox(height: 8),
              TextField(
                controller: contentController,
                maxLines: 5,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: "Write your note here...",
                  hintStyle: TextStyle(color: isDarkMode ? Colors.grey[500] : Colors.grey),
                  filled: true,
                  fillColor: inputFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const Spacer(),

              // ==========================================
              // [6] زر الحفظ (Save Button)
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
                  onPressed: _isSaving ? null : _saveNote, // تعطيل الزر أثناء عملية الحفظ
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.blueAccent) // مؤشر تحميل داخلي
                      : Text(
                    "Save",
                    style: TextStyle(fontSize: 18, color: buttonTextColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}