import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  final Color primaryTeal =  Color(0xFF64B5C7);

  // 🌟 ฟังก์ชันแปลงชื่อหมวดหมู่กลับเป็น Icon
  IconData _getIconForCategory(String title) {
    switch (title) {
      case 'เสื้อผ้า': return Icons.checkroom;
      case 'อาหารและน้ำ': return Icons.fastfood;
      case 'ของเล่นเด็ก': return Icons.smart_toy;
      case 'หนังสือ': return Icons.menu_book;
      case 'อุปกรณ์\nการเรียน': return Icons.school;
      case 'อุปกรณ์\nสุขภาพ': return Icons.medical_services;
      case 'ของใช้\nส่วนตัว': return Icons.person;
      case 'ของใช้\nในบ้าน': return Icons.home;
      default: return Icons.card_giftcard;
    }
  }

  // 🌟 Mockup Data ของมูลนิธิ
  final List<Map<String, dynamic>> _mockFoundations = [
    {
      'name': 'มูลนิธิกระจกเงา',
      'logoColor': Colors.yellowAccent.shade700,
      'logoIcon': Icons.people_alt,
      'acceptedItemsText': 'อาหารและน้ำ/ของเล่นเด็ก/หนังสือ/เสื้อผ้า',
      'distance': '1.5 Km (10 นาที)',
      'icons': [Icons.fastfood, Icons.smart_toy, Icons.menu_book, Icons.checkroom],
      'isVerified': true,
    },
    {
      'name': 'มูลนิธิศูนย์พิทักษ์สิทธิเด็ก',
      'logoColor': Colors.white,
      'logoIcon': Icons.family_restroom,
      'iconColor': const Color(0xFF0D3061),
      'acceptedItemsText': 'อาหาร/หนังสือ',
      'distance': '3 Km (25 นาที)',
      'icons': [Icons.fastfood, Icons.menu_book],
      'isVerified': false, // สมมติว่าไม่มีติ๊กถูก
    },
  ];

  @override
  Widget build(BuildContext context) {
    // คำนวณการแสดงผลไอคอน (แสดงสูงสุด 3 อัน)
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
                    // --- 1. หัวข้อและไอคอนสิ่งของที่เลือกมาจากหน้าที่แล้ว ---
                    const Center(
                      child: Text(
                        'คุณอยากบริจาคที่ไหน ?',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        'สิ่งของที่จะบริจาค',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryTeal),
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // แถวโชว์ไอคอนที่เลือกมา
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(displayCount, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(
                              _getIconForCategory(widget.selectedCategories[index]),
                              color: primaryTeal,
                              size: 40,
                            ),
                          );
                        }),
                        // ถ้าเลือกมาเกิน 3 อัน ให้แสดง +จำนวนที่เหลือ
                        if (overflowCount > 0)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8.0),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '+$overflowCount',
                              style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                      ],
                    ),
                    
                    // แสดงข้อความ "อื่นๆ" (ถ้ามี)
                    if (widget.othersText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Center(
                          child: Text(
                            'อื่นๆ: ${widget.othersText}',
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      ),

                    const SizedBox(height: 60),

                    // --- 2. ส่วนเลือกมูลนิธิ ---
                    const Text(
                      'เลือกมูลนิธิที่เปิดรับบริจาค',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(thickness: 1, height: 20),
                    
                    // ลิสต์รายการมูลนิธิ (ListView)
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _mockFoundations.length,
                      separatorBuilder: (context, index) => const Divider(height: 30),
                      itemBuilder: (context, index) {
                        final foundation = _mockFoundations[index];
                        
                        return InkWell(
                            onTap: () {
                            // 🌟 สร้างข้อมูลจำลอง (Mock Data) สำหรับหน้ารายละเอียด
                           // 🌟 สร้างข้อมูลจำลอง (Mock Data) สำหรับหน้ารายละเอียด
                              final mockDetailData = {
                                'name': foundation['name'],
                                'address': 'เลขที่ 191 ซอยวิภาวดี 62 (แยก 4-7) ถนนวิภาวดีรังสิต แขวงตลาดบางเขน เขตหลักสี่ กรุงเทพมหานคร 10210',
                                'rating': '4.7',
                                'hours': 'เปิด 08.00-18.00',
                                'distance': foundation['distance'],
                                'isVerified': foundation['isVerified'],
                                'phone': '0987654321',
                                'facebook': 'มูลนิธิกระจกเงา',
                                'website': 'www.mirror.or.th',
                                'coverImage': 'https://picsum.photos/600/300', 
                                'mapImage': 'https://picsum.photos/600/150',
                                'neededItems': [
                                  {'title': 'อาหารและน้ำ', 'icon': Icons.fastfood},
                                  {'title': 'เสื้อผ้า', 'icon': Icons.checkroom},
                                  {'title': 'ของเล่นเด็ก', 'icon': Icons.smart_toy},
                                  {'title': 'หนังสือ', 'icon': Icons.menu_book},
                                ],
                                // 🌟 เติม 2 บรรทัดนี้เข้าไป เพื่อส่งข้อมูลที่เราเลือกไปยังหน้าต่อไป!
                                'selectedCategories': widget.selectedCategories,
                                'othersText': widget.othersText,
                              };
                            // 🌟 ส่งข้อมูลแล้วไปหน้า Detail
                            context.push('/donation_foundation_detail', extra: mockDetailData);
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // โลโก้มูลนิธิ (ใช้ Container + Icon เป็น Mockup ก่อน)
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: foundation['logoColor'],
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Icon(
                                    foundation['logoIcon'], 
                                    size: 50, 
                                    color: foundation['iconColor'] ?? Colors.black87
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // รายละเอียดมูลนิธิ
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            foundation['name'], 
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (foundation['isVerified']) ...[
                                          const SizedBox(width: 4),
                                          const Icon(Icons.check_circle, color: Colors.blue, size: 18),
                                        ]
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      foundation['acceptedItemsText'], 
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                    Text(
                                      foundation['distance'], 
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // ไอคอนของที่รับบริจาค
                                    Row(
                                      children: (foundation['icons'] as List<IconData>).map((icon) {
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: Icon(icon, color: primaryTeal, size: 22),
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