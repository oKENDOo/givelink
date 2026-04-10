import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:geolocator/geolocator.dart'; 
import 'news_detail_screen.dart'; 
import 'package:go_router/go_router.dart';
import 'dart:async'; // สำหรับดักจับ Stream

class BannerItem {
  final String categoryTitle;
  final String foundationName;
  final String imageUrl;
  final Color fallbackColor;
  final String content; 

  BannerItem({
    required this.categoryTitle,
    required this.foundationName,
    required this.imageUrl,
    required this.fallbackColor,
    required this.content,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color primaryBlue = const Color(0xFF64B5C7);
  String userName = 'ผู้ใช้งาน';
  String? photoUrl; 

  late PageController _pageController;
  int _currentPage = 0;
  
  Position? _currentPosition;
  late Stream<QuerySnapshot> _foundationsStream; 

  // 🌟 เพิ่มตัวแปรนี้ เพื่อสร้างตัวแปรเก็บสถานะการดักฟังฐานข้อมูล
  StreamSubscription<QuerySnapshot>? _donationSubscription;

  final List<BannerItem> bannerData = [
    BannerItem(
      categoryTitle: 'สนับสนุนเครื่องมือแพทย์',
      foundationName: 'มูลนิธิรามาธิบดี',
      imageUrl: 'https://www.ramafoundation.or.th/give/uploads/projects/thumbnail/68f05ae2421f5.jpg',
      fallbackColor: Colors.pink.shade100,
      content: 'ปัจจุบันโรงพยาบาลยังขาดแคลนเครื่องช่วยหายใจและเครื่องฟอกไตจำนวนมาก... การบริจาคของคุณจะช่วยต่อลมหายใจให้ผู้ป่วยวิกฤตได้โดยตรง โดยเงินบริจาคจะนำไปจัดซื้ออุปกรณ์การแพทย์ที่ทันสมัยเพื่อรองรับผู้ป่วยที่เพิ่มขึ้นในแต่ละวันร่วมเป็นส่วนหนึ่งของการให้ที่ยิ่งใหญ่ได้วันนี้',
    ),
    BannerItem(
      categoryTitle: 'ช่วยเหลือเด็กด้อยโอกาส',
      foundationName: 'มูลนิธิเด็กวิลล่า',
      imageUrl: 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
      fallbackColor: Colors.blue.shade100,
      content: 'เด็กๆ ในพื้นที่ห่างไกลยังขาดอุปกรณ์การเรียนและสารอาหารที่จำเป็น... โครงการนี้มีเป้าหมายเพื่อมอบทุนการศึกษาและมื้ออาหารกลางวันที่ถูกสุขลักษณะให้กับเด็กกว่า 500 คน การสนับสนุนเพียงเล็กน้อยของคุณสามารถเปลี่ยนอนาคตของเด็กหนึ่งคนให้ดีขึ้นได้อย่างยั่งยืน',
    ),
    BannerItem(
      categoryTitle: 'อนุรักษ์สิ่งแวดล้อม',
      foundationName: 'กองทุนสัตว์ป่าโลก (WWF)',
      imageUrl: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
      fallbackColor: Colors.green.shade100,
      content: 'วิกฤตภาวะโลกร้อนส่งผลกระทบต่อถิ่นที่อยู่อาศัยของสัตว์ป่าไทยอย่างรุนแรง... เรามุ่งเน้นการฟื้นฟูป่าต้นน้ำและการเฝ้าระวังการล่าสัตว์ป่าผิดกฎหมาย เงินสนับสนุนจะถูกนำไปใช้ในโครงการฟื้นฟูป่าและจัดซื้ออุปกรณ์เดินป่าให้กับเจ้าหน้าที่พิทักษ์ป่าทั่วประเทศ',
    ),
  ];

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  Map<DateTime, List<Map<String, dynamic>>> _donationEvents = {};
  List<Map<String, dynamic>> _recentNotifications = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _getCurrentLocation(); 
    _pageController = PageController(initialPage: 0);
    _selectedDay = _focusedDay; 
    _listenToDonationEvents(); 
    
    _foundationsStream = FirebaseFirestore.instance.collection('Foundations').snapshots();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _donationSubscription?.cancel(); // 🌟 ยกเลิกการดักฟังเมื่อเปลี่ยนหน้า ป้องกันแอปค้าง!
    super.dispose();
  }

  void _listenToDonationEvents() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 🌟 นำ _donationSubscription มารับค่าการ listen
    _donationSubscription = FirebaseFirestore.instance
        .collection('DonationBookings')
        .where('user_id', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
      
      final Map<DateTime, List<Map<String, dynamic>>> newEvents = {};
      List<Map<String, dynamic>> allNotifications = []; 
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['booking_id'] = doc.id; 

        String currentStatus = data['status'] ?? 'pending';
        
        List<dynamic> dismissedList = data['dismissed_statuses'] ?? [];
        if (data['is_notification_dismissed'] == true && data['dismissed_status'] == null) {
          dismissedList.add('pending'); 
        } else if (data['dismissed_status'] != null && !dismissedList.contains(data['dismissed_status'])) {
          dismissedList.add(data['dismissed_status']); 
        }

        if (!dismissedList.contains('pending')) {
          allNotifications.add({
            ...data,
            'notification_type': 'pending', 
            'sort_time': data['created_at'],
          });
        }

        if (currentStatus == 'completed' || currentStatus == 'success') {
          if (!dismissedList.contains('completed')) {
            allNotifications.add({
              ...data,
              'notification_type': 'completed', 
              'sort_time': data['created_at'],
            });
          }
        } else if (currentStatus == 'cancelled' || currentStatus == 'cancel') {
          if (!dismissedList.contains('cancelled')) {
            allNotifications.add({
              ...data,
              'notification_type': 'cancelled',
              'sort_time': data['created_at'],
            });
          }
        }

        if (data['donation_date'] != null) {
          DateTime date = (data['donation_date'] as Timestamp).toDate();
          DateTime normalizedDate = DateTime.utc(date.year, date.month, date.day);
          if (newEvents[normalizedDate] == null) newEvents[normalizedDate] = [];
          newEvents[normalizedDate]!.add(data);
        }
      }
      
      allNotifications.sort((a, b) {
        Timestamp? timeA = a['sort_time'] as Timestamp?;
        Timestamp? timeB = b['sort_time'] as Timestamp?;
        if (timeA == null || timeB == null) return 0;
        int timeCompare = timeB.compareTo(timeA);
        if (timeCompare == 0) {
           if (a['notification_type'] == 'completed' && b['notification_type'] == 'pending') return -1;
           if (a['notification_type'] == 'pending' && b['notification_type'] == 'completed') return 1;
        }
        return timeCompare;
      });

      if (mounted) {
        setState(() {
          _donationEvents = newEvents;
          _recentNotifications = allNotifications; 
        });
      }
    });
  }

  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    user?.reload().then((_) {
      final updatedUser = FirebaseAuth.instance.currentUser;
      if (updatedUser != null && mounted) {
        setState(() {
          userName = updatedUser.displayName ?? updatedUser.email?.split('@')[0] ?? 'ผู้ใช้งาน';
          photoUrl = updatedUser.photoURL;
        });
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return; 

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
      _currentPosition!.latitude, _currentPosition!.longitude, targetLat, targetLng,
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

  void _navigateToNews(BannerItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailScreen(
          title: item.categoryTitle,
          foundation: item.foundationName,
          content: item.content,
          imageUrl: item.imageUrl,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return _donationEvents[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = bannerData[_currentPage];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<User?>(
                stream: FirebaseAuth.instance.userChanges(),
                builder: (context, snapshot) {
                  final currentUser = snapshot.data ?? FirebaseAuth.instance.currentUser;
                  final currentName = currentUser?.displayName ?? currentUser?.email?.split('@')[0] ?? 'ผู้ใช้งาน';
                  final currentPhotoUrl = currentUser?.photoURL;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.go('/user'),
                            child: Container(
                              width: 50, height: 50,
                              decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                              child: ClipOval(
                                child: (currentPhotoUrl != null && currentPhotoUrl.isNotEmpty)
                                    ? Image.network(currentPhotoUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 30, color: Colors.grey))
                                    : Image.network('https://cdn-icons-png.flaticon.com/512/3135/3135715.png', fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 30, color: Colors.grey)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(currentName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Badge(
                            isLabelVisible: _recentNotifications.isNotEmpty, 
                            label: Text(_recentNotifications.length > 9 ? '9+' : '${_recentNotifications.length}'), 
                            offset: const Offset(-5, 5),
                            child: IconButton(
                              onPressed: _showNotificationsSheet, 
                              icon: const Icon(Icons.notifications_none, color: Colors.black, size: 28),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('สวัสดี $currentName มาทำความดีกันเถอะ !', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold,color: Color(0xFF64B5C7))),
                    ],
                  );
                }
              ),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: () => _navigateToNews(currentItem),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(currentItem.categoryTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_circle_right_outlined, color: Colors.grey.shade800),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      if (_currentPage > 0) _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    },
                    icon: Icon(Icons.arrow_back_ios, color: _currentPage == 0 ? Colors.grey : Colors.black),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 170,
                      width: 100,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: bannerData.length,
                        onPageChanged: (int index) => setState(() => _currentPage = index),
                        itemBuilder: (context, index) {
                          final item = bannerData[index];
                          return GestureDetector(
                            onTap: () => _navigateToNews(item),
                            child: Container(
                              decoration: BoxDecoration(
                                color: item.fallbackColor,
                                borderRadius: BorderRadius.circular(16),
                                image: DecorationImage(image: NetworkImage(item.imageUrl), fit: BoxFit.cover),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_currentPage < bannerData.length - 1) _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    },
                    icon: Icon(Icons.arrow_forward_ios, color: _currentPage == bannerData.length - 1 ? Colors.grey : Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Center(child: Text(currentItem.foundationName, style: const TextStyle(color: Colors.grey))),

              const SizedBox(height: 30),

              const Text('มูลนิธิใกล้ฉัน', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              StreamBuilder<QuerySnapshot>(
                stream: _foundationsStream, 
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('ไม่พบข้อมูลมูลนิธิ', style: TextStyle(color: Colors.grey)));
                  }

                  final foundations = snapshot.data!.docs.toList();

                  if (_currentPosition != null) {
                    foundations.sort((a, b) {
                      GeoPoint? locA = (a.data() as Map<String, dynamic>)['location'];
                      GeoPoint? locB = (b.data() as Map<String, dynamic>)['location'];
                      
                      if (locA == null || locB == null) return 0;
                      
                      double distA = Geolocator.distanceBetween(_currentPosition!.latitude, _currentPosition!.longitude, locA.latitude, locA.longitude);
                      double distB = Geolocator.distanceBetween(_currentPosition!.latitude, _currentPosition!.longitude, locB.latitude, locB.longitude);
                      
                      return distA.compareTo(distB);
                    });
                  }

                  final nearestFoundations = foundations.take(3).toList();

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: nearestFoundations.length,
                    separatorBuilder: (context, index) => const Divider(height: 30),
                    itemBuilder: (context, index) {
                      final data = nearestFoundations[index].data() as Map<String, dynamic>;
                      
                      List<String> itemsList = List<String>.from(data['neededItems'] ?? []);
                      String acceptedItemsText = itemsList.join('/');
                      
                      Color logoColor = Colors.grey.shade200;
                      if (data['logoColor'] != null) {
                        try {
                          String hexStr = data['logoColor'].toString().replaceAll('0x', '').replaceAll('#', '');
                          if (hexStr.length == 6) hexStr = 'FF$hexStr';
                          logoColor = Color(int.parse(hexStr, radix: 16));
                        } catch (e) {}
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
                            'selectedCategories': [],
                            'othersText': '',
                          };
                          context.push('/donation_foundation_detail', extra: realDetailData);
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(
                                color: logoImage != null ? Colors.white : logoColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                                image: logoImage != null 
                                    ? DecorationImage(image: NetworkImage(logoImage), fit: BoxFit.contain)
                                    : null,
                              ),
                              child: logoImage == null
                                  ? const Icon(Icons.volunteer_activism, color: Colors.black87, size: 40)
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
                                          data['name'] ?? 'ไม่มีชื่อ', 
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), 
                                          maxLines: 1, 
                                          overflow: TextOverflow.ellipsis
                                        )
                                      ),
                                      if (data['isVerified'] == true) ...[
                                        const SizedBox(width: 4),
                                        const Icon(Icons.verified, color: Colors.blue, size: 18), 
                                      ]
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(acceptedItemsText, style: const TextStyle(color: Colors.grey, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 14, color: Colors.redAccent),
                                      const SizedBox(width: 4),
                                      Text(calculatedDistance, style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: itemsList.take(4).map((itemTitle) => Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: Icon(_getIconForCategory(itemTitle), color: primaryBlue, size: 20),
                                    )).toList(),
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
              GestureDetector(
                onTap: () => context.go('/map'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('ค้นหามูลนิธิเพิ่มเติม', style: TextStyle(fontWeight: FontWeight.bold,)),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_circle_right_outlined, color: primaryBlue),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              const Center(
                child: Text('ประวัติการบริจาคของฉัน', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 230, 250, 255).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(8),
              child: TableCalendar(
                  // 🌟 แก้ปัญหาตัวหนังสือ Sun Mon โดนตัดครึ่ง โดยการเพิ่มความสูงของแถว
                  daysOfWeekHeight: 30,

                  // 🌟 เพิ่มบรรทัดนี้ เพื่อให้ปฏิทินรับแค่การปัดซ้ายขวา แล้วปล่อยให้ปัดบนล่างเลื่อนหน้าจอได้
                  availableGestures: AvailableGestures.horizontalSwipe,
                  
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: _getEventsForDay, 
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  calendarStyle: CalendarStyle(
                    markerDecoration: BoxDecoration(color: primaryBlue, shape: BoxShape.circle),
                    selectedDecoration: const BoxDecoration(color: Colors.orangeAccent, shape: BoxShape.circle),
                    todayDecoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle),
                    todayTextStyle: const TextStyle(color: Colors.black),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _buildEventList(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventList() {
    final selectedEvents = _getEventsForDay(_selectedDay ?? _focusedDay);

    if (selectedEvents.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text('ไม่มีประวัติการบริจาคในวันนี้', style: TextStyle(color: Colors.grey, fontSize: 15)),
        ),
      );
    }

    return Column(
      children: selectedEvents.map((event) {
        String foundationName = event['foundation_name'] ?? 'ไม่ระบุชื่อมูลนิธิ';
        
        List<dynamic> categories = event['selected_categories'] ?? [];
        String others = event['others_text'] ?? '';
        List<String> allItems = categories.map((e) => e.toString().replaceAll('\n', '')).toList();
        if (others.isNotEmpty) allItems.add(others);
        
        String itemsText = 'ไม่ระบุ';
        if (allItems.isNotEmpty) {
          if (allItems.length <= 2) {
            itemsText = allItems.join(', ');
          } else {
            itemsText = '${allItems.take(2).join(', ')} +${allItems.length - 2}';
          }
        }

        String statusRaw = event['status'] ?? 'pending';
        String statusText = 'กำลังดำเนินการ';
        Color statusColor = Colors.orange;
        
        if (statusRaw == 'completed' || statusRaw == 'success') {
          statusText = 'เสร็จสิ้น';
          statusColor = Colors.green;
        } else if (statusRaw == 'cancelled' || statusRaw == 'cancel') {
          statusText = 'ยกเลิก';
          statusColor = Colors.red;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.inventory_2_outlined, color: primaryBlue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(foundationName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('บริจาค: $itemsText', style: const TextStyle(color: Colors.grey, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6, 
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 16),
                  const Text('การแจ้งเตือน', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('ปัดไปทางซ้ายเพื่อลบการแจ้งเตือน', style: TextStyle(fontSize: 12, color: Colors.grey)), 
                  const Divider(height: 20),
                  
                  Expanded(
                    child: _recentNotifications.isEmpty
                        ? const Center(child: Text('ไม่มีการแจ้งเตือนใหม่', style: TextStyle(color: Colors.grey)))
                        : ListView.separated(
                            itemCount: _recentNotifications.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final notif = _recentNotifications[index];
                              
                              final notifType = notif['notification_type'] ?? 'pending';
                              
                              String title = '';
                              String body = '';
                              IconData icon = Icons.check_circle;
                              Color iconColor = Colors.green;

                              if (notifType == 'completed') {
                                title = 'บริจาคเสร็จสิ้น!';
                                body = 'มูลนิธิได้รับสิ่งของบริจาคของคุณแล้ว ขอบคุณที่ร่วมแบ่งปันสิ่งดีๆ ครับ';
                                icon = Icons.volunteer_activism;
                                iconColor = primaryBlue;
                              } else if (notifType == 'cancelled') {
                                title = 'ยกเลิกการจอง';
                                body = 'รายการบริจาคให้กับ ${notif['foundation_name'] ?? 'มูลนิธิ'} ถูกยกเลิกเรียบร้อยแล้ว';
                                icon = Icons.cancel;
                                iconColor = Colors.red;
                              } else {
                                title = 'จองการบริจาคสำเร็จ!';
                                body = 'คุณได้จองการบริจาคกับ ${notif['foundation_name'] ?? 'มูลนิธิ'} แล้ว ระบบกำลังรอดำเนินการ';
                                icon = Icons.check_circle;
                                iconColor = Colors.green;
                              }

                              return Dismissible(
                                key: Key('${notif['booking_id']}_$notifType'), 
                                direction: DismissDirection.endToStart, 
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: const Icon(Icons.delete, color: Colors.white, size: 30),
                                ),
                                onDismissed: (direction) {
                                  if (notif['booking_id'] != null) {
                                    FirebaseFirestore.instance
                                        .collection('DonationBookings')
                                        .doc(notif['booking_id'])
                                        .update({
                                          'dismissed_statuses': FieldValue.arrayUnion([notifType]), 
                                          'dismissed_status': notifType, 
                                          'is_notification_dismissed': true, 
                                        });
                                  }

                                  setSheetState(() {
                                    _recentNotifications.removeAt(index);
                                  });
                                  
                                  setState(() {});
                                },
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                  leading: CircleAvatar(
                                    radius: 24,
                                    backgroundColor: iconColor.withOpacity(0.1),
                                    child: Icon(icon, color: iconColor, size: 28),
                                  ),
                                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(body, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }
}