import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNav extends StatelessWidget {
  // รับค่าว่าตอนนี้อยู่หน้าไหน (0=หน้าหลัก, 1=แผนที่, 2=ปุ่มบวก, 3=ประวัติ, 4=ผู้ใช้)
  final int currentIndex; 

  const CustomBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF64B5C7);

    return Container(
      height: 70,
      color: primaryBlue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // หน้าหลัก (Index 0)
          _buildNavItem(context, Icons.home, 'หน้าหลัก', 0, '/home'),
          
          // แผนที่ (Index 1)
          _buildNavItem(context, Icons.location_on, 'แผนที่', 1, '/map'),
          
          // ปุ่มเพิ่มตรงกลาง (Index 2)
          GestureDetector(
            onTap: () {
              // ถ้าไม่ได้อยู่หน้าบริจาคอยู่แล้ว ค่อยให้กดไปได้
              if (currentIndex != 2) context.push('/donation_start');
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add, color: Colors.black, size: 36),
            ),
          ),
          
          // ประวัติ (Index 3)
          _buildNavItem(context, Icons.history, 'ประวัติ', 3, '/history'),
          
          // ผู้ใช้ (Index 4)
          _buildNavItem(context, Icons.person, 'ผู้ใช้', 4, '/user'),
        ],
      ),
    );
  }

  // ฟังก์ชันย่อยสำหรับสร้างปุ่ม
  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index, String route) {
    final bool isActive = currentIndex == index; // เช็กว่าปุ่มนี้คือหน้าปัจจุบันไหม
    
    return GestureDetector(
      onTap: () {
        // ถ้ากดปุ่มที่ไม่ได้แอคทีฟอยู่ ให้เปลี่ยนหน้าไปที่ route นั้น
        if (!isActive) {
          context.push(route);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? Colors.white : Colors.black87, size: 28),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black87,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}