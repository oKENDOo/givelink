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

  // ฟังก์ชันออกจากระบบ
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    // TODO: ใส่โค้ดนำทางกลับไปหน้า Login ตรงนี้
    // Navigator.of(context).pushReplacementNamed('/login'); 
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
                // TODO: นำทางกลับไปหน้า Login หลังลบสำเร็จ
              } catch (e) {
                // จัดการ Error เช่น ต้อง Login ใหม่ก่อนลบ
                print("Error deleting account: $e");
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
                      Icon(Icons.volunteer_activism, color: primaryBlue, size: 18), // เปลี่ยนเป็นโลโก้แอปคุณได้
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
                        // TODO: ใส่โค้ดนำทางไปหน้าแก้ไขข้อมูลส่วนบุคคล
                        print('ไปหน้า ข้อมูลส่วนบุคคล');
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
                      isDestructive: false, 
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // --- 3. ส่วน Bottom Navigation Bar ---
      bottomNavigationBar: Container(
        height: 70,
        color: primaryBlue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home, 'หน้าหลัก', onTap: () => context.push('/home')),
            _buildNavItem(Icons.location_on, 'แผนที่', onTap: () => context.push('/map')),
            
            // ปุ่มเพิ่มตรงกลาง
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
            // ตั้งค่า isActive เป็น true สำหรับหน้านี้
            _buildNavItem(Icons.person, 'ผู้ใช้', isActive: true),
          ],
        ),
      ),
    );
  }

  // Widget สำหรับสร้างปุ่มเมนูแต่ละอันให้หน้าตาเหมือนในรูป
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
            Icon(icon, size: 28, color: Colors.black),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // Widget สำหรับ Bottom Nav (ปรับปรุงให้กดได้)
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