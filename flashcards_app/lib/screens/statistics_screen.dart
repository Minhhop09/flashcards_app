import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, int> setCounts = {};
  bool isLoading = true;

  // Danh sách màu cho cột biểu đồ, sẽ lặp lại nếu bộ quá nhiều
  final List<Color> barColors = [
    Colors.blue.shade300,
    Colors.green.shade300,
    Colors.orange.shade300,
    Colors.purple.shade300,
    Colors.red.shade300,
    Colors.teal.shade300,
    Colors.amber.shade300,
  ];

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    final userId = user.uid;

    try {
      QuerySnapshot setsSnap = await _firestore
          .collection('flashcard_sets')
          .where('ownerId', isEqualTo: userId)
          .get();

      Map<String, int> tempCounts = {};

      for (var setDoc in setsSnap.docs) {
        final setName =
            (setDoc.data() as Map<String, dynamic>)['name'] ?? 'Không tên';
        final flashcardsSnap = await _firestore
            .collection('flashcard_sets')
            .doc(setDoc.id)
            .collection('flashcards')
            .get();

        tempCounts[setName] = flashcardsSnap.docs.length;
      }

      setState(() {
        setCounts = tempCounts;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Lỗi tải dữ liệu thống kê: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Colors.blue.shade50;

    final maxCount = setCounts.values.isEmpty
        ? 10.0
        : (setCounts.values.reduce((a, b) => a > b ? a : b) + 3).toDouble();

    final sets = setCounts.keys.toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Text(
          'Thống kê flashcards theo bộ',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        elevation: 6,
        shadowColor: Colors.blue.shade200,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : setCounts.isEmpty
            ? Center(
                child: Text(
                  'Bạn chưa có bộ flashcards nào.',
                  style: TextStyle(fontSize: 18, color: Colors.blue.shade700),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Số flashcards trong từng bộ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: sets.length < 4 ? 1 : sets.length / 3,
                      child: BarChart(
                        BarChartData(
                          maxY: maxCount,
                          barGroups: List.generate(sets.length, (index) {
                            final count = setCounts[sets[index]]!.toDouble();
                            final barColor =
                                barColors[index % barColors.length];
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: count,
                                  color: barColor,
                                  width: 26,
                                  borderRadius: BorderRadius.circular(10),
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY: maxCount,
                                    color: barColor.withAlpha(
                                      (0.15 * 255).toInt(),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 70,
                                getTitlesWidget: (value, meta) {
                                  int idx = value.toInt();
                                  if (idx < 0 || idx >= sets.length) {
                                    return const SizedBox();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      sets[idx],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                interval: 2,
                                getTitlesWidget: (value, meta) {
                                  if (value % 2 != 0) return const SizedBox();
                                  return Text(
                                    value.toInt().toString(),
                                    style: TextStyle(
                                      color: Colors.blue.shade700.withAlpha(
                                        180,
                                      ),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 2,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Colors.blue.shade700.withAlpha(25),
                              strokeWidth: 1.2,
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              tooltipBgColor: Colors.blue.shade700.withAlpha(
                                230,
                              ),
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                return BarTooltipItem(
                                  '${sets[group.x.toInt()]}\n${rod.toY.toInt()} flashcards',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
