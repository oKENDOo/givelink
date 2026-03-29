import 'package:flutter/material.dart';
import 'core/routing/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// 1. เพิ่มการ import google_fonts
import 'package:google_fonts/google_fonts.dart'; 

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
      debugShowCheckedModeBanner: false,
      
      // 2. กำหนด Theme ตรงนี้
      theme: ThemeData(
        useMaterial3: true,
        // กำหนด Kanit ให้กับข้อความทั้งหมดในแอป
        textTheme: GoogleFonts.kanitTextTheme(
          Theme.of(context).textTheme,
        ),
        // แถม: ถ้าอยากให้ปุ่มหรือส่วนอื่นๆ เป็น Kanit ด้วย
        primaryTextTheme: GoogleFonts.kanitTextTheme(
          Theme.of(context).primaryTextTheme,
        ),
      ),

      routerConfig: appRouter,
    );
  }
}