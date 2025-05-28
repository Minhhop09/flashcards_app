import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class FlashcardSetsScreen extends StatefulWidget {
  const FlashcardSetsScreen({super.key});

  @override
  State<FlashcardSetsScreen> createState() => _FlashcardSetsScreenState();
}

class _FlashcardSetsScreenState extends State<FlashcardSetsScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final List<Color> cardColors = [
    const Color(0xffa2d5c6), // xanh ngọc
    const Color(0xfff8b400), // vàng
    const Color(0xfff67280), // hồng cam
    const Color(0xff6a4c93), // tím
    const Color(0xff119da4), // xanh dương
    const Color(0xffb5b682), // xám xanh nhạt
    const Color(0xfff28482), // đỏ cam
  ];

  Future<void> _showCreateOrEditSetDialog({
    String? currentName,
    String? docId,
  }) async {
    String setName = currentName ?? '';
    final controller = TextEditingController(text: setName);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          docId == null ? 'Tạo bộ flashcards mới' : 'Sửa bộ flashcards',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.blueAccent,
          ),
        ),
        content: TextField(
          autofocus: true,
          controller: controller,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          autocorrect: true,
          enableSuggestions: true,
          decoration: InputDecoration(
            labelText: 'Tên bộ flashcards',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.folder, color: Colors.blueAccent),
          ),
          onChanged: (value) => setName = value,
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blueAccent,
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (setName.trim().isEmpty) return;
              final userId = _auth.currentUser?.uid;
              if (userId == null) {
                logger.w('User chưa đăng nhập');
                return;
              }

              if (docId == null) {
                await _firestore.collection('flashcard_sets').add({
                  'name': setName.trim(),
                  'ownerId': userId,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                logger.i('Đã tạo bộ flashcards: $setName');
              } else {
                await _firestore.collection('flashcard_sets').doc(docId).update(
                  {'name': setName.trim()},
                );
                logger.i('Đã cập nhật bộ flashcards id=$docId');
              }

              if (!mounted) return;
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Text(docId == null ? 'Tạo' : 'Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSet(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Xác nhận',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: const Text('Bạn có chắc chắn muốn xoá bộ flashcards này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blueAccent,
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 82, 154, 255),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
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
      await _firestore.collection('flashcard_sets').doc(docId).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã xoá bộ flashcards'),
          backgroundColor: Colors.blueAccent,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      logger.i('Đã xoá bộ flashcards id=$docId');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final userId = user.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 6,
        title: const Text('Bộ Flashcards của tôi'),
        centerTitle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
          tooltip: 'Quay lại Home',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 28),
            tooltip: 'Tạo bộ mới',
            onPressed: () => _showCreateOrEditSetDialog(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('flashcard_sets')
              .where('ownerId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              logger.e('Firestore error: ${snapshot.error}');
              return Center(
                child: Text(
                  'Lỗi tải dữ liệu: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return Center(
                child: Text(
                  'Bạn chưa có bộ flashcards nào.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueAccent.shade200,
                  ),
                ),
              );
            }

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data()! as Map<String, dynamic>;
                final name = data['name'] ?? 'Tên trống';

                return FutureBuilder<QuerySnapshot>(
                  future: _firestore
                      .collection('flashcard_sets')
                      .doc(doc.id)
                      .collection('flashcards')
                      .get(),
                  builder: (context, cardsSnapshot) {
                    int cardCount = 0;
                    if (cardsSnapshot.hasData) {
                      cardCount = cardsSnapshot.data!.docs.length;
                    }
                    final bgColor = cardColors[index % cardColors.length];

                    return Card(
                      color: bgColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6,
                      child: Stack(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/flashcard_detail',
                                arguments: {'setId': doc.id, 'setName': name},
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                20,
                                20,
                                60,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '$cardCount flashcards',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                  tooltip: 'Sửa bộ flashcards',
                                  onPressed: () => _showCreateOrEditSetDialog(
                                    currentName: name,
                                    docId: doc.id,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                  tooltip: 'Xoá bộ flashcards',
                                  onPressed: () => _deleteSet(doc.id),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateOrEditSetDialog(),
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add),
        tooltip: 'Tạo bộ flashcards mới',
      ),
    );
  }
}
