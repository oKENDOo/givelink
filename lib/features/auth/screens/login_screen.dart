import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🌟 นำเข้า Firebase Auth

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 🌟 สร้างตัวควบคุม
  final TextEditingController _emailController = TextEditingController(); // Login Firebase ต้องใช้อีเมล
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;

  // 🌟 ฟังก์ชันเข้าสู่ระบบ
  Future<void> _signIn() async {
    setState(() => _isLoading = true);

    try {
      // 1. ส่งอีเมลและรหัสผ่านไปเช็กกับ Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      // 2. ถ้าล็อกอินสำเร็จ ให้ไปหน้าถัดไป (สมมติว่าเป็นหน้า / )
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('เข้าสู่ระบบสำเร็จ!')));
        // TODO: เปลี่ยน '/' เป็นเส้นทางหน้า Home Screen ของคุณ
        context.go('/home');
      }
    } on FirebaseAuthException catch (e) {
      // 3. ดักจับ Error เช่น รหัสผิด ไม่มีบัญชีนี้
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เข้าสู่ระบบล้มเหลว: ${e.message}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF64B5C7);
    const Color registerTextColor = Color.fromARGB(255, 0, 102, 255); 
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final minBlueBoxHeight = screenHeight - 300; 

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
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('เข้าสู่ระบบ', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('กรุณาเข้าสู่ระบบเพื่อใช้งาน', style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 80),
          Expanded( 
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
              ),
              child: SingleChildScrollView(
                physics: bottomInset > 0 ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30), 
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minBlueBoxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                      children: [
                        // 🌟 เปลี่ยน Hint เป็น 'อีเมล' เพราะ Firebase บังคับใช้อีเมลล็อคอิน
                        _buildTextField(hint: 'อีเมล', controller: _emailController),
                        _buildTextField(hint: 'รหัสผ่าน', isPassword: true, controller: _passwordController),
                        
                        const SizedBox(height: 10),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 70, 
                          child: ElevatedButton(
                            // 🌟 ผูกปุ่มเข้ากับฟังก์ชัน
                            onPressed: _isLoading ? null : _signIn, 
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('เข้าสู่ระบบ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('ยังไม่มีบัญชี ? ', style: TextStyle(color: Colors.white, fontSize: 20)),
                            GestureDetector(
                              onTap: () => context.push('/register'),
                              child: Text('ลงทะเบียน', style: TextStyle(color: registerTextColor, fontWeight: FontWeight.bold, fontSize: 20)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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

//kendokendo142711@gmail.com
//123456