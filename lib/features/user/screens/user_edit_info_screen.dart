import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../widgets/custom_bottom_nav.dart';

class UserEditInfoScreen extends StatefulWidget {
  const UserEditInfoScreen({super.key});

  @override
  State<UserEditInfoScreen> createState() => _UserEditInfoScreenState();
}

class _UserEditInfoScreenState extends State<UserEditInfoScreen> {
  final Color primaryTeal = const Color(0xFF64B5C7);
  
  User? user;
  String userName = '';
  String email = '';
  String? photoUrl;
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userName = user?.displayName ?? user?.email?.split('@')[0] ?? 'ผู้ใช้งาน';
        email = user?.email ?? '';
        photoUrl = user?.photoURL;
      });
    }
  }

  // 🌟 ฟังก์ชันอัปโหลดรูปไป ImgBB (ใส่ timeout ป้องกันเน็ตค้าง)
  Future<String?> _uploadToImgBB(File imageFile) async {
    const String apiKey = "0f95841b75294557c99590bce575a91d"; 
    
    final Uri url = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');
    final request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    try {
      // เพิ่ม timeout 15 วินาที ป้องกันโหลดไม่รู้จบ
      final response = await request.send().timeout(const Duration(seconds: 15));
      final responseData = await response.stream.bytesToString();
      final jsonResult = jsonDecode(responseData);

      if (jsonResult['success']) {
        return jsonResult['data']['url']; 
      } else {
        debugPrint("ImgBB Upload Failed: ${jsonResult['error']['message']}");
        return null;
      }
    } catch (e) {
      debugPrint("Error uploading image: $e");
      return null;
    }
  }

  // 🌟 แก้ไขฟังก์ชันจัดการเลือกรูป (แก้บั๊ก Context และ BottomSheet)
  void _showImagePickerSheet() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null || !mounted) return;

    // 🌟 จำ Messenger ของหน้าหลักไว้ก่อน (เพื่อให้ SnackBar ไม่พังตอน BottomSheet ปิด)
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: primaryTeal,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                const Text('แก้ไขรูปโปรไฟล์', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                GestureDetector(onTap: () => Navigator.pop(sheetContext), child: const Icon(Icons.close, color: Colors.black, size: 28)),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(image: FileImage(File(image.path)), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  // 1. ปิด Bottom Sheet ก่อน (ใช้ sheetContext)
                  Navigator.pop(sheetContext);

                  // 2. โชว์กล่องโหลดติ้วๆ (ใช้ context หน้าหลัก)
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (dialogContext) => const Center(child: CircularProgressIndicator()),
                  );

                  // 3. เริ่มอัปโหลดรูป
                  String? imageUrl = await _uploadToImgBB(File(image.path));

                  // 4. อัปโหลดเสร็จแล้ว ให้ปิดกล่องโหลดติ้วๆ
                  if (context.mounted) {
                    Navigator.pop(context); 
                  }

                  // 5. สรุปผล
                  if (imageUrl != null) {
                    await user?.updatePhotoURL(imageUrl);
                    setState(() {
                      _pickedImage = File(image.path);
                      photoUrl = imageUrl;
                    });
                    // ใช้ messenger ที่จำไว้ตั้งแต่แรก ปลอดภัย 100%
                    scaffoldMessenger.showSnackBar(const SnackBar(content: Text('อัปเดตรูปโปรไฟล์สำเร็จ!')));
                  } else {
                    scaffoldMessenger.showSnackBar(const SnackBar(content: Text('อัปโหลดรูปล้มเหลว กรุณาลองใหม่')));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('บันทึกรูปภาพ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBottomSheet({
    required String title,
    required String currentValue,
    required bool isPassword,
    required Function(String) onSave,
  }) {
    final TextEditingController controller = TextEditingController(text: isPassword ? '' : currentValue);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: primaryTeal,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 24),
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  GestureDetector(onTap: () => Navigator.pop(sheetContext), child: const Icon(Icons.close, color: Colors.black, size: 28)),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                obscureText: isPassword,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: isPassword ? 'ป้อนรหัสผ่านใหม่' : '',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.black),
                    onPressed: () => controller.clear(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    onSave(controller.text.trim());
                    Navigator.pop(sheetContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('บันทึก', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateName(String newName) async {
    if (newName.isEmpty) return;
    try {
      await user?.updateDisplayName(newName);
      setState(() => userName = newName);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('อัปเดตชื่อผู้ใช้สำเร็จ')));
    } catch (e) {
      debugPrint("Error updating name: $e");
    }
  }

  Future<void> _updateEmail(String newEmail) async {
    if (newEmail.isEmpty || !newEmail.contains('@')) return;
    try {
      await user?.verifyBeforeUpdateEmail(newEmail); 
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ส่งอีเมลยืนยันการเปลี่ยนแปลงไปที่อีเมลใหม่แล้ว')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ไม่สามารถเปลี่ยนอีเมลได้ กรุณาล็อกอินใหม่อีกครั้ง')));
    }
  }

  Future<void> _updatePassword(String newPassword) async {
    if (newPassword.isEmpty || newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร')));
      return;
    }
    try {
      await user?.updatePassword(newPassword);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('อัปเดตรหัสผ่านสำเร็จ')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('กรุณาออกจากระบบและเข้าสู่ระบบใหม่อีกครั้งก่อนเปลี่ยนรหัสผ่าน')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/icons/back_arrow.png', width: 35, height: 35),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // --- 1. รูปโปรไฟล์ และ ปุ่มแก้ไขรูป ---
            Center(
              child: Column(
                children: [
                  // 🌟 เปลี่ยนมาใช้ ClipOval แทน เพื่อให้รองรับรูปเสีย/รูปไม่มี ได้ดีขึ้น
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: _pickedImage != null 
                        ? Image.file(_pickedImage!, fit: BoxFit.cover)
                        : (photoUrl != null && photoUrl!.isNotEmpty)
                            ? Image.network(
                                photoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 60, color: Colors.grey),
                              )
                            : Image.network(
                                'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 60, color: Colors.grey),
                              ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _showImagePickerSheet,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.image, size: 20, color: Colors.black87),
                        SizedBox(width: 6),
                        Text('แก้ไข', style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // --- 2. กล่องรายการข้อมูล ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    _buildListTile('ชื่อผู้ใช้', userName, false, () {
                      _showEditBottomSheet(
                        title: 'แก้ไขชื่อผู้ใช้', 
                        currentValue: userName, 
                        isPassword: false, 
                        onSave: _updateName,
                      );
                    }),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildListTile('อีเมล', email, false, () {
                      _showEditBottomSheet(
                        title: 'แก้ไขอีเมล', 
                        currentValue: email, 
                        isPassword: false, 
                        onSave: _updateEmail,
                      );
                    }),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildListTile('รหัสผ่าน', '********', true, () {
                      _showEditBottomSheet(
                        title: 'แก้ไขรหัสผ่าน', 
                        currentValue: '', 
                        isPassword: true, 
                        onSave: _updatePassword,
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 4),
    );
  }

  Widget _buildListTile(String title, String value, bool isPassword, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }
}