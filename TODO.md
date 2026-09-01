# TODO — สถานะงาน (อัปเดต 30 ส.ค. 2569)

> ไฟล์นี้เป็นรายการงาน ส่วนเหตุผล/บันทึกการสำรวจอยู่ใน `RESPONSIVE_PLAN.md`

## ⚠️ ค้างอยู่ตอนนี้ — ยังไม่ push ทั้งสอง repo

| repo | commit | เรื่อง |
|---|---|---|
| frontend | `f2322da` | ใช้ `can-approve` รายคำขอแทนการเดาจาก role type |
| frontend | `6fb1bb7` | จดเส้นทางจริงของ role `info` + รู self-approve |
| backend | `6577a42` | ตอบ `can-approve` + ตรวจ `status` ก่อนเขียนลงฐาน |
| backend | `229601a` | กัน self-approve ใน `CheckApprovalPermission` |

```
cd Attendance-System-Frontend && git push origin main
cd ../Attendance-System-Backend && git push origin main
```

---

## ✅ เสร็จแล้ว (รอบนี้)

### Phase 6 — layout จอใหญ่ของ user/role management

- [x] **ข้อ 1** ฟอร์มย่อย 7 หน้าใส่ `maxWidth: ContentShape.form` (600) — เดิมตกไปใช้ค่า default 1100 · `1e458f1`
- [x] **ข้อ 2** ถอด `AppScaffold` ซ้อนกันใน `set_max_leave` / `max_leave` · `1e458f1`
- [x] **ข้อ 3** แยกโครงสองคอลัมน์เป็น `MasterDetailScaffold` · `48efe15`
- [x] **ข้อ 4** ต่อ `user-management` + `role-management` เข้ากับ widget นั้น · `48efe15`
- [x] ตรวจ 1600 / 1050 / 520px ครบสามหน้า

### ป้ายตำแหน่ง (role chips) · `9259d05`

- [x] แก้ล้นกรอบ — `Wrap` ไม่ตัดของที่กว้างเกิน มันปล่อยทะลุ
- [x] จำกัด 2 บรรทัด ที่เหลือขึ้น `...`
- [x] รวม `UserInfoButton` + `TextRoleButton` เป็น `RoleChips` ตัวเดียว
- [x] ถอด `IntrinsicHeight` ที่ตีกับ `LayoutBuilder` จนลิสต์พังทั้งแถบ
- [x] `test/role_chips_test.dart` 5 เคส

### ยุบหน้าย่อยของ `user_info` · `928389c`

- [x] จำนวนวันลาสูงสุด → ยุบเข้าหน้าเป็น `MaxLeaveSection` (เซฟทันทีทีละแถว เหมือนช่องอื่น)
- [x] ตำแหน่ง → เปลี่ยน push เป็น popup (คงไว้แยกเพราะเป็น batch-save)
- [x] แก้บั๊ก `AssignRole` คืนค่าตอนกดย้อนกลับทั้งที่ยังไม่บันทึก
- [x] `max_leave.dart` เขียนใหม่แบบ table-driven 206 → 111 บรรทัด

### ช่องโหว่สิทธิ์อนุมัติ · `6577a42` `229601a` `f2322da`

- [x] backend ตอบ `can-approve` รายคำขอ (ใบลา + แก้ไขเวลา)
- [x] frontend ใช้ค่านั้นแทน `roleType.any((r) => r == 'admin' || r == 'main')`
- [x] `test/can_approve_test.dart` 7 เคส (default **false** เมื่อ field หาย)
- [x] **บั๊กที่เจอระหว่างทาง**: `status` ไม่เคยถูกตรวจ — ยิงค่าอะไรไปก็เขียนลงฐาน
      คำขอค้างถาวร (ไม่ใช่ pending จึงหลุดจากหน้าอนุมัติ แต่ก็ไม่ใช่ approved/rejected)
      ปิดแล้ว รับแค่ `approved`/`rejected`
