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
                width: 140,
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
                    // 🌟 สั่งให้ไปหน้าเลือกสิ่งของบริจาค
                    context.push('/donation_selection');
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
    );
  }
}