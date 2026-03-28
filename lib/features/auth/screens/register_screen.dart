import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget { 
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 🌟 ลบ _nameController ออกไปแล้ว เหลือแค่ 4 ช่อง
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false; 

  // ฟังก์ชันสมัครสมาชิก
// 🌟 ฟังก์ชันสมัครสมาชิก
  Future<void> _signUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('รหัสผ่านไม่ตรงกัน!')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. สร้างบัญชีด้วยอีเมลและรหัสผ่าน และเก็บข้อมูล user ไว้ในตัวแปร userCredential
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      // 🌟 2. จุดสำคัญ! สั่งให้อัปเดต "ชื่อผู้ใช้" (displayName) เข้าไปในบัญชีที่เพิ่งสร้าง
      await userCredential.user?.updateDisplayName(_usernameController.text.trim());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ลงทะเบียนสำเร็จ!')));
        context.push('/login');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.message}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    // 🌟 ลบ _nameController.dispose() ออกไปแล้ว
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF64B5C7);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/icons/back_arrow.png', width: 40, height: 40),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ลงทะเบียน', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('กรุณาลงทะเบียนเพื่อใช้งาน', style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 40), 
          Expanded( 
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
              ),
              child: SingleChildScrollView(
                physics: bottomInset > 0 ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40), 
                child: Column(
                  children: [
                    // 🌟 ลบช่องกรอก "ชื่อ" ออกไปแล้ว ให้เริ่มที่ "ชื่อผู้ใช้" เลย
                    _buildTextField(hint: 'ชื่อผู้ใช้', controller: _usernameController),
                    const SizedBox(height: 40),
                    _buildTextField(hint: 'อีเมล', controller: _emailController),
                    const SizedBox(height: 40),
                    _buildTextField(hint: 'รหัสผ่าน', isPassword: true, controller: _passwordController),
                    const SizedBox(height: 40),
                    _buildTextField(hint: 'ยืนยันรหัสผ่าน', isPassword: true, controller: _confirmPasswordController),
                    
                    const SizedBox(height: 50), 
                    
                    SizedBox(
                      width: double.infinity,
                      height: 70, 
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signUp, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        ),
                        child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('ลงทะเบียน', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String hint, bool isPassword = false, required TextEditingController controller}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30), 
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}