- [x] **บั๊กที่เจอจากที่ผู้ใช้ท้วง**: `CheckApprovalPermission` ไม่ได้กัน self-approve
      ต่างจาก `canApprove` → admin เห็นปุ่มบนคำขอตัวเอง กดได้ 403

---

## ✅ ผลการทดสอบ (30 ส.ค. 2569)

ทดสอบบนเครื่องจำลองจริง iPhone 17 Pro (`info`) + iPad Pro 13" (`approval`) และ Chrome

### สิทธิ์อนุมัติ — ผ่านครบ 3 เคส

| เคส | เครื่อง / บัญชี | ผลที่ได้ |
|---|---|---|
| ดูคำขอลูกน้อง แต่ไม่ใช่หัวหน้าตัวจริง | iPhone · `info` | เห็นรายละเอียดครบ **ไม่มีปุ่มอนุมัติ/ปฏิเสธ** ✅ |
| ดูคำขอ **ของตัวเอง** | iPad · `approval` | **ไม่มีทั้งปุ่มและช่องเหตุผล** ✅ ← บั๊กที่เพิ่งแก้ (`229601a`) |
| ดูคำขอลูกน้องในฐานะหัวหน้าตัวจริง | iPad · `approval` | **มีปุ่ม "ไม่อนุมัติ" / "อนุมัติ" ครบ** ✅ ← กัน regression |

เคสที่ 2 ทำได้ด้วยการเพิ่มแถวใน `subordinate_manager_roles` ให้ `approval` เป็น
ลูกน้องของตัวเองชั่วคราว (ลบออกแล้ว) — ตรงกว่าการใช้ admin เพราะเดินโค้ดเส้นเดียวกัน

### อื่นๆ ที่ปิดได้

| รายการ | ผล |
|---|---|
| **แชร์ไฟล์บน iPad** | ✅ share sheet โผล่เป็น popover ติดปุ่ม — `sharePositionOrigin` ทำงาน (เดิมกดแล้วเงียบ) |
| **`/login` จอกว้าง (1700px)** | ✅ การ์ดอยู่กลาง กว้างพอดี ไม่ยืด ไม่ล้น |
| **บั๊ก #4 `/profile` ฟิลด์ว่าง** | ✅ **ไม่ใช่บั๊ก** — `system-root` ไม่มีข้อมูลในฐานตั้งแต่ต้น บัญชีปกติแสดงครบทุกฟิลด์ · 🚩 ข้อนี้มีคำตอบอยู่แล้วใน `RESPONSIVE_PLAN.md` ข้อ C ตั้งแต่ 25 ส.ค. — ผมพิสูจน์ซ้ำโดยไม่จำเป็น |
| **Phase 4 `PopupSurface`** | ✅ ยืนยันด้วยตาแล้ว — popup บน iPad เป็นกล่องกลางจอ ไม่ใช่แผ่นเลื่อนเต็มความกว้าง |

### ⚠️ ทดสอบไม่ได้ / ยังไม่ชัด

- [x] ~~**`openExternally` บน iOS**~~ — ✅ **ผู้ใช้ยืนยันแล้ว (31 ส.ค.): ใช้ได้ปกติ**
      ผมกดเองแล้วเห็นตัวอ่านไฟล์เต็มจอเปิดขึ้นและไม่มี error แต่แยกไม่ออกว่าเป็น
      Quick Look ของ iOS หรือ preview ของแอปเอง — ผู้ใช้ดูแล้วยืนยันว่าถูกต้อง
- [x] ~~**drag & drop บน macOS/Windows/Linux**~~ — **ไม่ต้องทดสอบ** โปรเจกต์รองรับแค่
      `android` / `ios` / `web` ไม่มี desktop target เลย `desktop_drop` จึงมีผลเฉพาะบนเว็บ
      (ซึ่งทดสอบไปแล้ว)
