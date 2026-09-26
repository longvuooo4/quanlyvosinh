# Karate Manager

Ứng dụng Flutter quản lý một câu lạc bộ Karate trên Android/iOS.
Phiên bản hiện tại: **1.0.0+1**.

## Chức năng v1.0

- Đổi tên câu lạc bộ và xem dashboard tổng quan.
- Thêm, sửa, tìm kiếm và xóa hồ sơ võ sinh.
- Theo dõi số điện thoại, trạng thái tập luyện và cấp đai Karate.
- Tạo lớp, lịch tập, huấn luyện viên và địa điểm.
- Xếp một võ sinh vào nhiều lớp.
- Điểm danh theo lớp và ngày.
- Ghi nhận khoản thu, khoản chi và tính số dư.
- Lưu dữ liệu bền vững trên thiết bị bằng SharedPreferences.
- Giao diện Material 3 tiếng Việt, hỗ trợ màn hình nhỏ và cỡ chữ lớn.

Ứng dụng không yêu cầu Internet và không gửi dữ liệu ra máy chủ. Dữ liệu của v1.0
chỉ nằm trên thiết bị; gỡ ứng dụng hoặc xóa dữ liệu ứng dụng có thể làm mất dữ liệu.

## Phát triển

Yêu cầu Flutter 3.47.5 stable và Dart 3.13.4.

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

## Build Android

```sh
flutter build apk --release
flutter build appbundle --release
```

Release Android đọc khóa ký từ `android/key.properties`. File này và keystore
được bỏ qua trong Git. Phải giữ bản sao khóa ký và mật khẩu để cập nhật ứng dụng
trên Google Play sau này.

## Cấu trúc

```text
lib/app/                  Bootstrap, theme và router
lib/features/club/domain  Mô hình dữ liệu Karate
lib/features/club/data    Kho dữ liệu cục bộ
lib/features/club/presentation  ViewModel và giao diện
test/                     Unit và widget tests
docs/                     Kế hoạch phát triển tiếp theo
```

## Giới hạn và lộ trình

v1.0 phục vụ một người quản lý trên một thiết bị. Đăng nhập, phân quyền, đồng bộ
nhiều thiết bị, nhập Excel, sao lưu đám mây và lịch sử sửa đổi là phạm vi của bản
cloud tiếp theo. Xem `docs/implementation-plan.md`.
