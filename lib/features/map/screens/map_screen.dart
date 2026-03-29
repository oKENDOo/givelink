import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../../widgets/custom_bottom_nav.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Color primaryBlue = const Color(0xFF64B5C7);
  final MapController _mapController = MapController(); 

  LatLng? _currentPosition;
  bool _isLoadingLocation = true; 

  @override
  void initState() {
    super.initState();
    _getUserLocation(); 
  }

  Future<void> _getUserLocation() async {
    const fallbackPosition = LatLng(13.7944, 100.3246); 

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() { _currentPosition = fallbackPosition; _isLoadingLocation = false; });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() { _currentPosition = fallbackPosition; _isLoadingLocation = false; });
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() { _currentPosition = fallbackPosition; _isLoadingLocation = false; });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if (mounted) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false; 
      });
    }
  }

  Future<void> _moveToCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('กรุณาเปิด GPS')));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('คุณปฏิเสธการเข้าถึงตำแหน่ง')));
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('คุณปฏิเสธการเข้าถึงตำแหน่งถาวร กรุณาไปแก้ในตั้งค่า')));
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    
    if (mounted) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_currentPosition!, 15.0);
    }
  }

  // 🌟 1. เพิ่มฟังก์ชันคำนวณระยะทาง
  String _calculateDistance(double? targetLat, double? targetLng) {
    if (_currentPosition == null || targetLat == null || targetLng == null) {
      return 'กำลังคำนวณ...'; 
    }
    double distanceInMeters = Geolocator.distanceBetween(
      _currentPosition!.latitude, _currentPosition!.longitude, targetLat, targetLng,
    );
    double distanceInKm = distanceInMeters / 1000;
    return '${distanceInKm.toStringAsFixed(1)} Km';
  }

  // 🌟 2. เพิ่มฟังก์ชันแปลงชื่อสิ่งของเป็นไอคอน
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoadingLocation 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: primaryBlue),
                const SizedBox(height: 16),
                const Text('กำลังค้นหาตำแหน่งของคุณ...', style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          )
        : Stack( 
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition!, 
                initialZoom: 15.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate, 
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.givelink', 
                ),
                
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('Foundations').snapshots(),
                  builder: (context, snapshot) {
                    List<Marker> allMarkers = [];

                    if (_currentPosition != null) {
                      allMarkers.add(
                        Marker(
                          point: _currentPosition!,
                          width: 50,
                          height: 50,
                          child: const Icon(Icons.location_on, color: Colors.red, size: 50),
                        ),
                      );
                    }

                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      for (var doc in snapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        GeoPoint? geoPoint = data['location'];
                        
                        if (geoPoint != null) {
                          allMarkers.add(
                            Marker(
                              point: LatLng(geoPoint.latitude, geoPoint.longitude),
                              width: 50,
                              height: 50,
                              child: GestureDetector(
                                onTap: () {
                                  List<String> itemsList = List<String>.from(data['neededItems'] ?? []);
                                  
                                  // 🌟 3. เรียกใช้สูตรคำนวณระยะทาง
                                  String calculatedDistance = _calculateDistance(geoPoint.latitude, geoPoint.longitude);
                                  
                                  final detailData = {
                                    'name': data['name'] ?? 'ไม่มีชื่อ',
                                    'address': data['address'] ?? '',
                                    'rating': data['rating'] ?? '0.0',
                                    'hours': data['hours'] ?? '',
                                    'distance': calculatedDistance, // ส่งค่าที่คำนวณแล้วไป
                                    'isVerified': data['isVerified'] ?? false,
                                    'phone': data['phone'] ?? '',
                                    'facebook': data['facebook'] ?? '',
                                    'website': data['website'] ?? '',
                                    'coverImage': data['coverImage'] ?? 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?q=80&w=600&auto=format&fit=crop', 
                                    'mapImage': data['mapImage'] ?? 'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=600&auto=format&fit=crop',
                                    'latitude': geoPoint.latitude,
                                    'longitude': geoPoint.longitude,
                                    // 🌟 4. เรียกใช้ฟังก์ชันแปลงไอคอน
                                    'neededItems': itemsList.map((item) => {
                                      'title': item,
                                      'icon': _getIconForCategory(item), 
                                    }).toList(),
                                    'selectedCategories': [],
                                    'othersText': '',
                                  };
                                  context.push('/donation_foundation_detail', extra: detailData);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white, 
                                    shape: BoxShape.circle,
                                    border: Border.all(color: primaryBlue, width: 2.5), 
                                    boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 3))], 
                                  ),
                                  child: ClipOval(
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0), 
                                      child: Image.asset(
                                        'assets/images/logo_crop.png',
                                        fit: BoxFit.contain, 
                                        errorBuilder: (context, error, stackTrace) => Icon(Icons.volunteer_activism, color: primaryBlue, size: 24),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      }
                    }

                    return MarkerLayer(markers: allMarkers);
                  },
                ),
              ],
            ),

            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'ค้นหามูลนิธิใกล้ฉัน',
                    prefixIcon: const Icon(Icons.search, color: Colors.black),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 20,
              right: 20,
              child: GestureDetector(
                onTap: _moveToCurrentLocation, 
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                    ],
                  ),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 0), 
                      child: Icon(Icons.near_me, color: Colors.white, size: 30),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }
}