- [x] ~~**`openExternally` บน Android**~~ — ✅ **ผ่านแล้ว (31 ส.ค.)** ทดสอบบน emulator
      Pixel/Android 16 (API 36) ล็อกอินจริงเป็น `system-root` → คำขอ `REQ000000000013`
      → พรีวิวไฟล์แนบ → เมนู `…` → "เปิดด้วยแอปอื่น"
      **หลักฐาน**: `topResumedActivity = com.google.android.apps.photos/.pager.HostPhotoPagerActivity`
      คือระบบส่งต่อให้แอปนอกจริง (`ACTION_VIEW` ผ่าน `OpenFilex`) ไม่ใช่ viewer ในแอป
      ยืนยันด้วยภาพหน้าจอ: chrome ของ Google Photos (cast / Share / Lens) ทับเต็มจอ
      · ยังไม่ได้ลองเคส **PDF** บน Android — emulator เปล่าไม่มีแอปอ่าน PDF จะได้
        `ResultType != done` ซึ่งเป็น error path ที่ถูกต้องอยู่แล้ว ไม่ใช่บั๊ก

---

## 🔴 งานที่เหลือ — ไม่ใช่การทดสอบแล้ว

- [x] ~~**`/statistic` KPI 4 ตัวรวมเป็นแถวเดียว**~~ — **ยกเลิกไปแล้ว ไม่ต้องทำ**
      เคยทำจริง (`0eea7b6`) แล้ว**ถูกแทนที่**ตอนรื้อหน้า `/statistic` ใหม่ทั้งหน้า
      (`RESPONSIVE_PLAN.md` ข้อ B บรรทัด 694 + หัวข้อ "รูปแบบสุดท้ายของ /statistic")
      🚩 บรรทัด 339 ในไฟล์นั้นเป็นรายการค้างจากตอนสำรวจ Phase 3 ที่ไม่มีใครขีดฆ่า
      หลังเปลี่ยนแผน — ผมยกมาใส่ TODO โดยไม่ได้เช็คว่าถูก supersede ไปแล้ว
- [x] ~~**mock function ที่ตายแล้ว**~~ — **ลบแล้ว `28e05a6`** เจอ 18 ตัวใน 12 ไฟล์
      (CLAUDE.md จดไว้ตัวเดียว) รวมกับ import ที่ค้างตามมา = 1,012 บรรทัด
- [x] ~~**เคส role ผสม**~~ — **พิสูจน์ครบแล้ว 30 ส.ค.** (ดูหัวข้อด้านล่าง)

---

### เคส role ผสม — พิสูจน์แล้วว่าโค้ดเก่าพังจริง โค้ดใหม่แก้ได้จริง

สร้างเคสชั่วคราว: ให้บัญชี `info` (คุม "บุคลากรทั่วไป" ผ่าน role `special`) ได้ role
`main` เพิ่มอีกอันที่คุม "ฝ่ายบุคคล" → มี `main` อยู่ในตัวแต่ **ไม่ใช่หัวหน้าตัวจริง
ของบุคลากรทั่วไป**

| | โค้ดเก่า (build ก่อน `f2322da`) | โค้ดใหม่ |
|---|---|---|
| ตรรกะ | `roleType.any((r) => r == 'admin' \|\| r == 'main')` → **true** | `can-approve` ของคำขอใบนั้น → **false** |
| ปุ่มบนคำขอของบุคลากรทั่วไป | **โผล่** | **ไม่โผล่** ✅ |
| กดแล้วเกิดอะไร | เซ็นลายเซ็น → ส่ง → **"เกิดข้อผิดพลาด กรุณาลองอีกครั้ง..."** (คือ 403) ลองกี่ครั้งก็ไม่ผ่าน | — |

ทดสอบบนเครื่องเดียวกัน คำขอเดียวกัน (`REQ000000000016`) ต่างกันแค่ build
คำขอยัง `pending` หลังกด (403 ไม่ได้เขียนอะไรลงฐาน) ลบ role ชั่วคราวออกแล้ว

