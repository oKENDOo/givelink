import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

class HistoryDetailScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  const HistoryDetailScreen({super.key, required this.bookingData});

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  final Color primaryBlue = const Color(0xFF64B5C7);
  
  Map<String, dynamic>? foundationData;
  String calculatedDistance = 'กำลังคำนวณ...';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFoundationAndLocation();
  }

  // ดึงข้อมูลมูลนิธิและคำนวณระยะทาง
  Future<void> _fetchFoundationAndLocation() async {
    try {
      final foundationId = widget.bookingData['foundation_id'];
      if (foundationId != null) {
        final doc = await FirebaseFirestore.instance.collection('Foundations').doc(foundationId).get();
        if (doc.exists) {
          foundationData = doc.data();
        }
      }

      // ดึงตำแหน่ง
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();

      if (serviceEnabled && permission != LocationPermission.denied && permission != LocationPermission.deniedForever) {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        if (foundationData != null && foundationData!['location'] != null) {
          GeoPoint geoPoint = foundationData!['location'];
          double distInMeters = Geolocator.distanceBetween(
            position.latitude, position.longitude,
            geoPoint.latitude, geoPoint.longitude,
          );
          calculatedDistance = '${(distInMeters / 1000).toStringAsFixed(1)} Km';
        } else {
          calculatedDistance = 'ไม่ระบุระยะทาง';
        }
      } else {
        calculatedDistance = 'ไม่สามารถระบุระยะทางได้';
      }
    } catch (e) {
      calculatedDistance = 'ไม่ทราบระยะทาง';
    }

    if (mounted) setState(() => isLoading = false);
  }

  // แปลงวันที่
  String _formatThaiDate(Timestamp? timestamp) {
    if (timestamp == null) return 'ไม่ระบุวันที่';
    DateTime date = timestamp.toDate();
    final thaiMonths = ['มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน', 'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'];
    return '${date.day} ${thaiMonths[date.month - 1]} ${date.year + 543}';
  }

  // ไอคอน
  IconData _getIconForCategory(String title) {
    switch (title.replaceAll('\n', '')) {
      case 'เสื้อผ้า': return Icons.checkroom;
      case 'อาหารและน้ำ': return Icons.fastfood;
      case 'ของเล่นเด็ก': return Icons.smart_toy;
      case 'หนังสือ': return Icons.menu_book;
      case 'อุปกรณ์การเรียน': return Icons.school;
      case 'อุปกรณ์สุขภาพ': return Icons.medical_services;
      case 'ของใช้ส่วนตัว': return Icons.person;
      case 'ของใช้ในบ้าน': return Icons.home;
      default: return Icons.card_giftcard;
    }
  }

  // สถานะ
  String _getStatusText(String status) {
    if (status == 'pending') return 'รอการส่งมอบสิ่งของ\nบริจาคให้กับมูลนิธิ';
    if (status == 'completed' || status == 'success') return 'ส่งมอบสิ่งของสำเร็จแล้ว';
    if (status == 'cancelled' || status == 'cancel') return 'ยกเลิกการบริจาค';
    return 'รอดำเนินการ';
  }

  // ข้อความสิ่งของรวม
  String _buildCategoriesString(List<String> items) {
    if (items.isEmpty) return 'ไม่ระบุสิ่งของ';
    if (items.length == 1) return items[0];
    if (items.length == 2) return '${items[0]} และ${items[1]}';
    String firstPart = items.sublist(0, items.length - 1).join(', ');
    return '$firstPart และ${items.last}';
  }

  @override
  Widget build(BuildContext context) {
    // ดึงและเตรียมข้อมูลสิ่งของ
    List<dynamic> rawCategories = widget.bookingData['selected_categories'] ?? [];
    String others = widget.bookingData['others_text'] ?? '';
    List<String> allItems = rawCategories.map((e) => e.toString().replaceAll('\n', '')).toList();
    if (others.isNotEmpty) allItems.add(others);

    List<dynamic> imageUrls = widget.bookingData['item_image_urls'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/icons/back_arrow.png', width: 35, height: 35),
          onPressed: () => context.pop(),
        ),
        title: const Text('ประวัติการบริจาค', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: primaryBlue))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. สถานะ ---
                    Row(
                      children: [
                        Text('สถานะ', style: TextStyle(color: primaryBlue, fontSize: 18, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Text(
                            _getStatusText(widget.bookingData['status'] ?? ''),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 40, thickness: 1),

                    // --- 2. สิ่งของที่จะบริจาค ---
                    Text('สิ่งของที่จะบริจาค', style: TextStyle(color: primaryBlue, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: allItems.take(3).map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(_getIconForCategory(item), color: primaryBlue, size: 45),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        _buildCategoriesString(allItems),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Divider(height: 40, thickness: 1),

                    // --- 3. บริจาคให้กับ (การ์ดมูลนิธิ) ---
                    Text('บริจาคให้กับ', style: TextStyle(color: primaryBlue, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    _buildFoundationCard(),
                    const Divider(height: 40, thickness: 1),

                    // --- 4. วันที่ ---
                    Row(
                      children: [
                        Text('ในวันที่', style: TextStyle(color: primaryBlue, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 30),
                        Expanded(
                          child: Text(
                            _formatThaiDate(widget.bookingData['donation_date']),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 40, thickness: 1),

                    // --- 5. รูปภาพสิ่งของ ---
                    Text('รูปภาพสิ่งของ', style: TextStyle(color: primaryBlue, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    if (imageUrls.isEmpty)
                      const Center(child: Text('ไม่มีรูปภาพแนบมา', style: TextStyle(color: Colors.grey)))
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: imageUrls.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imageUrls[index].toString(),
                                width: double.infinity,
                                height: 250,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 250,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildFoundationCard() {
    if (foundationData == null) {
      return Text(widget.bookingData['foundation_name'] ?? 'ไม่ระบุชื่อมูลนิธิ', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
    }

    String? logoImage = foundationData!['logoImage'];
    List<String> itemsList = List<String>.from(foundationData!['neededItems'] ?? []);
    String acceptedItemsText = itemsList.join('/');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 90, height: 90,
          decoration: BoxDecoration(
            color: Colors.yellow, // สีพื้นหลังเผื่อโหลดรูปไม่ติด
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
            image: logoImage != null ? DecorationImage(image: NetworkImage(logoImage), fit: BoxFit.contain) : null,
          ),
          child: logoImage == null ? const Icon(Icons.volunteer_activism, size: 40) : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      foundationData!['name'] ?? 'ไม่มีชื่อ', 
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), 
                      maxLines: 1, overflow: TextOverflow.ellipsis
                    ),
                  ),
                  if (foundationData!['isVerified'] == true) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, color: Colors.blue, size: 18),
                  ]
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '$acceptedItemsText\n$calculatedDistance', 
                style: const TextStyle(color: Colors.grey, fontSize: 12), 
                maxLines: 2, overflow: TextOverflow.ellipsis
              ),
              const SizedBox(height: 8),
              Row(
                children: itemsList.take(4).map((itemTitle) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Icon(_getIconForCategory(itemTitle), color: primaryBlue, size: 18),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}