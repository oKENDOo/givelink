import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // กำหนดสีฟ้าตามแบบ (สามารถปรับแก้รหัสสีให้ตรงเป๊ะได้ภายหลังครับ)
    const Color primaryBlue = Color(0xFF64B5C7); 

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // --- ส่วนบน: โลโก้ ---
          Expanded(
            child: Center(
              child: Image.asset(
                'assets/images/logo_name.png',
                width: 700,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // --- ส่วนล่าง: กล่องสีฟ้า ---
          Container(
            width: double.infinity,
            height: 310,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
            decoration: const BoxDecoration(
              color: primaryBlue,
              // ทำมุมโค้งมนที่ขอบบนซ้ายและขวา
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // ให้กล่องสูงเท่าที่จำเป็น
              children: [
                const Text(
                  'ยินดีต้อนรับ!',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'เพื่อเริ่มต้นแบ่งปันและเชื่อมต่อกับชุมชน\nกรุณาเข้าสู่ระบบด้วยบัญชีของคุณ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                
                // --- ปุ่ม 2 ปุ่ม ซ้าย-ขวา ---
                Row(
                  children: [
                    // ปุ่มเข้าสู่ระบบ (สีดำ)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // ให้ดันหน้า Login ขึ้นมา
                          context.push('/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: const Text('เข้าสู่ระบบ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16), // ระยะห่างระหว่างปุ่ม
                    // ปุ่มลงทะเบียน (สีขาว)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: นำไปหน้า Register
                          context.push('/register');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: const Text('ลงทะเบียน', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}