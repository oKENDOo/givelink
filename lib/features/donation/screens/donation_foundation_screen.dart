import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart'; 
import '../../widgets/custom_bottom_nav.dart';

class DonationFoundationScreen extends StatefulWidget {
  final List<String> selectedCategories;
  final String othersText;

  const DonationFoundationScreen({
    super.key,
    required this.selectedCategories,
    required this.othersText,
  });

  @override
  State<DonationFoundationScreen> createState() => _DonationFoundationScreenState();
}

class _DonationFoundationScreenState extends State<DonationFoundationScreen> {
  final Color primaryTeal = const Color(0xFF64B5C7);
  
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); 
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permissions are denied');
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permissions are permanently denied.');
      return;
    } 

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if (mounted) {
      setState(() {
        _currentPosition = position;
      });
    }
  }

  String _calculateDistance(double? targetLat, double? targetLng) {
    if (_currentPosition == null || targetLat == null || targetLng == null) {
      return 'กำลังคำนวณ...'; 
    }

    double distanceInMeters = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      targetLat,
      targetLng,
    );

    double distanceInKm = distanceInMeters / 1000;
    return '${distanceInKm.toStringAsFixed(1)} Km';
  }

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
        title: const Text('2 / 5', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25)),
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
                    const Center(child: Text('คุณอยากบริจาคที่ไหน ?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                    const SizedBox(height: 10),
                    Center(child: Text('สิ่งของที่จะบริจาค', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryTeal))),
                    const SizedBox(height: 10),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(displayCount, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(_getIconForCategory(widget.selectedCategories[index]), color: primaryTeal, size: 40),
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
                    if (widget.othersText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Center(child: Text('อื่นๆ: ${widget.othersText}', style: const TextStyle(fontSize: 16, color: Colors.grey))),
                      ),

                    const SizedBox(height: 50),

                    const Text('เลือกมูลนิธิที่เปิดรับบริจาค', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(thickness: 1, height: 20),
                    
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('Foundations').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('ไม่พบข้อมูลมูลนิธิในขณะนี้', style: TextStyle(color: Colors.grey)));
                        }

                        final allFoundations = snapshot.data!.docs.toList();
                        List<QueryDocumentSnapshot> filteredFoundations = [];

                        List<String> cleanSelected = widget.selectedCategories.map((e) => e.replaceAll('\n', '')).toList();

                        if (widget.othersText.trim().isNotEmpty) {
                          filteredFoundations = allFoundations;
                        } else {
                          filteredFoundations = allFoundations.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final neededItems = List<String>.from(data['neededItems'] ?? []);
                            return cleanSelected.any((item) => neededItems.contains(item));
                          }).toList();
                        }

                        if (filteredFoundations.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text(
                                'ยังไม่มีมูลนิธิเปิดรับของชนิดนี้ ในเวลานี้ครับ :)',
                                style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }

                        if (_currentPosition != null) {
                          filteredFoundations.sort((a, b) {
                            GeoPoint? locA = (a.data() as Map<String, dynamic>)['location'];
                            GeoPoint? locB = (b.data() as Map<String, dynamic>)['location'];
                            
                            if (locA == null || locB == null) return 0;
                            
                            double distA = Geolocator.distanceBetween(_currentPosition!.latitude, _currentPosition!.longitude, locA.latitude, locA.longitude);
                            double distB = Geolocator.distanceBetween(_currentPosition!.latitude, _currentPosition!.longitude, locB.latitude, locB.longitude);
                            
                            return distA.compareTo(distB);
                          });
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredFoundations.length, 
                          separatorBuilder: (context, index) => const Divider(height: 30),
                          itemBuilder: (context, index) {
                            final data = filteredFoundations[index].data() as Map<String, dynamic>; 
                            
                            List<String> itemsList = List<String>.from(data['neededItems'] ?? []);
                            String acceptedItemsText = itemsList.join('/');
                            
                            Color logoColor = Colors.grey.shade200;
                            if (data['logoColor'] != null) {
                              try {
                                String hexStr = data['logoColor'].toString().replaceAll('0x', '').replaceAll('#', '');
                                if (hexStr.length == 6) hexStr = 'FF$hexStr';
                                logoColor = Color(int.parse(hexStr, radix: 16));
                              } catch (e) {
                                debugPrint('Color parse error: $e');
                              }
                            }
                            String? logoImage = data['logoImage'];

                            GeoPoint? geoPoint = data['location'];
                            double? lat = geoPoint?.latitude;
                            double? lng = geoPoint?.longitude;

                            String calculatedDistance = _calculateDistance(lat, lng);

                            return InkWell(
                              onTap: () {
                                final realDetailData = {
                                  'name': data['name'] ?? 'ไม่มีชื่อ',
                                  'address': data['address'] ?? '',
                                  'rating': data['rating'] ?? '0.0',
                                  'hours': data['hours'] ?? '',
                                  'distance': calculatedDistance, 
                                  'isVerified': data['isVerified'] ?? false,
                                  'phone': data['phone'] ?? '',
                                  'facebook': data['facebook'] ?? '',
                                  'website': data['website'] ?? '',
                                  'coverImage': data['coverImage'] ?? 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?q=80&w=600&auto=format&fit=crop', 
                                  'mapImage': data['mapImage'] ?? 'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=600&auto=format&fit=crop',
                                  'latitude': lat, 
                                  'longitude': lng, 
                                  'neededItems': itemsList.map((item) => {
                                    'title': item,
                                    'icon': _getIconForCategory(item),
                                  }).toList(),
                                  'selectedCategories': widget.selectedCategories,
                                  'othersText': widget.othersText,
                                };

                                context.push('/donation_foundation_detail', extra: realDetailData);
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      color: logoImage != null ? Colors.white : logoColor,
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                      image: logoImage != null 
                                          ? DecorationImage(image: NetworkImage(logoImage), fit: BoxFit.contain)
                                          : null,
                                    ),
                                    child: logoImage == null
                                        ? const Center(child: Icon(Icons.volunteer_activism, size: 50, color: Colors.black87))
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 🌟 ปรับให้ติ๊กถูกติดกับชื่อ
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                data['name'] ?? 'ไม่มีชื่อ', 
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (data['isVerified'] == true) ...[
                                              const SizedBox(width: 4),
                                              const Icon(Icons.verified, color: Colors.blue, size: 18),
                                            ]
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(acceptedItemsText, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on, size: 14, color: Colors.redAccent),
                                            const SizedBox(width: 4),
                                            Text(calculatedDistance, style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: itemsList.take(4).map((itemTitle) {
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 8.0),
                                              child: Icon(_getIconForCategory(itemTitle), color: primaryTeal, size: 22),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
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
}