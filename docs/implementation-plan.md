# Lộ trình Karate Manager

## Đã hoàn thành — v1.0 local

- Ứng dụng Flutter Android/iOS bằng tiếng Việt.
- Quản lý võ sinh, cấp đai, lớp Karate và xếp lớp.
- Điểm danh theo lớp/ngày.
- Theo dõi thu, chi và số dư.
- Lưu dữ liệu trên thiết bị; không cần tài khoản hay Internet.
- Android release được ký bằng khóa riêng; có APK cài trực tiếp và AAB cho Play.

## Chặng tiếp theo — v1.1

- Chi tiết lịch sử điểm danh theo võ sinh.
- Học phí theo tháng, trạng thái nợ và thanh toán một phần.
- Sao lưu/khôi phục tệp JSON hoặc Excel.
- Lịch sử thăng đai và ngày thi.
- Báo cáo theo tháng và xuất dữ liệu.

## Bản cloud — v2.0

- Đăng nhập, lời mời và vai trò quản lý/HLV.
- Đồng bộ nhiều thiết bị và nhiều cơ sở.
- Backend Supabase, migration database và Row Level Security.
- Mọi dữ liệu nghiệp vụ có `club_id`; kiểm thử cách ly giữa hai CLB.
- Audit log, transaction máy chủ và idempotency cho điểm danh/tài chính.

Không đưa dữ liệu thật lên cloud trước khi RLS và kiểm thử cách ly hoàn tất.
