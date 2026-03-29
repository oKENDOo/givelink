import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final Color primaryBlue = const Color(0xFF64B5C7);
  String userName = 'ผู้ใช้งาน';
  String? photoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userName = user.displayName ?? user.email?.split('@')[0] ?? 'ผู้ใช้งาน';
        photoUrl = user.photoURL;
      });
    }
  }

  // 🌟 ฟังก์ชันออกจากระบบ (แก้ไขให้มียืนยันและไปหน้า Welcome)
  Future<void> _signOut() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการออกจากระบบ'),
        content: const Text('คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ?'),
        actions: [
          // ปุ่มยกเลิก
          TextButton(
            onPressed: () => Navigator.pop(context), // ปิดหน้าต่าง Popup
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          // ปุ่มยืนยันออกจากระบบ
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // ปิดหน้าต่าง Popup ก่อน
              await FirebaseAuth.instance.signOut(); // สั่งออกจากระบบ Firebase
              
              if (mounted) {
                // 🌟 ใช้ context.go เพื่อลบประวัติเก่าทิ้ง ไม่ให้กดย้อนกลับมาได้
                context.go('/welcome'); 
              }
            },
            child: const Text('ออกจากระบบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันลบบัญชี
  Future<void> _deleteAccount() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบบัญชี'),
        content: const Text('คุณแน่ใจหรือไม่ว่าต้องการลบบัญชีผู้ใช้? ข้อมูลทั้งหมดจะไม่สามารถกู้คืนได้'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.currentUser?.delete();
                if (mounted) {
                  context.go('/welcome'); // 🌟 ลบเสร็จให้กลับไปหน้า Welcome เหมือนกัน
                }
              } catch (e) {
                print("Error deleting account: $e");
                // ถ้า Error มักจะเกิดจากต้องให้ผู้ใช้ Login ใหม่ก่อนเพื่อความปลอดภัย
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('กรุณาออกจากระบบและเข้าสู่ระบบใหม่อีกครั้งก่อนทำการลบบัญชี')),
                  );
                }
              }
            },
            child: const Text('ลบบัญชี', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // --- 1. ส่วนรูปโปรไฟล์และชื่อ ---
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: photoUrl != null 
                        ? NetworkImage(photoUrl!) 
                        : const NetworkImage('https://cdn-icons-png.flaticon.com/512/3135/3135715.png') as ImageProvider,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  
                  // จำนวนการบริจาค
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.volunteer_activism, color: primaryBlue, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'จำนวนการบริจาค 0 ครั้ง',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),

            // --- 2. ส่วนเมนูตัวเลือก ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildMenuOption(
                      icon: Icons.person,
                      title: 'ข้อมูลส่วนบุคคล',
                      onTap: () {
                        // 🌟 กดแล้วพาไปหน้าแก้ไขข้อมูล
                        context.push('/user_edit');
                      },
                    ),
                    _buildMenuOption(
                      icon: Icons.logout,
                      title: 'ออกจากระบบ',
                      onTap: _signOut, // 🌟 เรียกใช้ฟังก์ชันที่แก้ใหม่
                    ),
                    _buildMenuOption(
                      icon: Icons.delete,
                      title: 'ลบบัญชีผู้ใช้',
                      onTap: _deleteAccount,
                      isDestructive: true, // ทำให้ไอคอนลบเป็นสีแดงได้ (ปรับให้ตรงกับโค้ดด้านล่าง)
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget สำหรับสร้างปุ่มเมนูแต่ละอัน
  Widget _buildMenuOption({
    required IconData icon, 
    required String title, 
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: isDestructive ? Colors.red : Colors.black),
            const SizedBox(width: 20),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: isDestructive ? Colors.red : Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}