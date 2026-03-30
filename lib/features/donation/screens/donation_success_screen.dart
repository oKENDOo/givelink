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

                // --- ปุ่มดูประวัติการบริจาค ---
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      // 🌟 1. สั่งให้ Tab บริจาค "กดย้อนกลับ" (Pop) รัวๆ จนกว่าจะถึงหน้าแรก (/donation_start)
                      while (context.canPop()) {
                        context.pop();
                      }
                      
                      // 🌟 2. เมื่อล้างหน้าจอเสร็จแล้ว ค่อยสั่งให้สลับไปที่หน้าประวัติ (History)
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}