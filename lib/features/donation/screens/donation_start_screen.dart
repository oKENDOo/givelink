import 'package:go_router/go_router.dart'; // 🌟 นำเข้า go_router สำหรับการเปลี่ยนหน้า
import 'package:flutter/material.dart';

class DonationStartScreen extends StatelessWidget {
  const DonationStartScreen({Key? key}) : super(key: key);

  // กำหนดสีหลักที่ใช้ในแอป (สีฟ้าอมเขียวตามภาพ)
  final Color primaryTeal = const Color(0xFF64B5C7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. โลโก้แอปพลิเคชัน
              Image.asset(
                'assets/images/logo_crop.png',
                height: 140,
              ),

              SizedBox(height: 10),

              // 2. คำชวน
              const Text(
                '“พร้อมแบ่งปันแล้วหรือยัง?”',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),

              // 3. ปุ่มกด "เริ่มจองการบริจาค"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: ใส่ Action เมื่อกดปุ่ม เช่น นำทางไปหน้ากรอกฟอร์มหรือหน้าอัปโหลดรูปภาพ
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'เริ่มจองการบริจาค',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(
                        Icons.arrow_circle_right_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // 4. Navigation Bar ด้านล่าง (ปรับให้เหมือน user_screen.dart)
      bottomNavigationBar: Container(
        height: 70, // 🌟 ปรับความสูงเป็น 70 เหมือนหน้า user_screen
        color: primaryTeal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home, 'หน้าหลัก', onTap: () => context.push('/home')),
            _buildNavItem(Icons.location_on, 'แผนที่', onTap: () => context.push('/map')),
            
            // ปุ่มเพิ่มตรงกลาง (เนื่องจากอยู่หน้านี้แล้ว เลยไม่ต้องใส่ context.push)
             
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.add, color: Colors.black, size: 36),
              ),
            
            
            _buildNavItem(Icons.history, 'ประวัติ', onTap: () => context.push('/history')),
            // 🌟 เปลี่ยน isActive เป็น false และใส่ onTap เพื่อให้กดกลับไปหน้าผู้ใช้ได้
            _buildNavItem(Icons.person, 'ผู้ใช้', onTap: () => context.push('/user')),
          ],
        ),
      ),
    );
  }

  // Widget สำหรับ Bottom Nav (เหมือนของ user_screen.dart)
  Widget _buildNavItem(IconData icon, String label, {bool isActive = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
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