**หมายเหตุ**: ระหว่างทดสอบ หน้า "อนุมัติคำขอ" โผล่ในเมนูของ `info` — **เพราะ role
`main` ที่ผมเพิ่มเข้าไปเอง ไม่ใช่พฤติกรรมจริง** `info` ล้วนๆ ไม่เห็นเมนูนี้
(`menu_access.dart` `canApprove => _any(['admin','main'])`) ยืนยันด้วยตาแล้วทั้ง
ก่อนเพิ่มและหลังลบ role

---

## 🩹 ที่ต้องซ่อมเพราะผมทำพัง

- [x] ~~**Chrome ต้องล็อกอินใหม่**~~ — ✅ ผู้ใช้ล็อกอินกลับเป็น `admin` แล้ว (31 ส.ค.)

      **บทเรียน**: `flutter_secure_storage` บนเว็บ **เข้ารหัสค่าด้วย `crypto.subtle`**
      (คีย์เก็บใน `localStorage` key `FlutterSecureStorage`) — ค่าที่เห็นใน
      `localStorage.FlutterSecureStorage.access_token` **ไม่ใช่ JWT ดิบ** เขียนทับด้วย
      JWT ตรงๆ ไม่ได้ แอปจะถอดรหัสไม่ผ่านแล้วเด้งไปหน้า login
      → ถ้าจะสลับบัญชีบนเว็บ ต้องล็อกอินผ่าน Google จริงเท่านั้น

## 🧹 ของค้างเล็กๆ

- [x] ~~`system-root` มี `check_out = 17:07:23` (24 ส.ค.) ที่ไม่รู้ที่มา~~
      **ผู้ใช้เคาะแล้ว (31 ส.ค.): ปล่อยไว้** ไม่ต้องย้อน
- [x] ~~ไฟล์ `ลายเซ็นดิจิทัล_6630300670.pdf` ค้างใน Files app ของ iPhone simulator~~
      **ผู้ใช้เคาะแล้ว (31 ส.ค.): ไม่ต้องลบ**
- [x] ~~CLAUDE.md ข้อ 7 ล้าสมัย (ยังเขียนว่ามี `mockGetUser()` เหลือค้าง)~~ — แก้แล้ว `e354086`

---

## 📌 หมายเหตุเชิงโครงสร้างที่ควรจำ

**มีสองที่ที่ตอบคำถาม "อนุมัติได้ไหม"** แยกกันอยู่:

| | ไฟล์ | หน้าที่ |
|---|---|---|
| `canApprove` | `leave_approval_repo.go` · `attendance_approval_repo.go` | บังคับใช้จริงตอนกด |
| `CheckApprovalPermission` | `personnel_repo.go` | บอกแอปว่าจะโชว์ปุ่มไหม |

แก้นโยบายทีต้องแก้ทั้งคู่ ไม่งั้นเพี้ยนกันเงียบๆ — ซึ่งเป็นสาเหตุของบั๊ก self-approve
พอดี ใส่คอมเมนต์โยงหากันไว้แล้ว

---

## 🛠️ dev environment ที่เปลี่ยนไปรอบนี้

- `flutter run -d chrome` → **`flutter run -d web-server --web-port=5050`**
  (ตัวเดิมเปิด Chrome ด้วย `--disable-extensions` + temp profile ทำให้เข้าไปตรวจไม่ได้)
- มี FIFO ให้สั่ง hot restart: `printf 'R\n' > <scratchpad>/flutter_cmd` (~0.5 วิ)
- ⚠️ ห้ามใช้พอร์ต 5000 — macOS จอง (AirPlay Receiver)

---

## ⚠️ บทเรียนตอนทำ TODO นี้

