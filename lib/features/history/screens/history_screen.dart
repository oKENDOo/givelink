import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:go_router/go_router.dart'; // 🌟 เพิ่มบรรทัดนี้เข้าไป

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Color primaryBlue = const Color(0xFF64B5C7);
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // 🌟 ฟังก์ชันแปลงวันที่จาก Firebase ให้เป็นภาษาไทย
  String _formatThaiDate(Timestamp? timestamp) {
    if (timestamp == null) return 'ไม่ระบุวันที่';
    DateTime date = timestamp.toDate();
    final List<String> thaiMonths = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];
    final int buddhistYear = date.year + 543;
    return 'วันที่ ${date.day} ${thaiMonths[date.month - 1]} $buddhistYear';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // จำนวน Tab ทั้งหมด 3 หน้า
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false, 
          title: const Text(
            'ประวัติการบริจาค',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          bottom: const TabBar(
            labelColor: Colors.black, 
            unselectedLabelColor: Colors.grey, 
            indicatorColor: Colors.black, 
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            tabs: [
              Tab(text: 'ดำเนินการ'),
              Tab(text: 'เสร็จสิ้น'),
              Tab(text: 'ยกเลิก'),
            ],
          ),
        ),
        
        // 🌟 ใช้ StreamBuilder เพื่อดึงข้อมูลจาก Firebase แบบ Real-time
        body: StreamBuilder<QuerySnapshot>(
          // ดึงเฉพาะข้อมูลของ User คนปัจจุบัน
          stream: FirebaseFirestore.instance
              .collection('DonationBookings')
              .where('user_id', isEqualTo: currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: primaryBlue));
            }
            
            if (snapshot.hasError) {
              return const Center(child: Text('เกิดข้อผิดพลาดในการดึงข้อมูล'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return TabBarView(
                children: [
                  _buildEmptyState('คุณยังไม่มีการบริจาคที่กำลังดำเนินการ'),
                  _buildEmptyState('คุณยังไม่มีการบริจาคที่เสร็จสิ้น'),
                  _buildEmptyState('คุณยังไม่มีการบริจาคที่ถูกยกเลิก/ล้มเหลว'),
                ],
              );
            }

            // ดึงข้อมูลออกมาทั้งหมด และนำมาเรียงลำดับให้ "อันใหม่ล่าสุดอยู่บนสุด"
            List<QueryDocumentSnapshot> allDocs = snapshot.data!.docs.toList();
            allDocs.sort((a, b) {
              Timestamp? timeA = (a.data() as Map<String, dynamic>)['created_at'];
              Timestamp? timeB = (b.data() as Map<String, dynamic>)['created_at'];
              if (timeA == null || timeB == null) return 0;
              return timeB.compareTo(timeA); 
            });

            // แยกรายการตามสถานะ
            final pendingDocs = allDocs.where((doc) => doc['status'] == 'pending').toList();
            final completedDocs = allDocs.where((doc) => doc['status'] == 'completed' || doc['status'] == 'success').toList();
            final cancelledDocs = allDocs.where((doc) => doc['status'] == 'cancelled' || doc['status'] == 'cancel').toList();

            return TabBarView(
              children: [
                _buildListView(pendingDocs, 'คุณยังไม่มีการบริจาคที่กำลังดำเนินการ'),
                _buildListView(completedDocs, 'คุณยังไม่มีการบริจาคที่เสร็จสิ้น'),
                _buildListView(cancelledDocs, 'คุณยังไม่มีการบริจาคที่ถูกยกเลิก/ล้มเหลว'),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- Widget สำหรับสร้าง List ของแต่ละ Tab ---
  Widget _buildListView(List<QueryDocumentSnapshot> docs, String emptyMessage) {
    if (docs.isEmpty) {
      return _buildEmptyState(emptyMessage);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final data = docs[index].data() as Map<String, dynamic>;
        
        String foundationName = data['foundation_name'] ?? 'ไม่ระบุชื่อมูลนิธิ';
        
        // 🌟 ดึงข้อมูลสิ่งของมาโชว์แทนที่อยู่
        List<dynamic> categories = data['selected_categories'] ?? [];
        String others = data['others_text'] ?? '';
        // 🌟 เพิ่ม .replaceAll('\n', '') เพื่อลบการปัดบรรทัดออกให้หมด
        List<String> allItems = categories.map((e) => e.toString().replaceAll('\n', '')).toList();
        if (others.isNotEmpty) allItems.add(others);
        
        // 🌟 ลอจิกใหม่: ถ้ายาวเกิน 2 อย่าง ให้ใส่ +ด้านหลัง
        String itemsText = 'ไม่ระบุ';
        if (allItems.isNotEmpty) {
          if (allItems.length <= 2) {
            itemsText = ' ${allItems.join(', ')}';
          } else {
            itemsText = ' ${allItems.take(2).join(', ')} +${allItems.length - 2}';
          }
        }
        
        // ดึงวันที่
        String dateText = _formatThaiDate(data['donation_date']);

        return _buildDonationItem(
          title: foundationName,
          subtitle: itemsText, 
          date: dateText,
          onTap: () {
            // 🌟 ลิงก์ไปหน้าประวัติแบบละเอียด พร้อมส่งข้อมูลใบจองไปด้วย
            context.push('/history_detail', extra: data);
          },
        );
      },
    );
  }

  // --- Widget สำหรับสร้างการ์ดรายการบริจาค ---
  Widget _buildDonationItem({
    required String title,
    required String subtitle,
    required String date,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ไอคอนกล่องพัสดุ
          const Icon(Icons.inventory_2_outlined, size: 40, color: Colors.black87),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.card_giftcard, size: 16, color: Colors.black54),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        subtitle,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date,
                      style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: const [
                            Text('เพิ่มเติม', style: TextStyle(color: Colors.white, fontSize: 12)),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_circle_right_outlined, color: Colors.white, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

 // line 203
  // --- Widget สำหรับหน้าว่าง (Empty State) ---
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
            ),
            // 🌟 ✅ แทนที่ Icon ด้วย Image.asset 
            child: Image.asset(
              'assets/images/logo_crop.png',
              width: 120, // กำหนดขนาดให้เท่ากับไอคอนเดิม
              height: 120,
              // เผื่อไว้กรณีโหลดภาพไม่สำเร็จ ให้แสดงไอคอนสำรอง
              errorBuilder: (context, error, stackTrace) => Icon(Icons.volunteer_activism, size: 60, color: primaryBlue),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}