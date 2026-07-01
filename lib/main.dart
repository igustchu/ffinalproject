import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // สำหรับเชื่อมต่อฐานข้อมูล
import 'package:test_app/screens/login_screen.dart';
// ✅ Import ไฟล์ใหม่

Future<void> main() async {
  // 1. จำเป็นต้องมีบรรทัดนี้เมื่อ main เป็น async
  WidgetsFlutterBinding.ensureInitialized();

  // 2. เชื่อมต่อ Supabase
  // ⚠️ ไปเอา URL และ Key ได้ที่: Supabase Dashboard -> Project Settings -> API
  await Supabase.initialize(
    url: 'https://qwxjxtzyowhhkhkjtjhj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF3eGp4dHp5b3doaGtoa2p0amhqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI4MjE5OTQsImV4cCI6MjA5ODM5Nzk5NH0.Xvl_9Rf40Ge1hIL7u5MRREPbctNKJyOJJt_AuckeR1A',
  );
  
  await Supabase.instance.client.auth.signOut(
    scope: SignOutScope.local,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // ปิดป้าย Debug มุมขวาบน

      // ตั้งค่าธีมหลักของแอป
      theme: ThemeData(
        primarySwatch: Colors.orange, // สีหลัก
        fontFamily: 'Sans-serif', // ฟอนต์
        scaffoldBackgroundColor: const Color(0xFFFFF9E6), // สีพื้นหลัง (ครีม)
        // ตั้งค่า AppBar ให้โปร่งใสเป็นค่าเริ่มต้น (เพื่อให้เข้ากับ CustomHeader)
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),

        // ตั้งค่าปุ่มกดให้สวยงามเป็นค่าเริ่มต้น
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),

      // เรียกหน้าแรก (ImageScanning)
      home: const LoginScreen(),
    );
  }
}

