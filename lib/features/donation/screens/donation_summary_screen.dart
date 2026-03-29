import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_bottom_nav.dart';

class DonationSummaryScreen extends StatelessWidget {
  final String foundationName;
  final List<dynamic> selectedCategories;
  final String othersText;
  final DateTime? selectedDate;
  final List<dynamic> selectedImages; // รับรูปภาพมาเป็น List<File>

  const DonationSummaryScreen({
    super.key,
    required this.foundationName,
    required this.selectedCategories,
    required this.othersText,
    required this.selectedDate,
    required this.selectedImages,
  });

  final Color primaryTeal = const Color(0xFF64B5C7);

  // ฟังก์ชันแปลงชื่อหมวดหมู่กลับเป็น Icon
  IconData _getIconForCategory(String title) {
    switch (title) {
      case 'เสื้อผ้า': return Icons.checkroom;
      case 'อาหารและน้ำ': return Icons.fastfood;
      case 'ของเล่นเด็ก': return Icons.smart_toy;
      case 'หนังสือ': return Icons.menu_book;
      case 'อุปกรณ์\nการเรียน': 
      case 'อุปกรณ์การเรียน': return Icons.school;
      case 'อุปกรณ์\nสุขภาพ': 
      case 'อุปกรณ์สุขภาพ': return Icons.medical_services;
      case 'ของใช้\nส่วนตัว': 
      case 'ของใช้ส่วนตัว': return Icons.person;
      case 'ของใช้\nในบ้าน': 
      case 'ของใช้ในบ้าน': return Icons.home;
      default: return Icons.card_giftcard;
    }
  }

  // ฟังก์ชันแปลงวันที่เป็นภาษาไทย
  String _formatThaiDate(DateTime? date) {
    if (date == null) return '';
    final List<String> thaiMonths = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];
    final int buddhistYear = date.year + 543;
    return '${date.day} ${thaiMonths[date.month - 1]} $buddhistYear';
  }

  // 🌟 ฟังก์ชันสร้างข้อความสรุปหมวดหมู่ (ใช้ "และ" แค่คำสุดท้าย)
  String _buildCategoriesString() {
    // เอาหมวดหมู่และช่องอื่นๆ มารวมกัน
    List<String> items = [...selectedCategories, if (othersText.isNotEmpty) othersText]
        .map((item) => item.toString().replaceAll('\n', '')) // เอา \n ออกให้หมดเพื่อให้อยู่บรรทัดเดียวกัน
        .toList();
    
    int n = items.length;
    if (n == 0) return '';
    if (n == 1) return items[0];
    if (n == 2) return '${items[0]} และ ${items[1]}';
    
    // ถ้ามี 3 อย่างขึ้นไป ให้คั่นด้วยลูกน้ำ แล้วใช้ และ ก่อนคำสุดท้าย
    String firstPart = items.sublist(0, n - 1).join(', ');
    return '$firstPart และ ${items[n - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    // 🌟 คำนวณการแสดงผลไอคอน (แสดงสูงสุด 3 อัน ถ้าเกินให้โชว์ +X)
    int displayCount = selectedCategories.length > 3 ? 3 : selectedCategories.length;
    int overflowCount = selectedCategories.length > 3 ? selectedCategories.length - 3 : 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/icons/back_arrow.png', width: 35, height: 35),
          onPressed: () => context.pop(),
        ),
        title: const Text('5 / 5', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. หัวข้อ ---
                    const Center(
                      child: Text('ตรวจสอบข้อมูลให้ถูกต้อง', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 20),

                    // --- 2. สิ่งของที่จะบริจาค ---
                    Center(child: Text('สิ่งของที่จะบริจาค', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryTeal))),
                    const SizedBox(height: 10),
                    
                    // 🌟 แถวโชว์ไอคอน (จำกัด 3 อัน พร้อม +X)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(displayCount, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(_getIconForCategory(selectedCategories[index].toString()), color: primaryTeal, size: 45),
                          );
                        }),
                        if (overflowCount > 0)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8.0),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                            child: Text('+$overflowCount', style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        _buildCategoriesString(),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Divider(height: 30, thickness: 1),

                    // --- 3. บริจาคให้กับ (จำลองข้อมูลจากชื่อที่ส่งมา) ---
                    Text('บริจาคให้กับ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryTeal)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(color: Colors.yellowAccent.shade700, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.people_alt, size: 40),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(foundationName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                  const Icon(Icons.check_circle, color: Colors.blue, size: 18),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text('อาหารและน้ำ/ของเล่นเด็ก/หนังสือ/เสื้อผ้า\n1.5 Km (10 นาที)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 4),
                              Row(
                                children: const [
                                  Icon(Icons.fastfood, color: Color(0xFF64B5C7), size: 18), SizedBox(width: 4),
                                  Icon(Icons.smart_toy, color: Color(0xFF64B5C7), size: 18), SizedBox(width: 4),
                                  Icon(Icons.menu_book, color: Color(0xFF64B5C7), size: 18), SizedBox(width: 4),
                                  Icon(Icons.checkroom, color: Color(0xFF64B5C7), size: 18),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30, thickness: 1),

                    // --- 4. ในวันที่ ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ในวันที่', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryTeal)),
                        const SizedBox(width: 20),
                        Expanded(child: Text(_formatThaiDate(selectedDate), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                      ],
                    ),
                    const Divider(height: 30, thickness: 1),

                    // --- 5. รูปภาพสิ่งของ ---
                    Text('รูปภาพสิ่งของ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryTeal)),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: selectedImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              selectedImages[index] as File,
                              width: double.infinity,
                              height: 300,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),

                    // --- 6. ปุ่มยืนยันข้อมูล ---
                    SizedBox(
                      width: double.infinity,
                      height: 65,
                      child: ElevatedButton(
                        onPressed: () {
                          // 🌟 กดแล้วไปหน้าความสำเร็จ
                          context.push('/donation_success');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('ยืนยันข้อมูล', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                            SizedBox(width: 15),
                            Icon(Icons.arrow_circle_right_outlined, color: Colors.white, size: 30),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
    );
  }
}