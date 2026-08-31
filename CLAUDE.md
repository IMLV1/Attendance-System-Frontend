# Attendance-System-Frontend

Flutter app (mobile + web) สำหรับระบบเช็คชื่อ/ลางาน (KU). คุยกับ backend ที่ `../Attendance-System-Backend` (Go/Gin). ดู CLAUDE.md ของ backend คู่กันสำหรับ API/DB context.

## Stack
- `go_router` (routing) + `get_it` (DI) + `provider` (global state) + `dio` (HTTP)
- Google Sign-In → backend `/auth/google` → JWT เก็บใน `flutter_secure_storage`
- ไม่มี dark theme, font หลัก Inter, รองรับ responsive mobile/tablet/desktop

## Bootstrap flow
`main.dart`: `dotenv.load('.env')` → `setupServiceLocator()` (get_it, `lib/service_locator.dart`) → `getIt<AuthState>().init()` (เช็ค token+ดึงโปรไฟล์/config แบบ blocking) → `MultiProvider` (`AuthState`, `NotificationProvider`, `NavigationGuard`) → `MaterialApp` ห่อ `App()` (go_router อยู่ชั้นในนั้น)

**Routing**: `lib/app/routes.dart` + `route_names.dart`. `redirect` gate ตาม `AuthState.status`. ส่วนใหญ่อยู่ใต้ `ShellRoute` → `BaseView` (เพิ่ม sidebar/bottom-nav ตาม `Responsive` breakpoint: mobile <600, tablet 600–1200, desktop ≥1200)

## Auth flow
`GoogleLoginServiceImpl` → Google access token → `AuthApiService.loginWithGoogle` (`POST /auth/google` body `{"token": accessToken}`) → เก็บ JWT ผ่าน `TokenStorage` (secure storage) → แนบ header **สองทาง** (ซ้ำซ้อน): `AuthInterceptor` (อ่านจาก storage ทุก request) + `ApiClient.setToken()` (set header ตรง) — ถ้าจะแก้ auth ต้องแก้ทั้งคู่ให้ sync กัน
- `AuthState` (`lib/core/auth/auth_state.dart`) cache `user`/`profile`/`leaveConfig`/`timeConfig`/`attendanceConfig`, ดึงด้วยการสร้าง service instance ตรงๆ (ไม่ผ่าน get_it แม้จะลงทะเบียนไว้แล้ว) ซ้ำ logic เดียวกันทั้งใน `init()` และ `loginWithGoogle()`
- 401 จาก interceptor → auto-logout (ยกเว้น request ไป `/auth/google`/`/auth/logout` เอง)

## Networking / Service pattern
`ApiConfig` **hardcode base URL ตาม platform/build mode** (ไม่ได้อ่านจาก `.env` ทั้งที่โหลด dotenv ไว้แล้ว — เปลี่ยน backend env ต้องแก้ source). `.env` มีแค่ `GOOGLE_CLIENT_ID_WEB` ที่ถูกใช้จริง (ANDROID/IOS ประกาศไว้เฉยๆ ไม่มีที่เรียก)

Service ทั่วไป (`*_service.dart`): `final Dio dio = GetIt.I<ApiClient>().dio;` + 1 method ต่อ endpoint คืน `Future<Response>` ดิบ ไม่ parse/catch เอง — ปล่อยให้ widget wrapper (ดูล่าง) ดัก error/parse. Model (`*_model.dart`): `factory fromJson` + null-coalescing default, บาง enum (เช่น `ApproveStatus`) ฝัง UI concern (icon/color) ไว้ในตัวเอง

**ข้อยกเว้น**: `AttendanceService` (check-in) ห่อ try/catch เองและ debugPrint แทนที่จะปล่อย error — ไม่ตรงกับ pattern ส่วนใหญ่ ถ้าเขียน service ใหม่ให้ยึด pattern ส่วนใหญ่ (ปล่อย error ให้ wrapper จัดการ)

## State management (ผสม ไม่มี pattern เดียว)
- Global: `ChangeNotifier`+`provider` (`AuthState`, `NotificationProvider`, `NavigationGuard`)
- หน้าจอทั่วไป: `StatefulWidget`+`setState` เป็นหลัก
- Async fetch/mutate: widget wrapper กลาง 3 ตัว (`lib/shared/widgets/utils/services/`) — เช็คทั้ง 3 ก่อนเขียนใหม่:
  - `ServiceLoader` — auto-fetch ตอน init, มี loading/error/retry UI ในตัว
  - `ServiceUpdater` — ทั่วไปกว่า, caller คุม UI เอง, ใช้เยอะกับปุ่ม save/submit (`fetchOnInit` default false)
  - `ServiceUpdaterProMax` — จัดการ list ของ concurrent request หลายตัว (copy-paste จาก `ServiceUpdater` ไม่ได้ share code กัน)

