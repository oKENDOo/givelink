import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../widgets/custom_bottom_nav.dart';

class DonationDateScreen extends StatefulWidget {
  final String foundationName;
  final List<dynamic> selectedCategories; // รับเป็น dynamic หรือ String ก็ได้
  final String othersText;

  const DonationDateScreen({
    super.key,
    required this.foundationName,
    required this.selectedCategories,
    required this.othersText,
  });

  @override
  State<DonationDateScreen> createState() => _DonationDateScreenState();
}

class _DonationDateScreenState extends State<DonationDateScreen> {
  final Color primaryTeal = const Color(0xFF64B5C7);
  
  // ตัวแปรสำหรับปฏิทิน
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // 🌟 ฟังก์ชันแปลงชื่อหมวดหมู่กลับเป็น Icon
  IconData _getIconForCategory(String title) {
    switch (title) {
      case 'เสื้อผ้า': return Icons.checkroom;
      case 'อาหารและน้ำ': return Icons.fastfood;
      case 'ของเล่นเด็ก': return Icons.smart_toy;
      case 'หนังสือ': return Icons.menu_book;
      case 'อุปกรณ์\nการเรียน': return Icons.school;
      case 'อุปกรณ์\nสุขภาพ': return Icons.medical_services;
      case 'ของใช้\nส่วนตัว': return Icons.person;
      case 'ของใช้\nในบ้าน': return Icons.home;
      default: return Icons.card_giftcard;
    }
  }

  // 🌟 ฟังก์ชันแปลงวันที่เป็นภาษาไทย (พ.ศ.)
  String _formatThaiDate(DateTime? date) {
    if (date == null) return 'กรุณาเลือกวันที่จากปฏิทิน';
    
    final List<String> thaiMonths = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];
    
    final int buddhistYear = date.year + 543;
    return '${date.day} ${thaiMonths[date.month - 1]} $buddhistYear';
  }

  @override
  Widget build(BuildContext context) {
    // คำนวณการแสดงผลไอคอน (แสดงสูงสุด 3 อัน)
    int displayCount = widget.selectedCategories.length > 3 ? 3 : widget.selectedCategories.length;
    int overflowCount = widget.selectedCategories.length > 3 ? widget.selectedCategories.length - 3 : 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/icons/back_arrow.png', width: 35, height: 35),
          onPressed: () => context.pop(),
        ),
        title: const Text('3 / 5', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25)),
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
                    // --- 1. หัวข้อและสิ่งที่เลือก ---
                    const Center(
                      child: Text(
                        'คุณอยากบริจาคเมื่อไหร่ ?',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        'สิ่งของที่จะบริจาค',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryTeal),
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // แถวโชว์ไอคอน
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(displayCount, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(
                              _getIconForCategory(widget.selectedCategories[index].toString()),
                              color: primaryTeal,
                              size: 45,
                            ),
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
                    
                    if (widget.othersText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Center(
                          child: Text('อื่นๆ: ${widget.othersText}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                        ),
                      ),

                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        'ให้กับ ${widget.foundationName}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryTeal),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- 2. ส่วนปฏิทิน ---
                    const Text(
                      'เลือกวันที่คุณจะไปบริจาค',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(thickness: 1, height: 20),
                    
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 230, 250, 255).withOpacity(0.5), 
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: TableCalendar(
                        firstDay: DateTime.now(), // เริ่มจากวันนี้
                        lastDay: DateTime.now().add(const Duration(days: 365)), // ล่วงหน้าได้ 1 ปี
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false, // ซ่อนปุ่ม 2 weeks
                          titleCentered: false,
                          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
                        ),
                        calendarStyle: CalendarStyle(
                          selectedDecoration: BoxDecoration(color: primaryTeal, shape: BoxShape.circle),
                          todayDecoration: BoxDecoration(color: Colors.orangeAccent.shade200, shape: BoxShape.circle),
                          todayTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          defaultTextStyle: const TextStyle(color: Colors.black87),
                          weekendTextStyle: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- 3. กล่องแสดงวันที่เลือก ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: primaryTeal, width: 1.5),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'วันที่คุณเลือก:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatThaiDate(_selectedDay),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- 4. ปุ่มขั้นตอนต่อไป ---
                    SizedBox(
                      width: double.infinity,
                      height: 65,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_selectedDay == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('กรุณาเลือกวันที่ต้องการไปบริจาคก่อนครับ')),
                            );
                            return;
                          }
                          
                          // 🌟 ส่งข้อมูลทั้งหมด รวมถึงวันที่เลือก ไปหน้าอัปโหลดรูปภาพ
                          context.push('/donation_image', extra: {
                            'foundationName': widget.foundationName,
                            'selectedCategories': widget.selectedCategories,
                            'othersText': widget.othersText,
                            'selectedDate': _selectedDay, // ส่งวันที่ไปด้วย
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('ขั้นตอนต่อไป', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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