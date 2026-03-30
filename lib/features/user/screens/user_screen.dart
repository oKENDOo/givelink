import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 🌟 เพิ่ม Import Firestore สำหรับดึงข้อมูล

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

  // ฟังก์ชันออกจากระบบ 
  Future<void> _signOut() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการออกจากระบบ'),
        content: const Text('คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); 
              await FirebaseAuth.instance.signOut(); 
              
              if (mounted) {
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
                  context.go('/welcome'); 
                }
              } catch (e) {
                print("Error deleting account: $e");
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
                  
                  // 🌟 จำนวนการบริจาค (ดึงข้อมูลจริงจาก Firestore)
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('DonationBookings')
                        .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      int donationCount = 0;

                      if (snapshot.hasData) {
                        // กรองนับเฉพาะรายการที่กำลังดำเนินการ และ เสร็จสิ้น
                        donationCount = snapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final status = data['status'] ?? '';
                          return  status == 'completed' || status == 'success';
                        }).length;
                      }

                     // ... ส่วน StreamBuilder ด้านบน ...
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ✅ โค้ดใหม่ (ใช้รูปโลโก้แทนไอคอน)
                          Image.asset(
                            'assets/images/logo_crop.png', 
                            width: 24, // กำหนดความกว้างให้เหมาะสม
                            height: 24, // กำหนดความสูงให้เหมาะสม
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'จำนวนการบริจาค $donationCount ครั้ง',
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      );
// ...
                    },
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
                        context.push('/user_edit');
                      },
                    ),
                    _buildMenuOption(
                      icon: Icons.logout,
                      title: 'ออกจากระบบ',
                      onTap: _signOut, 
                    ),
                    _buildMenuOption(
                      icon: Icons.delete,
                      title: 'ลบบัญชีผู้ใช้',
                      onTap: _deleteAccount,
                      isDestructive: true, 
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