## Popup system (`lib/shared/widgets/utils/popup/`) — เลือกให้ตรงงาน
- `FloatingPopup` — dialog กลางจอ, confirm/cancel
- `PushPopup` — bottom sheet เนื้อหา static/read-only
- `ServicePopup` (+ sub-variant number/option/text/signature) — bottom sheet ที่ปุ่ม submit ยิง API เอง (ผ่าน `ServiceUpdater`)
- `DynamicPushPopup`/`multi_page/` — wizard หลายหน้าใน sheet เดียว (nested Navigator + `PopupProvider`), ดู `example_usage.dart` ก่อนสร้างใหม่

## โครงสร้าง feature ↔ service
`lib/features/` (หน้าจอ) ไม่ได้ map 1:1 กับ `lib/services/` ตามโฟลเดอร์ แต่ตาม domain concept, บางโดเมนแยก 2 ฝั่ง requester/approver คนละ service+model:
- ขอลา: `services/leave/` ↔ `features/main_feature/leave_request/`
- อนุมัติลา: `services/approval/leave/` (import ใช้ `ApproveStatus`/`NetworkFile` จากฝั่ง requester) ↔ `features/settings/approval/leave/`
- เช่นเดียวกันสำหรับ attendance-correction ("time request"): `services/time_request/` vs `services/approval/attendance/`
- `personnel_info` แตกเป็น 6 service ย่อยตาม tab (data/attendance/attendance_request/leave/statistic/chooser)
- `system_config/*` (attendance_request, attendance_time, budget_year, leave) แต่ละตัวจับคู่กับ `settings/admin_config/setting_*.dart` ตรงๆ

## รู้ไว้ก่อนแก้ (gotcha ที่พบ ณ 2026-08-12)
1. **`SideBarNavigation` (เมนู desktop) ยังทำไม่เสร็จ**: `permissionLevel` hardcode = 3 ไม่ได้ดึงจาก role จริง, ลิงก์ไปหลาย path ที่ไม่มีจริงใน `routes.dart`, ไอคอนพังเพราะ asset path ว่าง — ต่างจาก `BottomNavigation` ที่ต่อครบแล้ว
2. มีไฟล์ชื่อ `leave_model.dart` ซ้ำกัน 2 ที่ (`services/leave/` กับ `services/approval/leave/`) คนละเนื้อหา — ระวังตอน grep/quick-open
3. `RouteNames.timeRequestCreate`/`attendanceRequestCreate` ชื่อสลับความหมายกับสิ่งที่ใช้จริง (ใช้งานถูกแต่ทำให้งงตอนอ่าน)
4. ไฟล์ `check-in_model.dart`/`check-in_service.dart`/`check_in-leave-*.dart` มี hyphen ในชื่อไฟล์ (ผิดธรรมเนียม Dart แต่ compile ผ่าน)
5. get_it ใช้ไม่สม่ำเสมอ: บาง service ลงทะเบียนไว้แต่จุดเรียกใช้สร้าง instance ตรงๆ แทน (เช่น `ProfileService` ใน `auth_state.dart`), ส่วนใหญ่ไม่ได้ลงทะเบียนเลย — ยังไม่มี convention ตายตัว
6. widget ชื่อ `TextButton` เอง (`lib/shared/widgets/utils/text_button.dart`) บัง Material's `TextButton` — ต้อง `hide TextButton` ตอน import material ในไฟล์ที่ใช้ทั้งคู่
7. ~~`user_management.dart` มี `mockGetUser()` เหลือค้าง~~ — **ลบแล้ว (2026-08-30)** ไล่ทั้งโปรเจกต์เจอ mock ที่ไม่มีใครเรียก 18 ตัวใน 12 ไฟล์ ลบครบพร้อม import ที่ค้าง (1,012 บรรทัด) ตอนนี้ทุกหน้ายิง service จริงหมด
8. Auth token ถูกแนบ 2 ทางซ้อนกัน (interceptor + `ApiClient.setToken`) ตามที่บอกด้านบน

## เชื่อมกับ backend
Base URL คนละตัวตาม build mode ใน `ApiConfig` — dev ชี้ `localhost:3000`, prod ชี้ `eng.src.ku.ac.th:3000`. **ระวัง port 3000 ชนกับ process อื่นบนเครื่อง dev** (เคยเจอปัญหา `localhost` resolve ไป service อื่นที่ bind port เดียวกัน ทำให้ได้ 404 ผิดที่แทนที่จะเจอ backend จริง — เช็ค `lsof -i :3000` ถ้า login แล้วได้ 404 แปลกๆ)
