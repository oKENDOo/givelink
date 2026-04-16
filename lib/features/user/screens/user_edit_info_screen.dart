import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class UserEditInfoScreen extends StatefulWidget {
  const UserEditInfoScreen({super.key});

  @override
  State<UserEditInfoScreen> createState() => _UserEditInfoScreenState();
}

class _UserEditInfoScreenState extends State<UserEditInfoScreen> with WidgetsBindingObserver {
  final Color primaryTeal = const Color(0xFF64B5C7);
  
  User? user;
  String userName = '';
  String email = '';
  String? photoUrl;
  File? _pickedImage;
  
  Timer? _emailCheckTimer; 
  bool _isLoggingOut = false;
  bool _isPickingImage = false; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); 
    _loadUserData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); 
    _emailCheckTimer?.cancel(); 
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshUserData();
    }
  }

  Future<void> _triggerSuccessAndLogout(String message) async {
    if (_isLoggingOut) return; 
    setState(() => _isLoggingOut = true);
    
    _emailCheckTimer?.cancel();
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF64B5C7))),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 5));

    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop(); 
      context.go('/welcome');
    }
  }

  Future<void> _refreshUserData() async {
    if (_isLoggingOut) return;

    try {
      await user?.reload();
      user = FirebaseAuth.instance.currentUser;

      if (user != null && mounted) {
        if (user!.email != email) {
          await _triggerSuccessAndLogout('อัปเดตอีเมลสำเร็จ!\nระบบจะพากลับไปหน้าต้อนรับใน 5 วินาที...');
        }
      }
    } catch (e) {
      debugPrint("Error reloading user data: $e");
      if (_emailCheckTimer != null && _emailCheckTimer!.isActive) {
        await _triggerSuccessAndLogout('อัปเดตอีเมลสำเร็จ!\nระบบจะพากลับไปหน้าต้อนรับใน 5 วินาที...');
      } else {
        _emailCheckTimer?.cancel();
        if (mounted && !_isLoggingOut) {
          await FirebaseAuth.instance.signOut();
          context.go('/welcome');
        }
      }
    }
  }

  void _startEmailCheckTimer() {
    _emailCheckTimer?.cancel(); 
    _emailCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _refreshUserData();
    });
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

  Future<String?> _uploadToImgBB(File imageFile) async {
    const String apiKey = "0f95841b75294557c99590bce575a91d"; 
    
    final Uri url = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');
    final request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    try {
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

  void _showImagePickerSheet() async {
    if (_isPickingImage) return; 
    _isPickingImage = true; 

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      _isPickingImage = false; 

      if (image == null || !mounted) return;

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
                  onPressed: () {
                    Navigator.pop(sheetContext);

                    setState(() {
                      _pickedImage = File(image.path);
                    });

                    scaffoldMessenger.showSnackBar(
                      const SnackBar(content: Text('กำลังบันทึกรูปโปรไฟล์เบื้องหลัง... สามารถใช้งานแอปต่อไปได้')),
                    );

                    _uploadToImgBB(File(image.path)).then((imageUrl) async {
                      if (imageUrl != null) {
                        await user?.updatePhotoURL(imageUrl);
                        
                        if (mounted) {
                          setState(() {
                            photoUrl = imageUrl;
                          });
                        }
                        
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('อัปเดตรูปโปรไฟล์เสร็จสมบูรณ์!'),
                            backgroundColor: Colors.green, 
                          )
                        );
                      } else {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('อัปโหลดรูปล้มเหลว กรุณาลองใหม่'),
                            backgroundColor: Colors.red,
                          )
                        );
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('บันทึกรูปภาพ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      _isPickingImage = false; 
      debugPrint("Error picking image: $e");
    }
  }

  void _showEditBottomSheet({
    required String title,
    required String currentValue,
    required bool isPassword,
    required Function(String) onSave,
    int? maxLength, 
  }) {
    final TextEditingController controller = TextEditingController(text: isPassword ? '' : currentValue);
    final TextEditingController confirmController = TextEditingController(); 

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
                maxLength: maxLength, 
                decoration: InputDecoration(
                  counterText: '', 
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
              
              if (isPassword) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: confirmController,
                  obscureText: true, 
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'ยืนยันรหัสผ่านใหม่อีกครั้ง',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.black),
                      onPressed: () => confirmController.clear(),
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (isPassword) {
                      if (controller.text.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร')));
                        return; 
                      }
                      if (controller.text != confirmController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('รหัสผ่านไม่ตรงกัน กรุณาลองใหม่')));
                        return; 
                      }
                    }

                    String valueToSave = controller.text.trim();
                    Navigator.pop(sheetContext); 
                    
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted) {
                        onSave(valueToSave);
                      }
                    });
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
      if (mounted) {
        setState(() => userName = newName);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('อัปเดตชื่อผู้ใช้สำเร็จ')));
      }
    } catch (e) {
      debugPrint("Error updating name: $e");
    }
  }

  Future<void> _updateEmail(String newEmail) async {
    if (newEmail.isEmpty || !newEmail.contains('@') || newEmail == email) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await user?.verifyBeforeUpdateEmail(newEmail);
      
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); 
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ส่งลิงก์ยืนยันไปที่อีเมลใหม่แล้ว!\nกรุณาเช็ค Inbox และกดลิงก์เพื่อยืนยัน อีเมลจึงจะถูกเปลี่ยน'),
            backgroundColor: Colors.green, 
            duration: Duration(seconds: 5), 
          )
        );
        
        _startEmailCheckTimer(); 
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); 
        
        if (e.code == 'requires-recent-login') {
          Future.delayed(const Duration(milliseconds: 200), () {
             _showReAuthDialog(newEmail: newEmail);
          });
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('อีเมลนี้ถูกใช้งานไปแล้ว กรุณาใช้อีเมลอื่น'), backgroundColor: Colors.orange)
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.message}'), backgroundColor: Colors.red)
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง'), backgroundColor: Colors.red)
        );
      }
    }
  }

  Future<void> _updatePassword(String newPassword) async {
    if (newPassword.isEmpty || newPassword.length < 6) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await user?.updatePassword(newPassword);
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); 
        await _triggerSuccessAndLogout('เปลี่ยนรหัสผ่านสำเร็จ!\nระบบจะพากลับไปหน้าต้อนรับใน 5 วินาที...');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); 

        if (e.code == 'requires-recent-login') {
          Future.delayed(const Duration(milliseconds: 200), () {
             _showReAuthDialog(newPassword: newPassword);
          });
        } else {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.message}'), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง'), backgroundColor: Colors.red));
      }
    }
  }

  void _showReAuthDialog({String? newEmail, String? newPassword}) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('ยืนยันตัวตน', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('เพื่อความปลอดภัย กรุณากรอกรหัสผ่านปัจจุบันของคุณเพื่อทำรายการต่อ'),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'รหัสผ่านปัจจุบัน',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (passwordController.text.isEmpty) return;
              Navigator.pop(dialogContext); 

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );

              try {
                AuthCredential credential = EmailAuthProvider.credential(
                  email: user!.email!,
                  password: passwordController.text,
                );
                await user!.reauthenticateWithCredential(credential);

                if (newEmail != null) {
                  await user!.verifyBeforeUpdateEmail(newEmail);
                  if (mounted) {
                    Navigator.of(context, rootNavigator: true).pop(); 
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ยืนยันตัวตนสำเร็จ!\nส่งลิงก์ยืนยันไปที่อีเมลใหม่แล้ว กรุณาเช็ค Inbox'),
                        backgroundColor: Colors.green, 
                        duration: Duration(seconds: 5), 
                      )
                    );
                    _startEmailCheckTimer(); 
                  }
                } else if (newPassword != null) {
                  await user!.updatePassword(newPassword);
                  if (mounted) {
                    Navigator.of(context, rootNavigator: true).pop(); 
                    await _triggerSuccessAndLogout('เปลี่ยนรหัสผ่านสำเร็จ!\nระบบจะพากลับไปหน้าต้อนรับใน 5 วินาที...');
                  }
                }

              } on FirebaseAuthException catch (e) {
                if (mounted) {
                  Navigator.of(context, rootNavigator: true).pop(); 
                  if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('รหัสผ่านไม่ถูกต้อง กรุณาลองใหม่'), backgroundColor: Colors.red),
                    );
                  } else if (e.code == 'email-already-in-use') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('อีเมลนี้ถูกใช้งานไปแล้ว กรุณาใช้อีเมลอื่น'), backgroundColor: Colors.orange),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.message}'), backgroundColor: Colors.red),
                    );
                  }
                }
              } catch (error) {
                if (mounted) {
                  Navigator.of(context, rootNavigator: true).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('เกิดข้อผิดพลาด กรุณาลองใหม่'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('ยืนยัน', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 🌟 1. สั่งไม่ให้ฉากหลังพยายามหดตัวหนีคีย์บอร์ดจนพัง
      resizeToAvoidBottomInset: false, 
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/icons/back_arrow.png', width: 35, height: 35),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        // 🌟 2. นำ SingleChildScrollView มาครอบเนื้อหาหลักทั้งหมดไว้
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              Center(
                child: GestureDetector(
                  onTap: _showImagePickerSheet,
                  behavior: HitTestBehavior.opaque, 
                  child: Column(
                    children: [
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.image, size: 20, color: Colors.black87),
                          SizedBox(width: 6),
                          Text('แก้ไข', style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

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
                          maxLength: 12,
                        );
                      }),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _buildListTile('อีเมล', email.length > 15 ? '${email.substring(0, 15)}...' : email, false, () {
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
              const SizedBox(height: 40), // เผื่อที่ว่างด้านล่างเล็กน้อยให้เลื่อนได้สวยงาม
            ],
          ),
        ),
      ),
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