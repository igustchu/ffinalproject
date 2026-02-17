import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/custom_header.dart';
import 'item_detail_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  // ตัวแปรสำหรับ Filter
  String selectedCategory = 'ทั้งหมด';
  final List<String> categories = [
    'ทั้งหมด',
    'ผัก',
    'เนื้อสัตว์',
    'นมและไข่',
    'ผลไม้',
  ];

  // ตัวแปร Search
  String searchQuery = '';

  // Stream สำหรับดึงข้อมูล (เปลี่ยนจาก final เป็น late เพื่อให้รีโหลดได้)
  late Stream<List<Map<String, dynamic>>> _ingredientsStream;

  @override
  void initState() {
    super.initState();
    _refreshData(); // โหลดข้อมูลครั้งแรก
  }

  // ✅ ฟังก์ชันโหลดข้อมูลใหม่ (ใช้เรียกตอนกลับมาจากหน้าแก้ไข)
  void _refreshData() {
    setState(() {
      _ingredientsStream = Supabase.instance.client
          .from('ingredients')
          .stream(primaryKey: ['id'])
          .order('expiry_date', ascending: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      body: Column(
        children: [
          const CustomHeader(
            title: "Remote Inventory",
            subtitle: "เช็คของในตู้เย็นจากที่ไหนก็ได้",
            showBack: true,
          ),

          // Search & Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFFFF9E6),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => setState(() => searchQuery = value),
                  decoration: InputDecoration(
                    hintText: "ค้นหาวัตถุดิบ...",
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((category) {
                      final isSelected = selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: Colors.orange,
                          backgroundColor: Colors.white,
                          onSelected: (bool selected) {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.orange
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Inventory List
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _ingredientsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allIngredients = snapshot.data!;
                final filteredIngredients = allIngredients.where((item) {
                  final matchesCategory =
                      selectedCategory == 'ทั้งหมด' ||
                      (item['category'] ?? '').toString().contains(
                        selectedCategory,
                      );
                  final matchesSearch = (item['name'] ?? '')
                      .toString()
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());
                  return matchesCategory && matchesSearch;
                }).toList();

                // Summary Data
                final totalItems = filteredIngredients.length;
                final expiringSoon = filteredIngredients
                    .where((i) => _getDaysRemaining(i['expiry_date']) <= 3)
                    .length;
                final lowStock = filteredIngredients
                    .where((i) => (i['quantity'] ?? 0) == 0)
                    .length;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ...filteredIngredients.map(
                      (item) => _buildInventoryCard(item),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "สรุปภาพรวม",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildSummaryItem(
                                "$totalItems",
                                "รายการทั้งหมด",
                                Colors.orange,
                              ),
                              _buildSummaryItem(
                                "$expiringSoon",
                                "ใกล้หมดอายุ",
                                Colors.deepOrange,
                              ),
                              _buildSummaryItem(
                                "$lowStock",
                                "ของเหลือน้อย",
                                Colors.pinkAccent,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryCard(Map<String, dynamic> item) {
    final name = item['name'] ?? 'ไม่ระบุ';
    final quantity = item['quantity'] ?? 0;
    final maxQuantity = item['max_quantity'] ?? quantity;
    final unit = item['unit'] ?? 'ชิ้น';
    final expiryDateStr = item['expiry_date'];

    final daysRemaining = _getDaysRemaining(expiryDateStr);
    final isExpiringSoon = daysRemaining <= 3;
    final progress = (quantity / (maxQuantity == 0 ? 1 : maxQuantity)).clamp(
      0.0,
      1.0,
    );

    Color statusColor = Colors.green;
    String statusText = "เพียงพอ";
    if (progress < 0.3) {
      statusColor = Colors.red;
      statusText = "เหลือน้อย";
    } else if (progress < 0.7) {
      statusColor = Colors.orange;
      statusText = "ปานกลาง";
    }

    return GestureDetector(
      onTap: () async {
        // ✅ ไปหน้าแก้ไข และรอรับค่ากลับมา
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ItemDetailScreen(item: item)),
        );

        // ✅ ถ้ามีการแก้ไข (result == true) ให้โหลดข้อมูลใหม่ทันที
        if (result == true) {
          _refreshData();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          _buildTag(
                            statusText,
                            statusColor.withOpacity(0.2),
                            Colors.black87,
                          ),
                          if (isExpiringSoon && daysRemaining >= 0) ...[
                            const SizedBox(width: 5),
                            _buildTag(
                              "เหลือ $daysRemaining วัน",
                              Colors.red.withOpacity(0.2),
                              Colors.red,
                            ),
                          ],
                          if (daysRemaining < 0) ...[
                            const SizedBox(width: 5),
                            _buildTag(
                              "หมดอายุแล้ว",
                              Colors.grey.withOpacity(0.2),
                              Colors.grey,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "$quantity $unit",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "จาก $maxQuantity $unit",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress.toDouble(),
                backgroundColor: Colors.grey[200],
                color: statusColor,
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }

  int _getDaysRemaining(String? dateStr) {
    if (dateStr == null) return 999;
    try {
      final expiry = DateTime.parse(dateStr);
      final now = DateTime.now();
      return expiry.difference(now).inDays;
    } catch (e) {
      return 999;
    }
  }
}
