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

## 🔴 ต้องทำต่อ — เรียงตามความคุ้ม

### 1. ตรวจด้วยตาว่าปุ่มอนุมัติหาย/โผล่ถูกต้อง ← ทำก่อน

ยืนยันแล้วเฉพาะชั้น API (ยิงจริงทุกมุมมอง + ยิง PUT เทียบว่า flag ตรงกับที่ enforce จริง)
กับ unit test ของการ parse — **ยังไม่เคยเห็นปุ่มหายบนจอจริงสักครั้ง**

| เครื่อง | บัญชี | ทำอะไร | ต้องได้ |
|---|---|---|---|
| iPhone | `attendance.info` | ข้อมูลบุคลากร → บุคลากรทั่วไป → ลากิจ 15 ก.ย. | ❌ ไม่มีปุ่ม |
| iPad | `attendance.approval` | ข้อมูลบุคลากร → **ตัวเอง** → ลาป่วย 27 ส.ค. | ❌ ไม่มีปุ่ม ← บั๊กที่เพิ่งแก้ |
| iPad | `attendance.approval` | ข้อมูลบุคลากร → บุคลากรทั่วไป → ลากิจ 15 ก.ย. | ✅ มีปุ่ม ← กัน regression |

หมายเหตุ: แอปบนเครื่องจำลองยังเป็นโค้ดก่อนแก้ frontend — ไม่เป็นไรสำหรับสามเคสนี้
เพราะหน้าข้อมูลบุคลากรใช้ `permission-level` จาก backend ล้วน (ไฟล์ frontend ไม่ได้แตะ)

- [ ] **บล็อกอยู่**: Terminal ไม่มีสิทธิ์ Accessibility → `System Events` เห็นหน้าต่าง
      Simulator เป็น 0 บาน สั่ง tap ไม่ได้เลย
      แก้: System Settings → Privacy & Security → Accessibility → เพิ่ม Terminal

### 2. เส้นทางหน้าอนุมัติที่ยังทดสอบแยกไม่ออก

`can-approve` ตัวใหม่มีผลจริงเฉพาะกับคนที่มี **role ผสม** (มีทั้ง `main` ที่คุมทีมอื่น
และ role อื่นที่คุมคนนี้) ซึ่งฐานทดสอบยังไม่มีเคสนั้น — บัญชีที่มีตอนนี้ให้ผลเหมือนกัน
ทั้งโค้ดเก่าและใหม่

- [ ] สร้างเคสทดสอบ role ผสม (ชั่วคราวแล้วลบ) หรือรอเจอในข้อมูลจริง

### 3. ของค้างจาก Phase 3

- [ ] `/statistic` — KPI 4 ตัวรวมเป็นแถวเดียว (ตอนนี้อยู่คนละ widget คนละ request)
- [ ] `/login` — ยังไม่เคยตรวจบนจอกว้างเลย
- [ ] บั๊ก #4 `/profile` ฟิลด์ว่างเกือบหมด — ต้องล็อกอินบัญชี**ปกติ** ถึงจะรู้ว่าเป็นบั๊ก
      หรือแค่บัญชีนั้นไม่มีข้อมูล

### 4. ของที่ทำแล้วแต่ยังไม่ยืนยันด้วยตา

- [ ] **Phase 4 `PopupSurface`** — ตารางใน `RESPONSIVE_PLAN.md` ยังเขียน
      "⏳ คอมไพล์ผ่าน ยังไม่ได้กดดูด้วยตา" ตั้งแต่ 24 ส.ค. แต่ระหว่างงานรอบนี้
      เห็น popup ทำงานบนเว็บหลายรอบแล้ว → น่าจะอัปเดตสถานะได้
- [ ] **drag & drop บน macOS / Windows / Linux** — เขียนไว้แต่ทดสอบแค่ web
- [ ] **`openExternally`** บน Android และ desktop
- [ ] **"แชร์ไฟล์" บน iPad** — แก้ `sharePositionOrigin` แล้ว (`4da7ab2`) แต่ยืนยันด้วยมือ
      ไม่ได้เพราะ tap injection ไม่ติด (ข้อเดียวกับข้อ 1)

---

## 🧹 ของค้างเล็กๆ

- [ ] `system-root` มี `check_out = 17:07:23` (24 ส.ค.) ที่ไม่รู้ที่มา — ยังไม่ได้แตะ
      รอเคาะว่าจะย้อนหรือปล่อย
- [ ] ไฟล์ `ลายเซ็นดิจิทัล_6630300670.pdf` ค้างใน Files app ของ iPhone simulator
      (เศษจากการทดสอบ)
- [ ] `user_management.dart` มี `mockGetUser()` เหลือค้าง (จด CLAUDE.md ไว้แล้ว)

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