`RESPONSIVE_PLAN.md` มีรายการ "ยังไม่ได้ทำ" ที่บรรทัด 337–345 ซึ่ง**ค้างจากตอนสำรวจ
Phase 3** และถูกตอบไปแล้วในตารางข้อสังเกต 8 ข้อ (บรรทัด 691–701) โดยไม่มีใครกลับไป
ขีดฆ่ารายการเดิม — ผมอ่านเจอรายการเดิมแล้วยกมาใส่ TODO ทั้งสองข้อ (KPI + บั๊ก #4)
ทั้งที่ข้อหนึ่งยกเลิกไปแล้วและอีกข้อมีคำตอบแล้ว

**ก่อนหยิบงานจากไฟล์แผน ให้เช็คตารางสถานะท้ายไฟล์ก่อนเสมอ** ว่ารายการนั้นถูก
supersede ไปหรือยัง

---

## 🐞 บั๊ก Android build ที่เจอตอนตั้ง environment (31 ส.ค.) — แก้แล้ว ยังไม่ commit

ไม่เกี่ยวกับ `openExternally` แต่เจอระหว่างทาง ทั้งสองข้อทำให้ **build Android ไม่ผ่านบน
เครื่องที่ไม่ใช่ของคนที่ commit มา**

| ไฟล์ | ปัญหา | แก้ |
|---|---|---|
| `android/gradle.properties` | `org.gradle.java.home=C:\Program Files\Android\Android Studio\jbr` ฝังมาตั้งแต่ commit แรก (23 ม.ค.) — ค่าเฉพาะเครื่องที่ไม่ควรอยู่ใน repo | ลบบรรทัดนั้น ให้ Gradle ใช้ JDK ที่ `flutter config --jdk-dir` ชี้ |
| `android/app/build.gradle.kts:42` | `signingConfigs` แคสต์ `keystoreProperties["storeFile"] as String` โดยไม่เช็คว่ามี `key.properties` มั้ย ทั้งที่ตอนโหลดด้านบนเช็คอยู่ · บล็อกนี้ประเมินตอน configure จึงพัง **ทั้ง debug และ release** | ห่อด้วย `if (keystorePropertiesFile.exists())` + ให้ release fallback ไป debug key |

**ยังไม่ได้แก้ (แค่เลี่ยงตอนทดสอบ)**: `lib/core/network/api_config.dart` — dev mode ตั้ง
`baseUrl = 'http://localhost:3000'` สำหรับ mobile ทั้งหมด แต่ Android emulator ต้องใช้
`10.0.2.2` (ในโค้ดมีคอมเมนต์เขียนไว้เองว่า "Android Emulator: use http://10.0.2.2:3000
instead" แต่ไม่ได้ทำตาม และคอมเมนต์ด้านบนบอกว่า "emulator ไม่ต้องใส่" ซึ่งจริงเฉพาะ iOS)
ตอนทดสอบใช้ `--dart-define=API_BASE_URL=http://10.0.2.2:3000` แทน

## 🛠️ environment Android ที่ตั้งไว้แล้ว (31 ส.ค.)

- SDK: `/opt/homebrew/share/android-commandlinetools` (~10 GB รวม NDK 2 ตัว)
- JDK: `brew install openjdk@21` (**formula ไม่ใช่ cask** — cask ต้อง sudo, formula ไม่ต้อง)
- AVD `ku_test` · Android 16 API 36 · google_apis arm64-v8a
- ⚠️ บูตต้องใส่ `-gpu host` ไม่งั้น RAM ว่าง < 5.12 GB แล้วตกไปใช้ software rendering (ช้ามาก)
- ⚠️ แก้ `config.ini` แล้วต้องบูตด้วย `-no-snapshot-load` ไม่งั้น snapshot เก่าทับ config ใหม่
- ⚠️ คีย์บอร์ด Mac พิมพ์เข้า emulator ไม่ได้ถ้าเปิด emulator จาก shell เบื้องหลัง —
  ต้องเปิดจาก Terminal.app เอง
- NDK ที่ใช้จริงคือ **27.0.12077973** (ตัว 28.2.13676358 ลงเกินมา ลบได้ ~2.8 GB)
