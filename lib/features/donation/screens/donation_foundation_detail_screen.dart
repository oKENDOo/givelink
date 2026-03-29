import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart'; // 🌟 ใช้สำหรับเปิด Google Maps
import '../../widgets/custom_bottom_nav.dart';

class DonationFoundationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> foundationData;

  const DonationFoundationDetailScreen({
    super.key,
    required this.foundationData,
  });

  static const Color primaryTeal = Color(0xFF64B5C7);

  // 🌟 ฟังก์ชันเปิด Google Maps (แก้ไข URL ให้ถูกต้อง)
  Future<void> _openGoogleMaps() async {
    final Uri googleMapsUrl = Uri.parse('https://maps.google.com/?q=มูลนิธิกระจกเงา');
    if (!await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication)) {
      debugPrint('ไม่สามารถเปิดแผนที่ได้');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🌟 1. แก้ไขการดึงข้อมูลเป็น List<dynamic> เพื่อป้องกันแอปค้างตอนเปลี่ยนหน้า
    final List<dynamic> neededItems = foundationData['neededItems'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false, 
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. ส่วนรูปภาพปก (Cover Image) และปุ่มย้อนกลับ ---
                    Stack(
                      children: [
                        Image.network(
                          foundationData['coverImage'],
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 220,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                          ),
                        ),
                        // ปุ่มย้อนกลับ
                        Positioned(
                          top: 33, // ปรับความสูงให้พ้นขอบมือถือ
                          left: 10,
                          child: GestureDetector(
                            onTap: () => context.pop(),
                            child: Image.asset(
                              'assets/icons/back_arrow.png', 
                              width: 35, 
                              height: 35,
                            ),
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- 2. ส่วนชื่อและที่อยู่ ---
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      foundationData['name'] ?? 'ชื่อมูลนิธิ',
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      foundationData['address'] ?? 'รายละเอียดที่อยู่',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.location_on, color: Colors.redAccent, size: 40),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // --- 3. ส่วนแผนที่ (กดเพื่อเปิด Google Maps) ---
                          GestureDetector(
                            onTap: _openGoogleMaps,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.network(
                                    foundationData['mapImage'],
                                    width: double.infinity,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(Icons.volunteer_activism, color: primaryTeal, size: 30),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),
                          const Divider(thickness: 1),
                          const SizedBox(height: 20),

                          // --- 4. ข้อมูลพื้นฐาน ---
                          const Text('ข้อมูลพื้นฐาน', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 3.5,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            children: [
                              _buildInfoPill(icon: Icons.star, iconColor: Colors.amber, text: '${foundationData['rating']} (Google Maps)'),
                              _buildInfoPill(icon: Icons.access_time, iconColor: primaryTeal, text: foundationData['hours']),
                              _buildInfoPill(icon: Icons.route, iconColor: primaryTeal, text: foundationData['distance']),
                              _buildInfoPill(icon: Icons.verified, iconColor: primaryTeal, text: foundationData['isVerified'] ? 'ยืนยันตัวตนแล้ว' : 'รอการยืนยัน'),
                            ],
                          ),

                          const SizedBox(height: 30),
                          const Divider(thickness: 1),
                          const SizedBox(height: 20),

                          // --- 5. สิ่งของที่ต้องการ ---
                          const Text('สิ่งของที่ต้องการ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 3.5,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: neededItems.length,
                            itemBuilder: (context, index) {
                              final item = neededItems[index];
                              // 🌟 2. ดึงข้อมูลแบบไม่ล็อค Type
                              return _buildInfoPill(icon: item['icon'], iconColor: primaryTeal, text: item['title'].toString());
                            },
                          ),

                          const SizedBox(height: 30),
                          const Divider(thickness: 1),
                          const SizedBox(height: 20),

                          // --- 6. ติดต่อ ---
                          const Text('ติดต่อ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Text('เบอร์โทรติดต่อ: ${foundationData['phone']}', style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 10),
                          Text('Facebook: ${foundationData['facebook']}', style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 10),
                          Text('Website : ${foundationData['website']}', style: const TextStyle(fontSize: 14)),

                          const SizedBox(height: 40),

                          // --- 7. ปุ่มบริจาคสิ่งของ ---
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: () {
                                // 🌟 ส่งข้อมูลของจริงที่รับมา ไปยังหน้าเลือกวันที่
                                context.push('/donation_date', extra: {
                                  'foundationName': foundationData['name'],
                                  // เอา ['เสื้อผ้า', 'หนังสือ'] ออก แล้วดึงข้อมูลจริงที่ส่งมาจากจุดที่ 1 มาใช้
                                  'selectedCategories': foundationData['selectedCategories'] ?? [],
                                  'othersText': foundationData['othersText'] ?? '',
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryTeal,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('บริจาคสิ่งของให้กับมูลนิธินี้', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                  SizedBox(width: 10),
                                  Icon(Icons.arrow_circle_right_outlined, color: Colors.white, size: 28),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
    );
  }

  // Widget ช่วยสร้างกล่องข้อมูลแบบมีกรอบมนๆ
  Widget _buildInfoPill({required IconData icon, required Color iconColor, required String text}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}