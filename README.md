<h1 align="center">💙 GiveLink Mobile Application</h1>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Firebase-%23FFCA28.svg?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase">
</p>

<p align="center">
  <b>แพลตฟอร์มสื่อกลางเชื่อมโยงการแบ่งปันสิ่งของ เพื่อลดขยะในสังคมและสร้างจิตสำนึกอย่างยั่งยืน</b>
</p>

---

## 📌 About The Project (เกี่ยวกับโครงงาน)
**GiveLink** เป็นแอปพลิเคชันบนสมาร์ทโฟนที่พัฒนาขึ้นเพื่ออำนวยความสะดวกในการบริจาคสิ่งของ โดยทำหน้าที่เป็นสื่อกลางระหว่าง "ผู้บริจาค" และ "มูลนิธิ" ผ่านการประยุกต์ใช้เทคโนโลยีระบุตำแหน่ง (Location-Based Service) เพื่อค้นหามูลนิธิใกล้เคียง และระบบจัดการฐานข้อมูลแบบเรียลไทม์ โครงงานนี้มุ่งหวังที่จะลดขั้นตอนความยุ่งยากในการบริจาค และส่งเสริมแนวคิดเศรษฐกิจหมุนเวียน (Circular Economy) โดยการนำสิ่งของเหลือใช้กลับมาสร้างประโยชน์สูงสุด

## ✨ Key Features (ฟีเจอร์เด่น)
- 📍 **Location-Based Sorting:** ระบบค้นหาและเรียงลำดับมูลนิธิที่อยู่ใกล้ที่สุดแบบอัตโนมัติ (GPS Integration)
- 📅 **Interactive Booking Flow:** ระบบจองวันและเวลาบริจาคผ่านปฏิทินที่ใช้งานง่าย
- 📸 **Image Upload & Compression:** รองรับการอัปโหลดรูปภาพสิ่งของสูงสุด 5 รูป (เชื่อมต่อผ่าน ImgBB API) 
- 🔄 **Real-Time Status Tracking:** ระบบติดตามสถานะการจองบริจาค (รอดำเนินการ, เสร็จสิ้น, ยกเลิก) 
- 🔔 **Smart Notifications:** ระบบแจ้งเตือนอัจฉริยะรองรับการปัดเพื่อลบ (Swipe-to-Dismiss)
- 🔒 **Secure Authentication:** ระบบจัดการบัญชีผู้ใช้และระบบยืนยันตัวตนซ้ำ (Re-Authentication) เพื่อความปลอดภัยสูงสุด

## 📱 Screenshots (ภาพหน้าจอแอปพลิเคชัน)
| หน้าหลัก (Home) | ค้นหามูลนิธิ (Near Me) | จองการบริจาค (Booking) | ประวัติ (History) |
|:---:|:---:|:---:|:---:|
| <img src="[ใส่ลิงก์รูปหน้าHome]" width="200"> | <img src="[ใส่ลิงก์รูปหน้ามูลนิธิ]" width="200"> | <img src="[ใส่ลิงก์รูปหน้าอัปโหลดรูป]" width="200"> | <img src="[ใส่ลิงก์รูปหน้าประวัติ]" width="200"> |

> **Note:** สามารถเพิ่มรูปภาพ Screenshot จริงของแอปโดยนำภาพไปฝากไว้ในโฟลเดอร์ `assets` หรือฝากลิงก์ไว้ใน GitHub แล้วนำ URL มาใส่แทน `[ใส่ลิงก์รูป...]`

## 🛠 Tech Stack (เทคโนโลยีที่ใช้พัฒนา)
* **Frontend:** Flutter Framework (Dart)
* **Backend / Database:** Firebase Authentication, Cloud Firestore
* **External APIs:** ImgBB API (สำหรับโฮสต์รูปภาพ)
* **Key Packages:** `geolocator`, `table_calendar`, `image_picker`, `share_plus`

## 🚀 Getting Started (วิธีการติดตั้งและรันโปรเจกต์)
คำแนะนำสำหรับการโคลนโปรเจกต์ไปรันบนเครื่อง Local ของคุณ

### Prerequisites (สิ่งที่ต้องมี)
* Flutter SDK (Version 3.x ขึ้นไป)
* Android Studio หรือ VS Code
* อุปกรณ์ Android/iOS หรือ Emulator/Simulator

### Installation (ขั้นตอนการติดตั้ง)
1. Clone repository นี้
   ```bash
   git clone [https://github.com/](https://github.com/)[ชื่อยูสเซอร์ของคุณ]/givelink.git