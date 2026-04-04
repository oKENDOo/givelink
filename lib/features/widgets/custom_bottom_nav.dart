import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap; 

  const CustomBottomNav({
    super.key, 
    required this.currentIndex,
    this.onTap, 
  });

  @override
  Widget build(BuildContext context) {
    // 🌟 1. ดึงระยะความสูงของขอบจอด้านล่าง (Safe Area / แถบ Home) ของมือถือแต่ละรุ่น
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      // 🌟 2. ปรับความสูงแบบไดนามิก: ความสูงฐาน (75) + ขอบล่างของมือถือเครื่องนั้นๆ
      // ถ้าเป็นมือถือจอธรรมดา bottomPadding จะเป็น 0 (สูง 75 ปกติ)
      // ถ้าเป็นมือถือจอยาว bottomPadding จะมีค่าเพิ่มขึ้น ทำให้ไม่เกิด Error Overflow
      height: 75 + bottomPadding, 
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap, 
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF64B5C7), // พื้นหลังสีฟ้า Givelink
        selectedItemColor: Colors.white, // สีขาวตอนกดเลือก
        unselectedItemColor: Colors.black, // สีดำตอนไม่ได้เลือก
        selectedFontSize: 14, 
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 30), label: 'หน้าหลัก'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on, size: 30), label: 'แผนที่'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 30), label: 'บริจาค'),
          BottomNavigationBarItem(icon: Icon(Icons.history, size: 30), label: 'ประวัติ'),
          BottomNavigationBarItem(icon: Icon(Icons.person, size: 30), label: 'ผู้ใช้'),
        ],
      ),
    );
  }
}