import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  void _navigateTo(String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final primaryColor = Colors.blue.shade700;
    final bgColor = Colors.blueGrey.shade900;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(28),
            top: Radius.zero,
          ),
        ),
        title: const Text(
          'Trang chính',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () async {
              await _auth.signOut();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome card
              Card(
                color: Colors.white,
                elevation: 8,
                shadowColor: primaryColor.withAlpha((0.4 * 255).round()),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  child: Text(
                    'Chào mừng, ${user!.email ?? 'Người dùng'}!',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Menu buttons list vertical
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: 4,
                  separatorBuilder: (_, __) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final labels = [
                      'Quản lý bộ flashcards',
                      'Học flashcards',
                      'Thống kê',
                      'Thông tin ứng dụng',
                    ];
                    final icons = [
                      Icons.collections_bookmark_rounded,
                      Icons.play_circle_fill_rounded,
                      Icons.bar_chart_rounded,
                      Icons.info_outline_rounded,
                    ];
                    final colors = [
                      primaryColor,
                      primaryColor.withAlpha((0.8 * 255).round()),
                      primaryColor.withAlpha((0.6  * 255).round()),
                      primaryColor.withAlpha((0.4 * 255).round()),
                    ];

                    return _buildMenuButton(
                      icon: icons[index],
                      label: labels[index],
                      color: colors[index],
                      onTap: () {
                        switch (index) {
                          case 0:
                            _navigateTo('/flashcard_sets');
                            break;
                          case 1:
                            _navigateTo('/study');
                            break;
                          case 2:
                            _navigateTo('/statistics');
                            break;
                          case 3:
                            showAboutDialog(
                              context: context,
                              applicationName: 'Flashcards App',
                              applicationVersion: '1.0.0',
                              applicationLegalese: '© 2025 Your Company',
                              applicationIcon: Icon(
                                Icons.flash_on_rounded,
                                size: 48,
                                color: primaryColor,
                              ),
                            );
                            break;
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      elevation: 8,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.white24,
        highlightColor: Colors.white12,
        onTap: onTap,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 3,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.white70,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
