import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart'; // 🌟 1. นำเข้า Geolocator
import  '../../widgets/custom_bottom_nav.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Color primaryBlue = const Color(0xFF64B5C7);
  
  // 🌟 2. สร้าง MapController เพื่อควบคุมการย้ายแผนที่
  final MapController _mapController = MapController(); 

  // พิกัดเริ่มต้น (มหาวิทยาลัยมหิดล ศาลายา)
  final LatLng _initialPosition = const LatLng(13.7944, 100.3246);

  // 🌟 3. ฟังก์ชันดึงพิกัดปัจจุบันและสั่งย้ายแผนที่
  Future<void> _moveToCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // ตรวจสอบว่าเปิด GPS หรือไม่
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณาเปิด GPS (Location Service)')));
      }
      return;
    }

    // ตรวจสอบและขอสิทธิ์การใช้ตำแหน่ง
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('คุณปฏิเสธการเข้าถึงตำแหน่ง')));
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('คุณปฏิเสธการเข้าถึงตำแหน่งถาวร กรุณาไปแก้ในตั้งค่า')));
      }
      return;
    }

    // ดึงพิกัดปัจจุบัน (high accuracy)
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    // สั่งให้ MapController ย้ายแผนที่ไปที่ตำแหน่งใหม่
    _mapController.move(LatLng(position.latitude, position.longitude), 15.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // --- 1. แผนที่ OpenStreetMap ---
            FlutterMap(
              mapController: _mapController, // 🌟 อย่าลืมผูก MapController ตรงนี้
              options: MapOptions(
                initialCenter: _initialPosition,
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
                
                // ชั้นสำหรับวางหมุด
                MarkerLayer(
                  markers: [
                    // หมุดที่ 1: หมุดสีแดง (ตำแหน่งเริ่มต้น/มหาลัย)
                    Marker(
                      point: _initialPosition,
                      width: 50,
                      height: 50,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 50),
                    ),
                    
                    // หมุดที่ 2: มูลนิธิกระจกเงา
                    Marker(
                      point: const LatLng(13.7965, 100.3280),
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D3061), 
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                        child: const Icon(Icons.volunteer_activism, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // --- 2. แถบค้นหา ด้านบน ---
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

// 🌟 4. ปุ่มย้ายกลับมาตำแหน่งปัจจุบัน (สไตล์ตามรูปเป๊ะๆ)
            Positioned(
              bottom: 20,
              right: 20,
              child: GestureDetector(
                onTap: _moveToCurrentLocation, // เมื่อกด ให้เรียกฟังก์ชันดึงตำแหน่ง
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: primaryBlue, // พื้นหลังสีฟ้า
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2), // ขอบสีดำ
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                    ],
                  ),
                  child: const Center(
                    child: Padding(
                      // ขยับไอคอนนิดหน่อยให้ดูอยู่ตรงกลางสวยๆ
                      padding: EdgeInsets.only(bottom: 0), 
                      child: Icon(
                        Icons.near_me, // ไอคอนลูกศร
                        color: Colors.white, // ลูกศรสีขาว
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // แถบเมนูด้านล่างสุด
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }
}