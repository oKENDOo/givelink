import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'news_detail_screen.dart'; // 🌟 นำเข้าหน้าข่าวสาร

class BannerItem {
  final String categoryTitle;
  final String foundationName;
  final String imageUrl;
  final Color fallbackColor;
  final String content; // เนื้อหาข่าว

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

  late PageController _pageController;
  int _currentPage = 0;

  // 🌟 ข้อมูล Banner พร้อมเนื้อหาข่าว 3 แบบ
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
      imageUrl: 'https://via.placeholder.com/600x400/7f7fff/ffffff?text=Children+Foundation',
      fallbackColor: Colors.blue.shade100,
      content: 'เด็กๆ ในพื้นที่ห่างไกลยังขาดอุปกรณ์การเรียนและสารอาหารที่จำเป็น... โครงการนี้มีเป้าหมายเพื่อมอบทุนการศึกษาและมื้ออาหารกลางวันที่ถูกสุขลักษณะให้กับเด็กกว่า 500 คน การสนับสนุนเพียงเล็กน้อยของคุณสามารถเปลี่ยนอนาคตของเด็กหนึ่งคนให้ดีขึ้นได้อย่างยั่งยืน',
    ),
    BannerItem(
      categoryTitle: 'อนุรักษ์สิ่งแวดล้อม',
      foundationName: 'กองทุนสัตว์ป่าโลก (WWF)',
      imageUrl: 'https://via.placeholder.com/600x400/7fff7f/333333?text=WWF+Thailand',
      fallbackColor: Colors.green.shade100,
      content: 'วิกฤตภาวะโลกร้อนส่งผลกระทบต่อถิ่นที่อยู่อาศัยของสัตว์ป่าไทยอย่างรุนแรง... เรามุ่งเน้นการฟื้นฟูป่าต้นน้ำและการเฝ้าระวังการล่าสัตว์ป่าผิดกฎหมาย เงินสนับสนุนจะถูกนำไปใช้ในโครงการฟื้นฟูป่าและจัดซื้ออุปกรณ์เดินป่าให้กับเจ้าหน้าที่พิทักษ์ป่าทั่วประเทศ',
    ),
  ];

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late final Map<DateTime, List<String>> _donationEvents;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _pageController = PageController(initialPage: 0);

    final today = DateTime.now();
    _donationEvents = {
      DateTime(today.year, today.month, today.day + 2): ['บริจาคมูลนิธิกระจกเงา'],
      DateTime(today.year, today.month, today.day + 5): ['บริจาคมูลนิธิเพื่อคนพิการ'],
    };
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    user?.reload().then((_) {
      final updatedUser = FirebaseAuth.instance.currentUser;
      if (updatedUser != null && mounted) {
        setState(() {
          userName = updatedUser.displayName ?? updatedUser.email?.split('@')[0] ?? 'ผู้ใช้งาน';
        });
      }
    });
  }

  // 🌟 ฟังก์ชันเปลี่ยนหน้าไปยัง NewsDetailScreen
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

  List<String> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
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
              // --- 1. ส่วนหัว ---
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage('https://cdn-icons-png.flaticon.com/512/3135/3135715.png'),
                  ),
                  const SizedBox(width: 12),
                  Text(userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Colors.black)),
                ],
              ),
              const SizedBox(height: 16),
              Text('สวัสดี $userName มาทำความดีกันเถอะ !', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

              const SizedBox(height: 20),

              // --- 2. ส่วนหัวข้อแบนเนอร์ (กดได้) ---
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
                      if (_currentPage > 0) {
                        _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      }
                    },
                    icon: Icon(Icons.arrow_back_ios, color: _currentPage == 0 ? Colors.grey : Colors.black),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 160,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: bannerData.length,
                        onPageChanged: (int index) {
                          setState(() => _currentPage = index);
                        },
                        itemBuilder: (context, index) {
                          final item = bannerData[index];
                          // 🌟 ตัวรูปภาพ Banner (กดได้)
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
                      if (_currentPage < bannerData.length - 1) {
                        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      }
                    },
                    icon: Icon(Icons.arrow_forward_ios, color: _currentPage == bannerData.length - 1 ? Colors.grey : Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Center(child: Text(currentItem.foundationName, style: const TextStyle(color: Colors.grey))),

              const SizedBox(height: 30),

              // --- 3. ส่วนรายการ: มูลนิธิใกล้ฉัน ---
              const Text('มูลนิธิใกล้ฉัน', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              _buildFoundationCard(
                title: 'มูลนิธิกระจกเงา',
                items: 'อาหาร/ของเล่น/หนังสือ/เสื้อผ้า',
                distance: '1.5 Km (10 นาที)',
                logoColor: Colors.yellow.shade600,
                icons: [Icons.fastfood, Icons.toys, Icons.menu_book, Icons.checkroom],
              ),
              const Divider(height: 30),
              _buildFoundationCard(
                title: 'มูลนิธิเพื่อคนพิการ',
                items: 'รถเข็น/อาหาร',
                distance: '3 Km (25 นาที)',
                logoColor: Colors.blue.shade800,
                icons: [Icons.accessible, Icons.fastfood],
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('ค้นหามูลนิธิเพิ่มเติม', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_circle_right_outlined, color: Colors.grey.shade800),
                ],
              ),

              const SizedBox(height: 40),

              // --- 4. ส่วนประวัติการบริจาค ---
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

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        height: 70,
        color: primaryBlue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home, 'หน้าหลัก', isActive: true),
            _buildNavItem(Icons.location_on, 'แผนที่'),

            Container(
              margin: const EdgeInsets.only(bottom: 8),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add, color: Colors.black, size: 36),
            ),

            _buildNavItem(Icons.history, 'ประวัติ'),
            _buildNavItem(Icons.person, 'ผู้ใช้'),
          ],
        ),
      ),
    );
  }

  Widget _buildFoundationCard({
    required String title,
    required String items,
    required String distance,
    required Color logoColor,
    required List<IconData> icons,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(color: logoColor, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.volunteer_activism, color: Colors.white, size: 40),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  const Icon(Icons.verified, color: Colors.blue, size: 18),
                ],
              ),
              const SizedBox(height: 4),
              Text(items, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              Text(distance, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: icons.map((icon) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(icon, color: primaryBlue, size: 20),
                )).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, {bool isActive = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? Colors.white : Colors.black87, size: 28),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}