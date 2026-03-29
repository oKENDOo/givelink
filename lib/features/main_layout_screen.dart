import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/custom_bottom_nav.dart'; // 🌟 ดึง CustomBottomNav สีฟ้าของเรามาใช้

class MainLayoutScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayoutScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ไส้ในตรงกลาง จะเปลี่ยนไปตามที่เรากด
      body: navigationShell,
      
      // 🌟 เปลี่ยนจาก BottomNavigationBar ธรรมดา มาใช้ Custom ของเรา!
      bottomNavigationBar: CustomBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          // สั่งให้เปลี่ยนแค่ไส้ใน ไม่เปลี่ยนทั้งหน้า
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}