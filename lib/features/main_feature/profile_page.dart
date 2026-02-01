import 'package:attendance_system/services/profile_service/profile_model.dart';
import 'package:attendance_system/services/profile_service/profile_service.dart';
import 'package:attendance_system/shared/widgets/app_scaffold.dart';
import 'package:attendance_system/shared/widgets/head_bar/header.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

/// หน้าจอโปรไฟล์ผู้ใช้งาน (Stateless เพราะตอนนี้ใช้ mock data ยังไม่มี state เปลี่ยนแปลง)
class _ProfilePageState extends State<ProfilePage> {
  late Future<ProfileModel> _futureProfile;

  @override
  void initState() {
    super.initState();
    _futureProfile = GetIt.I<ProfileService>().getProfile();
  }

  @override
  Widget build(BuildContext context) {
    // // Mock data (เดี๋ยวค่อยเปลี่ยนเป็นข้อมูลจาก API)
    // const profile = MockProfile(
    //   thName: 'ด้วยดี ตามไท',
    //   enName: 'Duaydee Tamtai',
    //   email: 'duaydee.t@eng.src.ku.ac.th',
    //   avatarAsset: 'assets/images/Avatar_profile.png',
    // );

    return AppScaffold(
      header: Header.mainHeader(context,
        title: 'ข้อมูลผู้ใช้งาน',
        subTitle: 'User Profile',
        iconPath: 'icon_profile.svg',
      ),
        content: FutureBuilder<ProfileModel>(
            future: _futureProfile,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text('โหลดข้อมูลไม่สำเร็จ'));
              }

              final profile = snapshot.data!;

              return Padding(
                  padding: const EdgeInsets.only(top: 65),
                  // กัน content โดน header ทับ
                  child: SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _ProfileHeaderCard(
                            thName: profile.thName,
                            enName: profile.enName,
                            email: profile.email,
                            // avatarAsset: profile.,
                          ),
                          const SizedBox(height: 12),

                          _ProfileInfoCard(
                              rows: [
                                ProfileFieldRow(label: 'รหัสบุคลากร', value: profile.staffId),
                                ProfileFieldRow(label: 'เลขประจำตัวประชาชน', value: profile.citizenId),
                                ProfileFieldRow(label: 'ชื่อ-นามสกุล', value: profile.thName),
                                ProfileFieldRow(label: 'Full-name', value: profile.enName),
                                ProfileFieldRow(label: 'เพศ', value: profile.gender),
                                ProfileFieldRow(label: 'สัญชาติ', value: profile.nationality),
                                ProfileFieldRow(label: 'เบอร์โทร', value: profile.phone),
                                ProfileFieldRow(label: 'อีเมล', value: profile.email),
                            ]
                          ),

                          const SizedBox(height: 12),
                          _CurrentPositionCard(),
                        ],
                      ),
                    ),
                  )
              );
            }
        ),
    );
  }
}


/// การ์ดส่วนหัวของโปรไฟล์: Avatar + ชื่อไทย/อังกฤษ
class _ProfileHeaderCard extends StatelessWidget {
  final String thName; // ชื่อภาษาไทย
  final String enName; // ชื่อภาษาอังกฤษ
  final String email; // อีเมล
  // final String avatarAsset; // รูปโปรไฟล์

  const _ProfileHeaderCard({
    required this.thName,
    required this.enName,
    required this.email,
    // required this.avatarAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0, // ไม่ให้เงา (เรียบ ๆ)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // มุมโค้ง
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // รูปโปรไฟล์
            CircleAvatar(
              radius: 20,
              // backgroundImage: AssetImage(avatarAsset),
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(width: 12),

            // ข้อความชื่อ 2 บรรทัด
            Expanded(
              // Expanded ทำให้ column กินพื้นที่ที่เหลือใน Row
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    enName,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// การ์ดรายละเอียดข้อมูลผู้ใช้ (กลุ่มแถวหลาย ๆ แถว)
class _ProfileInfoCard extends StatelessWidget {
  final List<ProfileFieldRow> rows; // รายการแถว label-value ที่จะแสดง
  const _ProfileInfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // วนลูปสร้างแต่ละแถว พร้อมเส้นคั่น (Divider) ระหว่างแถว
          for (int i = 0; i < rows.length; i++) ...[
            // Padding ต่อแถว เพื่อให้มีระยะหายใจ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: rows[i],
            ),

            // ใส่ Divider ยกเว้นแถวสุดท้าย
            if (i != rows.length - 1)
              Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
          ]
        ],
      ),
    );
  }
}

/// แถวข้อมูลแบบ "label - value"
class ProfileFieldRow extends StatelessWidget {
  final String label; // ชื่อฟิลด์ เช่น "อีเมล"
  final String value; // ค่าที่แสดง เช่น "xxx@xxx.com"

  const ProfileFieldRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // label ฝั่งซ้าย: ใช้ Expanded ให้กินพื้นที่ได้
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13),
          ),
        ),
        const SizedBox(width: 12),

        // value ฝั่งขวา: ใช้ Flexible กันล้น + ellipsis
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            overflow: TextOverflow.ellipsis, // ถ้ายาวเกินตัดด้วย ...
          ),
        ),
      ],
    );
  }
}

/// การ์ดตำแหน่ง/บทบาทปัจจุบัน (ตอนนี้ทำเป็นตัวอย่างด้วย chip tag)
class _CurrentPositionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // ไอคอนตำแหน่ง
            const Icon(Icons.place_outlined, size: 18),
            const SizedBox(width: 8),

            // ข้อความหัวข้อ
            const Text('ตำแหน่งปัจจุบัน:', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 8),

            // แท็กสถานะ/บทบาท (ตัวอย่าง)
            _ChipTag(text: 'รองคณบดีฝ่ายวิชาการ'),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}

/// Widget แท็กเล็ก ๆ แบบ pill/chip ที่กำหนดสีและขอบโค้งเอง
class _ChipTag extends StatelessWidget {
  final String text;
  const _ChipTag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding ภายในแท็ก
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color.fromARGB(20, 255, 165, 29), // สีพื้นหลัง
        borderRadius: BorderRadius.circular(999), // ทำให้เป็นทรง pill
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, color: Color.fromARGB(255, 255, 165, 29)),
      ),
    );
  }
}
