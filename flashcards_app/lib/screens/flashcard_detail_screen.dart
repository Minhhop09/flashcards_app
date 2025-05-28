import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class FlashcardDetailScreen extends StatefulWidget {
  final String setId;
  final String setName;

  const FlashcardDetailScreen({
    super.key,
    required this.setId,
    required this.setName,
  });

  @override
  State<FlashcardDetailScreen> createState() => _FlashcardDetailScreenState();
}

class _FlashcardDetailScreenState extends State<FlashcardDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (text.trim().isEmpty) return;
    await flutterTts.setLanguage('en-US'); // giữ phát âm tiếng Anh
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  Future<void> _showCreateOrEditFlashcardDialog({
    String? currentWord,
    String? currentMeaning,
    String? currentNote,
    String? currentExample,
    String? docId,
  }) async {
    String word = currentWord ?? '';
    String meaning = currentMeaning ?? '';
    String note = currentNote ?? '';
    String example = currentExample ?? '';

    final wordController = TextEditingController(text: word);
    final meaningController = TextEditingController(text: meaning);
    final noteController = TextEditingController(text: note);
    final exampleController = TextEditingController(text: example);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          docId == null ? 'Thêm flashcard mới' : 'Sửa flashcard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.blue.shade700,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                controller: wordController,
                label: 'Từ vựng',
                icon: Icons.language,
                onChanged: (val) => word = val,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: meaningController,
                label: 'Nghĩa',
                icon: Icons.translate,
                onChanged: (val) => meaning = val,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: noteController,
                label: 'Ghi chú',
                icon: Icons.note,
                onChanged: (val) => note = val,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: exampleController,
                label: 'Ví dụ',
                icon: Icons.menu_book,
                onChanged: (val) => example = val,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () {
              if (mounted) Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.blue.shade700),
            child: const Text('Huỷ', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (word.trim().isEmpty || meaning.trim().isEmpty) return;

              final collectionRef = _firestore
                  .collection('flashcard_sets')
                  .doc(widget.setId)
                  .collection('flashcards');

              if (docId == null) {
                await collectionRef.add({
                  'word': word.trim(),
                  'meaning': meaning.trim(),
                  'note': note.trim(),
                  'example': example.trim(),
                  'createdAt': FieldValue.serverTimestamp(),
                });
                logger.i('Đã tạo flashcard mới trong bộ ${widget.setId}');
              } else {
                await collectionRef.doc(docId).update({
                  'word': word.trim(),
                  'meaning': meaning.trim(),
                  'note': note.trim(),
                  'example': example.trim(),
                });
                logger.i(
                  'Đã cập nhật flashcard id=$docId trong bộ ${widget.setId}',
                );
              }

              if (!mounted) return;
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Text(docId == null ? 'Thêm' : 'Lưu'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade700),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        ),
      ),
      onChanged: onChanged,
    );
  }

  Future<void> _deleteFlashcard(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Xác nhận',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.red.shade700,
          ),
        ),
        content: const Text('Bạn có chắc chắn muốn xoá flashcard này?'),
        actions: [
          TextButton(
            onPressed: () {
              if (mounted) Navigator.pop(context, false);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.blue.shade700),
            child: const Text('Huỷ', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () {
              if (mounted) Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firestore
          .collection('flashcard_sets')
          .doc(widget.setId)
          .collection('flashcards')
          .doc(docId)
          .delete();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã xoá flashcard'),
          backgroundColor: Colors.blue.shade700,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      logger.i('Đã xoá flashcard id=$docId trong bộ ${widget.setId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flashcards: ${widget.setName}'),
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Thêm flashcard mới',
            onPressed: () => _showCreateOrEditFlashcardDialog(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('flashcard_sets')
            .doc(widget.setId)
            .collection('flashcards')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            logger.e('Lỗi Firestore: ${snapshot.error}');
            return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Text(
                'Bộ flashcards chưa có thẻ nào.',
                style: TextStyle(fontSize: 18, color: Colors.blue.shade400),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data()! as Map<String, dynamic>;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadowColor: Colors.blue.shade200,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          data['word'] ?? 'Từ trống',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.volume_up,
                          color: Colors.blue.shade700,
                        ),
                        onPressed: () => _speak(data['word'] ?? ''),
                        tooltip: 'Phát âm từ',
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nghĩa: ${data['meaning'] ?? ''}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        if (data['note'] != null &&
                            data['note'].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'Ghi chú: ${data['note']}',
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.blue.shade400,
                              ),
                            ),
                          ),
                        if (data['example'] != null &&
                            data['example'].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'Ví dụ: ${data['example']}',
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.blue.shade600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue.shade700),
                        tooltip: 'Sửa flashcard',
                        onPressed: () => _showCreateOrEditFlashcardDialog(
                          currentWord: data['word'],
                          currentMeaning: data['meaning'],
                          currentNote: data['note'],
                          currentExample: data['example'],
                          docId: doc.id,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red.shade700),
                        tooltip: 'Xoá flashcard',
                        onPressed: () => _deleteFlashcard(doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
