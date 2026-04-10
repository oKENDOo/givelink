import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget { 
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false; 

  // 🌟 ฟังก์ชันสมัครสมาชิก
  Future<void> _signUp() async {
    // 🌟 1. ดักจับกรณีผู้ใช้ยังไม่กรอกข้อมูลให้ครบถ้วน
    if (_usernameController.text.trim().isEmpty || 
        _emailController.text.trim().isEmpty || 
        _passwordController.text.trim().isEmpty || 
        _confirmPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')));
      return; // หยุดการทำงาน ไม่ส่งไป Firebase
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('รหัสผ่านไม่ตรงกัน!')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // สร้างบัญชีด้วยอีเมลและรหัสผ่าน
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      // อัปเดต "ชื่อผู้ใช้" (displayName) เข้าไปในบัญชีที่เพิ่งสร้าง
      await userCredential.user?.updateDisplayName(_usernameController.text.trim());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ลงทะเบียนสำเร็จ!')));
        context.push('/login');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        // 🌟 แปลง Error ยาวๆ ของ Firebase ให้เป็นข้อความภาษาไทยสั้นๆ เข้าใจง่าย
        String errorMessage = 'เกิดข้อผิดพลาดในการลงทะเบียน กรุณาลองใหม่';
        if (e.code == 'email-already-in-use') {
          errorMessage = 'อีเมลนี้มีผู้ใช้งานแล้ว';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'รูปแบบอีเมลไม่ถูกต้อง';
        } else if (e.code == 'weak-password') {
          errorMessage = 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF64B5C7);
    
    // 🌟 2. ดึงค่าความหนาของ Navbar ด้านล่างสุดของมือถือแต่ละเครื่อง
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

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
          const SizedBox(height: 35), 
          Expanded( 
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
              ),
              child: SingleChildScrollView(
                // 🌟 3. เปลี่ยนให้เลื่อนจอขึ้นลงได้เสมอ จะได้ใช้นิ้วปัดดูปุ่มได้
                physics: const AlwaysScrollableScrollPhysics(),
                // 🌟 4. ดันระยะด้านล่างสุดเพิ่มขึ้น (บวกความหนาของ Navbar มือถือเข้าไป)
                padding: EdgeInsets.only(left: 30, right: 30, top: 40, bottom: 40 + bottomPadding), 
                child: Column(
                  children: [
                    _buildTextField(hint: 'ชื่อผู้ใช้', controller: _usernameController, maxLength: 12),
                    const SizedBox(height: 20),
                    _buildTextField(hint: 'อีเมล', controller: _emailController),
                    const SizedBox(height: 20),
                    _buildTextField(hint: 'รหัสผ่าน', isPassword: true, controller: _passwordController),
                    const SizedBox(height: 20),
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

  Widget _buildTextField({required String hint, bool isPassword = false, required TextEditingController controller, int? maxLength}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      maxLength: maxLength, 
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        counterText: '', 
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30), 
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}