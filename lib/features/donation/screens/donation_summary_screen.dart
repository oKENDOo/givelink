import 'dart:io';
import 'dart:convert'; // 🌟 สำหรับแปลง JSON จาก ImgBB
import 'package:http/http.dart' as http; // 🌟 สำหรับเรียก API ImgBB
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🌟 สำหรับดึง user_id
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:geolocator/geolocator.dart'; 

class DonationSummaryScreen extends StatefulWidget {
  final String foundationName;
  final List<dynamic> selectedCategories;
  final String othersText;
  final DateTime? selectedDate;
  final List<dynamic> selectedImages;

  const DonationSummaryScreen({
    super.key,
    required this.foundationName,
    required this.selectedCategories,
    required this.othersText,
    required this.selectedDate,
    required this.selectedImages,
  });

  @override
  State<DonationSummaryScreen> createState() => _DonationSummaryScreenState();
}

class _DonationSummaryScreenState extends State<DonationSummaryScreen> {
  final Color primaryTeal = const Color(0xFF64B5C7);

  Map<String, dynamic>? foundationData;
  String? foundationId; // 🌟 เก็บ foundation_id ไว้ใช้ตอนบันทึก
  String calculatedDistance = 'กำลังคำนวณ...';
  bool isLoadingFoundation = true;
  bool isSaving = false; // 🌟 ตัวแปรเช็คสถานะตอนกำลังกดบันทึก

  @override
  void initState() {
    super.initState();
    _fetchFoundationData(); 
  }

