import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_note.dart';
import 'main.dart';
import 'app_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ==========================================
  // [1] متغيرات وحالات الشاشة
  // ==========================================
  List<Map<String, dynamic>> notes = [];
  List<Map<String, dynamic>> filteredNotes = [];
  bool isLoading = true;
  bool isSearching = false;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchNotesFromSupabase();
  }

  // ==========================================
  // [2] دالة جلب الملاحظات
  // ==========================================
  Future<void> _fetchNotesFromSupabase() async {
    setState(() => isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client
          .from('notes')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        notes = List<Map<String, dynamic>>.from(response);
        filteredNotes = notes;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching notes: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // ==========================================
  // [3] دالة فلترة الملاحظات (بالعنوان فقط)
  // ==========================================
  void _filterNotes(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredNotes = notes;
      } else {
        filteredNotes = notes
            .where((note) =>
            (note['title'] ?? '').toString().toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  // ==========================================
  // [4] دالة حذف الملاحظة
  // ==========================================
  Future<void> _deleteNote(dynamic noteId) async {
    try {
      await Supabase.instance.client
          .from('notes')
          .delete()
          .eq('id', noteId);
      _fetchNotesFromSupabase();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete note: $e")),
        );
      }
    }
  }

  void _showDeleteDialog(dynamic noteId) {
    final bool isDarkMode = themeNotifier.value == ThemeMode.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Delete Note",
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to delete this note?",
            style: TextStyle(
              color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteNote(noteId);
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // دالة لتسجيل الخروج والذهاب لصفحة اللوجن
  void _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = themeNotifier.value == ThemeMode.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.grey;
    final cardColor = isDarkMode ? Colors.grey[850] : Colors.grey.shade100;
    final fabColor = isDarkMode ? Colors.white : Colors.black;
    final fabIconColor = isDarkMode ? Colors.black : Colors.white;

    return AppScaffold(
      showBackButton: false,
      title: "",
      actions: [
        IconButton(
          icon: Icon(Icons.logout, color: subTextColor),
          tooltip: "Logout",
          onPressed: _logout,
        ),
        IconButton(
          icon: Icon(isSearching ? Icons.close : Icons.search, color: subTextColor),
          onPressed: () {
            setState(() {
              isSearching = !isSearching;
              if (!isSearching) {
                searchController.clear();
                filteredNotes = notes;
              }
            });
          },
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isSearching)
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: TextField(
                  controller: searchController,
                  autofocus: true,
                  onChanged: _filterNotes,
                  style: TextStyle(color: textColor, fontSize: 18),
                  decoration: InputDecoration(
                    hintText: "Search by title...",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: isDarkMode ? Colors.grey[500] : Colors.grey),
                  ),
                ),
              ),
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
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredNotes.isEmpty
                  ? Center(child: Text("No notes found.", style: TextStyle(color: subTextColor, fontSize: 14)))
                  : ListView.builder(
                itemCount: filteredNotes.length,
                itemBuilder: (context, index) {
                  final note = filteredNotes[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditNoteScreen(note: note)),
                        );
                        if (result == true) _fetchNotesFromSupabase();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(note['title'] ?? '', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                                  const SizedBox(height: 8),
                                  Text(note['content'] ?? '', style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.white70 : Colors.black54)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => _showDeleteDialog(note['id']),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: fabColor,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditNoteScreen()),
          );
          if (result == true) _fetchNotesFromSupabase();
        },
        child: Icon(Icons.add, color: fabIconColor),
      ),
    );
  }
}