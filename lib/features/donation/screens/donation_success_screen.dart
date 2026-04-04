import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DonationSuccessScreen extends StatelessWidget {
  const DonationSuccessScreen({super.key});

  final Color primaryTeal = const Color(0xFF64B5C7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- โลโก้ ---
                Image.asset(
                  'assets/images/logo_crop.png', 
                  width: 140,
                  height: 140,
                ),
                const SizedBox(height: 30),

                // --- ข้อความสำเร็จ ---
                const Text(
                  'การจองบริจาคกับ\nมูลนิธิของคุณสำเร็จแล้ว!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 40),

                // --- ปุ่มดูประวัติการบริจาค (ปุ่มหลัก) ---
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('/history');
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
                          'ดูประวัติการบริจาค',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_circle_right_outlined, color: Colors.white, size: 28),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16), // เว้นระยะห่างระหว่างปุ่ม

                // --- 🌟 ปุ่มจองการบริจาคอีกครั้ง (ปุ่มรอง) ---
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: OutlinedButton(
                    onPressed: () {
                      // กระโดดไปหน้าเริ่มจองบริจาค
                      context.go('/donation_start');
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryTeal, width: 2), // ขอบสีฟ้า
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'จองการบริจาคอีกครั้ง',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryTeal,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.add_circle_outline, color: primaryTeal, size: 28),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}