import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';
import 'app_scaffold.dart';

class EditNoteScreen extends StatefulWidget {
  final Map<String, dynamic>? note;

  const EditNoteScreen({Key? key, this.note}) : super(key: key);

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note?['title'] ?? '');
    contentController = TextEditingController(text: widget.note?['content'] ?? '');
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_isSaving) return;
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty && content.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (widget.note == null) {
        await Supabase.instance.client.from('notes').insert({
          'title': title,
          'content': content,
          'user_id': user?.id ?? '',
        });
      } else {
        await Supabase.instance.client.from('notes').update({
          'title': title,
          'content': content,
        }).eq('id', widget.note!['id']);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // نافذة الحوار مترجمة بالكامل إلى الإنجليزية (Save Changes)
  Future<bool> _handlePop() async {
    if (titleController.text.trim().isEmpty && contentController.text.trim().isEmpty) {
      return true;
    }

    final bool? shouldPop = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final bool isDarkMode = themeNotifier.value == ThemeMode.dark;
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Save Changes",
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Do you want to save changes before leaving?",
            style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.grey[800]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Don't Save", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () async {
                await _saveNote();
                if (context.mounted) Navigator.of(context).pop(true);
              },
              child: const Text("Save", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
    return shouldPop ?? false;
  }

  Future<void> _onBackPressed() async {
    final shouldPop = await _handlePop();
    if (shouldPop && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = themeNotifier.value == ThemeMode.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final inputFillColor = isDarkMode ? Colors.grey[850] : Colors.grey.shade100;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _handlePop();
        if (shouldPop && mounted) {
          Navigator.of(context).pop(true);
        }
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: textColor, size: 20),
            onPressed: _onBackPressed,
          ),
          title: Text(
            widget.note == null ? "Add Note" : "Edit Note",
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Title", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: inputFillColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              Text("Content", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 8),
              TextField(
                controller: contentController,
                maxLines: 5,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: inputFillColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? Colors.white : Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isSaving
                      ? null
                      : () async {
                    await _saveNote();
                    if (mounted) Navigator.pop(context, true);
                  },
                  child: _isSaving
                      ? const CircularProgressIndicator()
                      : Text("Save", style: TextStyle(color: isDarkMode ? Colors.black : Colors.white)),
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