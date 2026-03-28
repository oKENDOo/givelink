import 'package:flutter/material.dart';

class NewsDetailScreen extends StatelessWidget {
  // รับข้อมูลจากหน้า Home มาแสดงผล
  final String title;
  final String foundation;
  final String content;
  final String imageUrl;

  const NewsDetailScreen({
    super.key,
    required this.title,
    required this.foundation,
    required this.content,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // ปุ่มย้อนกลับแบบลอยตัว
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/icons/back_arrow.png', width: 40, height: 40),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('ข่าวสาร', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. รูปภาพข่าวขนาดใหญ่
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. หมวดหมู่/หัวข้อข่าว
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF64B5C7).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      title,
                      style: const TextStyle(color: Color(0xFF64B5C7), fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. ชื่อมูลนิธิ
                  Text(
                    foundation,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  
                  // 4. วันที่/เวลา (สมมติ)
                  const Row(
                    children: [
                      Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('22 มีนาคม 2026', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const Divider(height: 40),

                  // 5. เนื้อหาข่าว (Content)
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.6, // ระยะห่างบรรทัดให้อ่านง่าย
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // 6. ปุ่มแชร์หรือปุ่มบริจาคด่วน
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF64B5C7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('แชร์ข่าวนี้', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}