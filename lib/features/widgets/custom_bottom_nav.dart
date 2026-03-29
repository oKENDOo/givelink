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
    // 🌟 นำ SizedBox มาครอบเพื่อล็อคความสูงของแถบ Navbar
    return SizedBox(
      height: 88, 
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap, 
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF64B5C7), // พื้นหลังสีฟ้า Givelink
        selectedItemColor: Colors.white, // สีขาวตอนกดเลือก
        unselectedItemColor: Colors.black, // สีดำตอนไม่ได้เลือก
        selectedFontSize: 14, 
        unselectedFontSize: 12,
        
        // 🌟 1. เพิ่มบรรทัดนี้ เพื่อทำให้ตัวอักษรตอนที่ "ถูกเลือก" เป็นตัวหนา
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        
        // 🌟 2. เพิ่มบรรทัดนี้ เพื่อทำให้ตัวอักษรตอนที่ "ไม่ได้เลือก" เป็นตัวหนาด้วย
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