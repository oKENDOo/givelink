import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart'; 

class DonationImageScreen extends StatefulWidget {
  final String foundationName;
  final List<dynamic> selectedCategories;
  final String othersText;
  final DateTime? selectedDate; 

  const DonationImageScreen({
    super.key,
    required this.foundationName,
    required this.selectedCategories,
    required this.othersText,
    required this.selectedDate,
  });

  @override
  State<DonationImageScreen> createState() => _DonationImageScreenState();
}

class _DonationImageScreenState extends State<DonationImageScreen> {
  final Color primaryTeal = const Color(0xFF64B5C7);
  
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('อัปโหลดได้สูงสุด 5 รูปครับ')));
      return;
    }

    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          for (var xfile in pickedFiles) {
            if (_selectedImages.length < 5) {
              _selectedImages.add(File(xfile.path));
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // 🌟 ฟังก์ชันแสดงรูปภาพเต็มหน้าจอ (สำหรับภาพจากตัวเครื่อง)
  void _showFullScreenImage(BuildContext context, File imageFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.black.withOpacity(0.9), // พื้นหลังสีดำโปร่งแสง
          body: Stack(
            children: [
              Center(
                child: InteractiveViewer( // 🌟 ทำให้ใช้นิ้วซูมภาพได้
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.file(
                    imageFile,
                    fit: BoxFit.contain, // แสดงภาพเต็มจอโดยไม่ถูกตัด
                  ),
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 36),
                      onPressed: () => Navigator.of(context).pop(), // กดปิดรูป
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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

  String _formatThaiDate(DateTime? date) {
    if (date == null) return '';
    final List<String> thaiMonths = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];
    final int buddhistYear = date.year + 543;
    return '${date.day} ${thaiMonths[date.month - 1]} $buddhistYear';
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
        title: const Text('4 / 5', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25)),
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
                      child: Text(
                        'ถ่ายภาพสิ่งของที่จะนำ\nไปบริจาคเพื่อส่งให้กับมูลนิธิ',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Center(
                      child: Text('สิ่งของที่จะบริจาค', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryTeal)),
                    ),
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
                    
                    if (widget.othersText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Center(child: Text('อื่นๆ: ${widget.othersText}', style: const TextStyle(fontSize: 14, color: Colors.grey))),
                      ),

                    const SizedBox(height: 10),
                    Center(
                      child: Text('ให้กับ ${widget.foundationName}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryTeal)),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text('ในวันที่ ${_formatThaiDate(widget.selectedDate)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryTeal)),
                    ),

                    const SizedBox(height: 30),

                    const Text('เลือกรูปสิ่งของที่คุณจะบริจาค', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(thickness: 1, height: 20),
                    
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300, 
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          if (_selectedImages.isNotEmpty)
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 1,
                              ),
                              itemCount: _selectedImages.length < 5 ? _selectedImages.length + 1 : 5, 
                              itemBuilder: (context, index) {
                                if (index == _selectedImages.length && _selectedImages.length < 5) {
                                  return GestureDetector(
                                    onTap: _pickImages,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey, style: BorderStyle.solid),
                                      ),
                                      child: const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                                          SizedBox(height: 8),
                                          Text('เพิ่มรูปภาพ', style: TextStyle(color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                
                                return Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // 🌟 หุ้มรูปภาพด้วย GestureDetector เพื่อกดดูรูปเต็มหน้าจอ
                                    GestureDetector(
                                      onTap: () => _showFullScreenImage(context, _selectedImages[index]),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(_selectedImages[index], fit: BoxFit.cover),
                                      ),
                                    ),
                                    // ปุ่มลบรูปภาพ (แยกทำงานอิสระ ไม่ทับกับกดดูรูป)
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () => _removeImage(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            )
                          else
                            GestureDetector(
                              onTap: _pickImages,
                              child: Container(
                                width: double.infinity,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                                    SizedBox(height: 10),
                                    Text('แตะเพื่อเลือกรูปภาพ (สูงสุด 5 รูป)', style: TextStyle(color: Colors.grey, fontSize: 16)),
                                  ],
                                ),
                              ),
                            ),
                          
                          const SizedBox(height: 10),
                          Text('${_selectedImages.length} / 5 รูป', style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 65,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_selectedImages.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('กรุณาอัปโหลดรูปภาพสิ่งของอย่างน้อย 1 รูปครับ')));
                            return;
                          }
                          
                          context.push('/donation_summary', extra: {
                            'foundationName': widget.foundationName,
                            'selectedCategories': widget.selectedCategories,
                            'othersText': widget.othersText,
                            'selectedDate': widget.selectedDate,
                            'selectedImages': _selectedImages, 
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
                            Text('ขั้นตอนต่อไป', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                            SizedBox(width: 15),
                            Icon(Icons.arrow_circle_right_outlined, color: Colors.white, size: 30),
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
}