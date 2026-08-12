import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_note.dart';
import 'main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ==========================================
  // [1] متغيرات وحالات الشاشة (States & Controllers)
  // ==========================================
  List<Map<String, dynamic>> notes = [];          // قائمة الملاحظات الأصلية الجلبة من السيرفر
  List<Map<String, dynamic>> filteredNotes = [];  // قائمة الملاحظات المفلترة (تستخدم للبحث)
  bool isLoading = true;                          // مؤشر التحميل أثناء جلب البيانات
  bool isSearching = false;                       // حالة البحث (هل شريط البحث مفتوح أم لا)
  final TextEditingController searchController = TextEditingController(); // متحكم حقل البحث

  @override
  void initState() {
    super.initState();
    _fetchNotesFromSupabase(); // جلب الملاحظات فور فتح الشاشة
  }

  // ==========================================
  // [2] دالة جلب الملاحظات من Supabase (Fetch Data)
  // ==========================================
  Future<void> _fetchNotesFromSupabase() async {
    setState(() => isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) return; // التأكد من وجود مستخدم مسجل دخول

      // جلب الملاحظات التي تخص الـ ID للمستخدم الحالي فقط مع ترتيبها من الأحدث للأقدم
      final response = await Supabase.instance.client
          .from('notes')
          .select()
          .eq('user_id', user.id) // عزل الملاحظات الخاصة بالمستخدم الحالي فقط
          .order('created_at', ascending: false);

      setState(() {
        notes = List<Map<String, dynamic>>.from(response);
        filteredNotes = notes; // تعيين القائمة المفلترة لتساوي القائمة الأصلية مبدئياً
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطأ في جلب الملاحظات: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // ==========================================
  // [3] دالة فلترة الملاحظات أثناء البحث (Search Function)
  // ==========================================
  void _filterNotes(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredNotes = notes;
      } else {
        filteredNotes = notes
            .where((note) =>
        (note['title'] ?? '').toString().toLowerCase().contains(query.toLowerCase()) ||
            (note['content'] ?? '').toString().toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  // ==========================================
  // [4] دالة حذف الملاحظة من قاعدة البيانات (Delete Note)
  // ==========================================
  Future<void> _deleteNote(dynamic noteId) async {
    try {
      await Supabase.instance.client
          .from('notes')
          .delete()
          .eq('id', noteId);

      _fetchNotesFromSupabase(); // إعادة تحديث القائمة بعد الحذف
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("فشل حذف الملاحظة: $e")),
        );
      }
    }
  }

  // ==========================================
  // [5] نافذة تأكيد الحذف المنبثقة (Delete Dialog)
  // ==========================================
  void _showDeleteDialog(dynamic noteId) {
    final bool isDarkMode = themeNotifier.value == ThemeMode.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("حذف الملاحظة", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
          content: Text("هل أنت متأكد من أنك تريد حذف هذه الملاحظة؟", style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // إغلاق النافذة دون حذف
              child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // إغلاق نافذة التأكيد
                _deleteNote(noteId);     // تنفيذ عملية الحذف
              },
              child: const Text("حذف", style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = themeNotifier.value == ThemeMode.dark;

    // تحديد الألوان ديناميكياً حسب الوضع الليلي أو الفاتح
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.grey;
    final cardColor = isDarkMode ? Colors.grey[850] : Colors.grey.shade100;
    final fabColor = isDarkMode ? Colors.white : Colors.black;
    final fabIconColor = isDarkMode ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,

      // ==========================================
      // [6] الشريط العلوي (AppBar) مع تبديل حالة البحث
      // ==========================================
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        // التبديل بين عرض عنوان التطبيق أو حقل البحث
        title: isSearching
            ? TextField(
          controller: searchController,
          autofocus: true,
          onChanged: _filterNotes,
          style: TextStyle(color: textColor, fontSize: 18),
          decoration: InputDecoration(
            hintText: "Search notes...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: isDarkMode ? Colors.grey[500] : Colors.grey),
          ),
        )
            : Text(
          "Smart Notes",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          // زر تفعيل أو إغلاق البحث
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search, color: subTextColor),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  searchController.clear();
                  filteredNotes = notes; // إعادة تعيين الملاحظات عند إغلاق البحث
                }
              });
            },
          ),
        ],
      ),

      // ==========================================
      // [7] جسم الصفحة الرئيسي وعرض الملاحظات (Body Content)
      // ==========================================
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome Back!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 8),
            Text(
              "Here are your notes and ideas",
              style: TextStyle(fontSize: 14, color: subTextColor),
            ),
            const SizedBox(height: 20),

            // عرض المحتوى بناءً على حالة التحميل أو خلو القائمة
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator()) // مؤشر تحميل البيانات
                  : filteredNotes.isEmpty
                  ? Center(
                child: Text(
                  "No notes found. Tap '+' to add one.",
                  style: TextStyle(color: subTextColor, fontSize: 14),
                ),
              )
                  : ListView.builder(
                itemCount: filteredNotes.length,
                itemBuilder: (context, index) {
                  final note = filteredNotes[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      // النقر لتعديل الملاحظة الحالية
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditNoteScreen(note: note),
                          ),
                        );
                        if (result == true) {
                          _fetchNotesFromSupabase(); // تحديث القائمة عند العودة بحفظ ناجح
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // عنوان الملاحظة
                                  Text(
                                    note['title'] ?? '',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // محتوى الملاحظة
                                  Text(
                                    note['content'] ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDarkMode ? Colors.white70 : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // زر حذف الملاحظة المفردة
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () {
                                _showDeleteDialog(note['id']);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // ==========================================
      // [8] زر الإضافة العائم (Floating Action Button)
      // ==========================================
      floatingActionButton: FloatingActionButton(
        backgroundColor: fabColor,
        onPressed: () async {
          // الانتقال لشاشة التعديل/الإضافة لإنشاء ملاحظة جديدة
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EditNoteScreen(),
            ),
          );
          if (result == true) {
            _fetchNotesFromSupabase(); // تحديث القائمة بعد إضافة ملاحظة جديدة
          }
        },
        child: Icon(Icons.add, color: fabIconColor),
      ),
    );
  }
}