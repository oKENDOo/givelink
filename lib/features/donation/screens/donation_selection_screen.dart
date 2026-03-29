import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// 🌟 ตรวจสอบ Path ของ CustomBottomNav ให้ตรงกับโปรเจกต์ของคุณ
import '../../widgets/custom_bottom_nav.dart'; 

class DonationSelectionScreen extends StatefulWidget {
  const DonationSelectionScreen({super.key});

  @override
  State<DonationSelectionScreen> createState() => _DonationSelectionScreenState();
}

class _DonationSelectionScreenState extends State<DonationSelectionScreen> {
  final Color primaryTeal = const Color(0xFF64B5C7);
  
  // Set สำหรับเก็บชื่อหมวดหมู่ที่ถูกเลือก (เลือกได้หลายอัน)
  final Set<String> _selectedCategories = {};

  // Controller สำหรับช่องกรอกข้อความ "อื่นๆ"
  final TextEditingController _othersController = TextEditingController();

  // ข้อมูลหมวดหมู่และไอคอน (ใช้ Material Icon ที่ใกล้เคียงกับดีไซน์)
  final List<Map<String, dynamic>> _categories = [
    {'title': 'เสื้อผ้า', 'icon': Icons.checkroom},
    {'title': 'อาหารและน้ำ', 'icon': Icons.fastfood},
    {'title': 'ของเล่นเด็ก', 'icon': Icons.smart_toy},
    {'title': 'หนังสือ', 'icon': Icons.menu_book},
    {'title': 'อุปกรณ์\nการเรียน', 'icon': Icons.school}, // 🌟 เติม \n ตรงนี้
    {'title': 'อุปกรณ์\nสุขภาพ', 'icon': Icons.medical_services}, // 🌟 เติม \n ตรงนี้
    {'title': 'ของใช้\nส่วนตัว', 'icon': Icons.person}, // 🌟 เติม \n ตรงนี้
    {'title': 'ของใช้\nในบ้าน', 'icon': Icons.home}, // 🌟 เติม \n ตรงนี้
  ];

  @override
  void dispose() {
    _othersController.dispose();
    super.dispose();
  }

  // ฟังก์ชันสำหรับสลับสถานะการเลือกปุ่ม
  void _toggleCategory(String title) {
    setState(() {
      if (_selectedCategories.contains(title)) {
        _selectedCategories.remove(title);
      } else {
        _selectedCategories.add(title);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          // 🌟 ตรวจสอบ Path ของรูปภาพลูกศรย้อนกลับ
          icon: Image.asset('assets/icons/back_arrow.png', width: 35, height: 35),
          onPressed: () => context.pop(),
        ),
        title: const Text('1 / 5', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // หัวข้อ
                    const Center(
                      child: Text(
                        'คุณอยากบริจาคอะไรบ้าง ?',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Grid ของปุ่มเลือกหมวดหมู่
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(), // ปิดการเลื่อนซ้อนกัน
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 คอลัมน์
                        crossAxisSpacing: 16, // ระยะห่างแนวนอน
                        mainAxisSpacing: 30, // ระยะห่างแนวตั้ง
                        childAspectRatio: 2.3, // อัตราส่วนกว้างต่อสูงของปุ่ม (ปรับนิดหน่อยให้พอดี)
                      ),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = _selectedCategories.contains(cat['title']);

                        return GestureDetector(
                          onTap: () => _toggleCategory(cat['title']),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? primaryTeal : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? primaryTeal : Colors.grey.shade400,
                                width: 1.5,
                              ),
                            ),
                            // 🌟 แก้ไขส่วนนี้: ใช้ Padding ชิดซ้าย + ล็อคขนาดไอคอน
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0), // ดันให้ทุกปุ่มเริ่มจากขอบซ้ายเท่ากัน
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start, // จัดชิดซ้าย
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // 1. กล่องของไอคอน (ล็อคความกว้างไว้ที่ 45 เสมอ)
                                  SizedBox(
                                    width: 45, 
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Icon(
                                        cat['icon'],
                                        color: isSelected ? Colors.white : primaryTeal,
                                        size: 45, // ปรับขนาดไอคอนให้กำลังสวย
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8), // ช่องว่างระหว่างไอคอนกับข้อความ
                                  // 2. ส่วนของข้อความ
                                  Flexible(
                                    child: Text(
                                      cat['title'],
                                      textAlign: TextAlign.left, // จัดข้อความชิดซ้าย
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // ส่วนกรอกข้อความ "อื่นๆ"
                    const Text(
                      'อื่นๆ',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _othersController,
                      decoration: InputDecoration(
                        hintText: 'เช่น เฟอร์นิเจอร์เก่า ชุดเครื่องนอน',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryTeal, width: 2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ปุ่มขั้นตอนต่อไป
                    SizedBox(
                      width: double.infinity,
                      height: 65,
                      child: ElevatedButton(
                        onPressed: () {
                         // 🌟 ตรวจสอบว่าผู้ใช้เลือกอะไรบ้างหรือยัง
                          if (_selectedCategories.isEmpty && _othersController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('กรุณาเลือกสิ่งของหรือระบุในช่องอื่นๆ ก่อนไปต่อครับ')),
                            );
                            return; // หยุดการทำงานถ้ายังไม่เลือก
                          }

                          // 🌟 ส่งข้อมูลข้ามไปหน้า /donation_foundation
                          context.push(
                            '/donation_foundation',
                            extra: {
                              'categories': _selectedCategories.toList(),
                              'others': _othersController.text.trim(),
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ขั้นตอนต่อไป',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            SizedBox(width: 15,),
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
      
      // Navbar ใช้ CustomBottomNav ตัวเดิม
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
    );
  }
}