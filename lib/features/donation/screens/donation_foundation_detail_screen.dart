import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart'; 

class DonationFoundationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> foundationData;

  const DonationFoundationDetailScreen({
    super.key,
    required this.foundationData,
  });

  static const Color primaryTeal = Color(0xFF64B5C7);

  Future<void> _openGoogleMaps(double? lat, double? lng) async {
    if (lat == null || lng == null) {
      debugPrint('ไม่มีพิกัดแผนที่สำหรับมูลนิธินี้');
      return;
    }
    final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    
    if (!await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication)) {
      debugPrint('ไม่สามารถเปิดแผนที่ได้');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> neededItems = foundationData['neededItems'] ?? [];
    final String coverImage = foundationData['coverImage'] ?? 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?q=80&w=600&auto=format&fit=crop';
    final String mapImage = foundationData['mapImage'] ?? 'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=600&auto=format&fit=crop';
    final bool isVerified = foundationData['isVerified'] ?? false;
    final String rating = foundationData['rating'] ?? '-';
    final String hours = foundationData['hours'] ?? 'ไม่ได้ระบุเวลา';
    final String distance = foundationData['distance'] ?? 'ไม่ได้ระบุระยะทาง';
    
    final double? latitude = foundationData['latitude'];
    final double? longitude = foundationData['longitude'];

    // 🌟 ดึงข้อมูลของบริจาค เพื่อเช็คว่ามาจากหน้าไหน
    final List<dynamic> selectedCategories = foundationData['selectedCategories'] ?? [];
    final String othersText = foundationData['othersText'] ?? '';
    
    // 🌟 ตัวแปรเช็คว่า "ได้เลือกของบริจาคมาหรือยัง?" (ถ้า true คือมาจากหน้า 2/5, ถ้า false คือมาจาก Home)
    final bool hasSelectedItems = selectedCategories.isNotEmpty || othersText.isNotEmpty;

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
                    Stack(
                      children: [
                        Image.network(
                          coverImage, 
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 220,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                          ),
                        ),
                        Positioned(
                          top: 33, 
                          left: 10,
                          child: GestureDetector(
                            onTap: () {
                              // 🌟 1. ดักการกด Back ไม่ให้แอปพัง
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/map'); // ถ้าย้อนไม่ได้ให้กลับแผนที่
                              }
                            },
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
                              const Icon(Icons.location_on, color: Colors.redAccent, size: 60),
                            ],
                          ),
                          const SizedBox(height: 20),

                          GestureDetector(
                            onTap: () => _openGoogleMaps(latitude, longitude),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.network(
                                    mapImage, 
                                    width: double.infinity,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      height: 150,
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.map, size: 50, color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),
                          const Divider(thickness: 1),
                          const SizedBox(height: 20),

                          const Text('ข้อมูลพื้นฐาน', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 3.5,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            children: [
                              _buildInfoPill(icon: Icons.star, iconColor: Colors.amber, text: '$rating (Google Maps)'),
                              _buildInfoPill(icon: Icons.access_time, iconColor: primaryTeal, text: hours),
                              _buildInfoPill(icon: Icons.route, iconColor: primaryTeal, text: distance),
                              _buildInfoPill(icon: Icons.verified, iconColor: primaryTeal, text: isVerified ? 'ยืนยันตัวตนแล้ว' : 'รอการยืนยัน'),
                            ],
                          ),

                          const SizedBox(height: 30),
                          const Divider(thickness: 1),
                          const SizedBox(height: 20),

                          const Text('สิ่งของที่ต้องการ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
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
                              return _buildInfoPill(
                                icon: item['icon'] as IconData? ?? Icons.card_giftcard, 
                                iconColor: primaryTeal, 
                                text: item['title'].toString()
                              );
                            },
                          ),

                          const SizedBox(height: 30),
                          const Divider(thickness: 1),
                          const SizedBox(height: 20),

                          const Text('ติดต่อ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Text('เบอร์โทรติดต่อ: ${foundationData['phone'] ?? '-'}', style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 10),
                          Text('Facebook: ${foundationData['facebook'] ?? '-'}', style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 10),
                          Text('Website : ${foundationData['website'] ?? '-'}', style: const TextStyle(fontSize: 14)),

                          const SizedBox(height: 40),

                          // 🌟 ถ้าเข้าผ่าน Tab บริจาค (มีของที่เลือกมาแล้ว) ถึงจะโชว์ปุ่มไปต่อ
                          if (hasSelectedItems)
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton(
                                onPressed: () {
                                  context.push('/donation_date', extra: {
                                    'foundationName': foundationData['name'] ?? 'มูลนิธิ',
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
                          // ❌ ลบ else ทิ้งไปแล้ว (ถ้ามาจาก Home/Map จะไม่มีปุ่มอะไรโชว์เลย)

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
    );
  }
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