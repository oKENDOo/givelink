import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // ⏳ ตั้งเวลาหน่วง 3 วินาที
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // เมื่อครบ 3 วิ ให้เปลี่ยนไปหน้า /welcome
        context.go('/welcome');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/logo_name.png', 
          width: 700,
          height: 200,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}