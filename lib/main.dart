import 'package:flutter/material.dart';
import 'core/routing/app_router.dart'; // ดึงไฟล์ router ที่เราสร้างมาใช้
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GiveLink',
      debugShowCheckedModeBanner: false, // ปิดแถบ Debug แดงๆ มุมขวาบน
      routerConfig: appRouter, // ใช้ go_router เป็นตัวจัดการหน้า
    );
  }
}