  Future<void> _fetchFoundationData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Foundations')
          .where('name', isEqualTo: widget.foundationName)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        foundationData = snapshot.docs.first.data();
        foundationId = snapshot.docs.first.id; // 🌟 เก็บ ID ของมูลนิธินี้ไว้
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

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
          calculatedDistance = 'ไม่ทราบระยะทาง';
        }
      } else {
        calculatedDistance = 'ไม่สามารถระบุระยะทางได้';
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      calculatedDistance = 'ข้อผิดพลาดในการคำนวณ';
    }

    if (mounted) {
      setState(() {
        isLoadingFoundation = false;
      });
    }
  }

  // 🌟 ฟังก์ชันอัปโหลดรูปภาพ 1 รูปไปที่ ImgBB
  Future<String?> _uploadSingleImageToImgBB(File imageFile) async {
    const String apiKey = "0f95841b75294557c99590bce575a91d"; 
    final Uri url = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');
    final request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    try {
      final response = await request.send().timeout(const Duration(seconds: 15));
      final responseData = await response.stream.bytesToString();
      final jsonResult = jsonDecode(responseData);

      if (jsonResult['success']) {
        return jsonResult['data']['url']; 
      }
    } catch (e) {
      debugPrint("Error uploading image: $e");
    }
    return null;
  }

  // 🌟 ฟังก์ชันหลักสำหรับบันทึกข้อมูลการจอง
  Future<void> _submitDonationBooking() async {
    // 1. เช็คความพร้อมของข้อมูลสำคัญ
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('กรุณาล็อกอินก่อนทำการบริจาค')));
      return;
    }
    if (foundationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ไม่พบข้อมูลมูลนิธินี้ในระบบ')));
      return;
    }

    // 2. โชว์สถานะกำลังโหลดป้องกันผู้ใช้กดเบิ้ล
    setState(() { isSaving = true; });

    try {
      // 3. วนลูปอัปโหลดรูปภาพทั้งหมดทีละรูป และเก็บ URL ไว้ใน List
      List<String> uploadedImageUrls = [];
      for (var image in widget.selectedImages) {
        if (image is File) {
          String? url = await _uploadSingleImageToImgBB(image);
          if (url != null) {
            uploadedImageUrls.add(url);
          }
        }
      }

      // 4. เตรียมชุดข้อมูล (Schema) ที่จะโยนเข้า Firebase
      final bookingData = {
        'user_id': user.uid,
        'foundation_id': foundationId,
        'foundation_name': widget.foundationName,
        'selected_categories': widget.selectedCategories.map((e) => e.toString()).toList(),
        'others_text': widget.othersText,
        'donation_date': widget.selectedDate != null ? Timestamp.fromDate(widget.selectedDate!) : FieldValue.serverTimestamp(),
        'item_image_urls': uploadedImageUrls, // เก็บลิงก์ที่อัปโหลดสำเร็จแล้ว
        'status': 'pending', // สถานะเริ่มต้นคือรอดำเนินการ
        'created_at': FieldValue.serverTimestamp(), // เวลาปัจจุบันที่กดยืนยัน
      };

      // 5. ส่งข้อมูลขึ้น Firebase Collection 'DonationBookings' (ถ้าไม่มีมันจะสร้างให้เอง)
      final docRef = await FirebaseFirestore.instance.collection('DonationBookings').add(bookingData);
      
      // 6. อัปเดตข้อมูล booking_id กลับเข้าไปในเอกสารตัวมันเอง
      await docRef.update({'booking_id': docRef.id});

     // 7. สำเร็จ! พยายามเปลี่ยนหน้าไปที่หน้า Success
      if (mounted) {
        setState(() { isSaving = false; });

        // 🌟 สร้างแจ้งเตือนเด้งจากด้านบนหน้าจอ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 10,
            behavior: SnackBarBehavior.floating, // ทำให้ลอยได้
            backgroundColor: Colors.green.shade600, // สีพื้นหลังแจ้งเตือน
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // ขอบมนสวยงาม
            // 🌟 ทริคดันแจ้งเตือนไปไว้ด้านบนสุด โดยลบความสูงของหน้าจอออก
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 180, 
              left: 20,
              right: 20,
            ),
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 32),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('ทำรายการสำเร็จ!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('ระบบได้บันทึกการจองบริจาคของคุณแล้ว', style: TextStyle(fontSize: 13, color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 3), // โชว์ค้างไว้ 3 วินาที
          ),
        );

        // 🌟 เปลี่ยนไปหน้า Success หลังโชว์แจ้งเตือน
        context.push('/donation_success');
      }

    } catch (e) {
      // กรณีมีข้อผิดพลาด
      debugPrint('Error saving booking: $e');
      if (mounted) {
        setState(() { isSaving = false; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('เกิดข้อผิดพลาดในการบันทึกข้อมูล กรุณาลองใหม่')));
      }
    }
  }

  // (ส่วนฟังก์ชัน UI ด้านล่าง ยังคงเหมือนเดิม ไม่ต้องเปลี่ยนครับ)
  IconData _getIconForCategory(String title) {
    switch (title) {
      case 'เสื้อผ้า': return Icons.checkroom;
      case 'อาหารและน้ำ': return Icons.fastfood;
      case 'ของเล่นเด็ก': return Icons.smart_toy;
      case 'หนังสือ': return Icons.menu_book;
      case 'อุปกรณ์\nการเรียน': 
      case 'อุปกรณ์การเรียน': return Icons.school;
      case 'อุปกรณ์\nสุขภาพ': 
      case 'อุปกรณ์สุขภาพ': return Icons.medical_services;
      case 'ของใช้\nส่วนตัว': 
      case 'ของใช้ส่วนตัว': return Icons.person;
      case 'ของใช้\nในบ้าน': 
      case 'ของใช้ในบ้าน': return Icons.home;
      default: return Icons.card_giftcard;
    }
  }

  String _formatThaiDate(DateTime? date) {
    if (date == null) return '';
    final List<String> thaiMonths = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];
    final int buddhistYear = date.year + 543;
    return '${date.day} ${thaiMonths[date.month - 1]} $buddhistYear';
  }

  String _buildCategoriesString() {
    List<String> items = [...widget.selectedCategories, if (widget.othersText.isNotEmpty) widget.othersText]
        .map((item) => item.toString().replaceAll('\n', ''))
        .toList();
    
    int n = items.length;
    if (n == 0) return '';
    if (n == 1) return items[0];
    if (n == 2) return '${items[0]} และ ${items[1]}';
    
    String firstPart = items.sublist(0, n - 1).join(', ');
    return '$firstPart และ ${items[n - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    int displayCount = widget.selectedCategories.length > 3 ? 3 : widget.selectedCategories.length;
    int overflowCount = widget.selectedCategories.length > 3 ? widget.selectedCategories.length - 3 : 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/icons/back_arrow.png', width: 35, height: 35),
          onPressed: () => context.pop(),
        ),
        title: const Text('5 / 5', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text('ตรวจสอบข้อมูลให้ถูกต้อง', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 20),

                    Center(child: Text('สิ่งของที่จะบริจาค', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryTeal))),
                    const SizedBox(height: 10),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(displayCount, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(_getIconForCategory(widget.selectedCategories[index].toString()), color: primaryTeal, size: 45),
                          );
                        }),
                        if (overflowCount > 0)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8.0),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                            child: Text('+$overflowCount', style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        _buildCategoriesString(),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Divider(height: 30, thickness: 1),

                    Text('บริจาคให้กับ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryTeal)),
                    const SizedBox(height: 10),
                    
                    isLoadingFoundation 
                      ? const Center(child: CircularProgressIndicator()) 
                      : foundationData == null 
                        ? Center(child: Text('ไม่พบข้อมูลของ ${widget.foundationName} ในระบบ', style: const TextStyle(color: Colors.red)))
                        : _buildFoundationCard(), 

                    const Divider(height: 30, thickness: 1),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ในวันที่', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryTeal)),
                        const SizedBox(width: 20),
                        Expanded(child: Text(_formatThaiDate(widget.selectedDate), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                      ],
                    ),
                    const Divider(height: 30, thickness: 1),

                    Text('รูปภาพสิ่งของ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryTeal)),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.selectedImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              widget.selectedImages[index] as File,
                              width: double.infinity,
                              height: 300,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),

                    // 🌟 ปุ่มยืนยันข้อมูล
                    SizedBox(
                      width: double.infinity,
                      height: 65,
                      child: ElevatedButton(
                        // 🌟 ถ้าระบบกำลังเซฟอยู่ ให้ปิดการกดซ้ำ และถ้าไม่ใช่ก็ให้เรียกฟังก์ชันบันทึก
                        onPressed: isSaving ? null : _submitDonationBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          disabledBackgroundColor: Colors.grey.shade400, // สีปุ่มตอนกำลังโหลด
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 🌟 ถ้ากำลังเซฟอยู่ โชว์วงกลมหมุนๆ ถ้าไม่ใช่โชว์ข้อความปกติ
                            isSaving 
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                              : const Text('ยืนยันข้อมูล', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                            
                            if (!isSaving) ...[
                              const SizedBox(width: 15),
                              const Icon(Icons.arrow_circle_right_outlined, color: Colors.white, size: 30),
                            ]
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoundationCard() {
    Color logoColor = Colors.grey.shade200;
    if (foundationData!['logoColor'] != null) {
      try {
        String hexStr = foundationData!['logoColor'].toString().replaceAll('0x', '').replaceAll('#', '');
        if (hexStr.length == 6) hexStr = 'FF$hexStr';
        logoColor = Color(int.parse(hexStr, radix: 16));
      } catch (e) {}
    }
    String? logoImage = foundationData!['logoImage'];

    List<String> itemsList = List<String>.from(foundationData!['neededItems'] ?? []);
    String acceptedItemsText = itemsList.join('/');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: logoImage != null ? Colors.white : logoColor,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            image: logoImage != null 
                ? DecorationImage(image: NetworkImage(logoImage), fit: BoxFit.contain)
                : null,
          ),
          child: logoImage == null
              ? const Center(child: Icon(Icons.volunteer_activism, size: 40, color: Colors.black87))
              : null,
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
                      foundationData!['name'] ?? widget.foundationName, 
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), 
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis
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
                maxLines: 2, 
                overflow: TextOverflow.ellipsis
              ),
              const SizedBox(height: 6),
              Row(
                children: itemsList.take(4).map((itemTitle) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Icon(_getIconForCategory(itemTitle), color: primaryTeal, size: 18),
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