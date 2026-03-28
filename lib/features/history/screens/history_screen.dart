import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import  '../../widgets/custom_bottom_nav.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Color primaryBlue = const Color(0xFF64B5C7);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // จำนวน Tab ทั้งหมด 3 หน้า
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false, // ปิดปุ่มย้อนกลับอัตโนมัติ (เพราะเราใช้ Nav bar ด้านล่างแทน)
          title: const Text(
            'ประวัติการบริจาค',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          bottom: const TabBar(
            labelColor: Colors.black, // สีของ Tab ที่ถูกเลือก
            unselectedLabelColor: Colors.grey, // สีของ Tab ที่ไม่ได้เลือก
            indicatorColor: Colors.black, // สีเส้นขีดด้านล่าง
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            tabs: [
              Tab(text: 'กำลังดำเนินการ'),
              Tab(text: 'เสร็จสิ้น'),
              Tab(text: 'ยกเลิก/ล้มเหลว'),
            ],
          ),
        ),
        
        // --- ส่วนเนื้อหาของแต่ละ Tab ---
        body: TabBarView(
          children: [
            // Tab 1: กำลังดำเนินการ (มีข้อมูล 1 รายการ)
            ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildDonationItem(
                  title: 'มูลนิธิกระจกเงา',
                  address: '126/14 ซอยอนุบาล อำเภอเมือง\nจังหวัดแรคคูล',
                  date: 'วันที่ 28 กุมภาพันธ์ 2569',
                  onTap: () {
                    // TODO: นำทางไปหน้ารายละเอียดเมื่อกดปุ่ม "เพิ่มเติม"
                  },
                ),
              ],
            ),

            // Tab 2: เสร็จสิ้น (หน้าว่าง)
            _buildEmptyState('คุณยังไม่มีการบริจาคที่เสร็จสิ้นในตอนนี้'),

            // Tab 3: ยกเลิก/ล้มเหลว (หน้าว่าง)
            _buildEmptyState('คุณยังไม่มีการบริจาคที่ถูกยกเลิก/ล้มเหลวในตอนนี้'),
          ],
        ),

        // --- ส่วน Bottom Navigation Bar ---
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
      ),
    );
  }

  // --- Widget สำหรับสร้างรายการบริจาค ---
  Widget _buildDonationItem({
    required String title,
    required String address,
    required String date,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
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
                    const Icon(Icons.location_on, size: 16, color: Colors.black87),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        address,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
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

  // --- Widget สำหรับหน้าว่าง (Empty State) ---
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ใช้ไอคอนแทนโลโก้ชั่วคราว (ถ้ามีรูปโลโก้สามารถเปลี่ยนเป็น Image.asset ได้เลย)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryBlue, width: 3),
            ),
            child: Icon(Icons.volunteer_activism, size: 60, color: primaryBlue),
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