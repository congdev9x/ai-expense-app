# AI Expense Application
Dự án Quản lý Chi tiêu cá nhân thông minh siêu xịn xò với AI (Gemini).  
Stack công nghệ: **Flutter (Frontend)** - **FastAPI (Backend)** - **PostgreSQL (Database)**

## Yêu cầu Hệ thống
- Docker & Docker Compose
- Python 3.12+ (sử dụng Conda)
- Flutter SDK (cho Web/Mobile)

## 🚀 Hướng Dẫn Chạy Dự Án (Start Project)

Mỗi ngày mở lại máy tính, bạn chỉ cần làm theo 3 bước sau là hệ thống sẽ chạy lại hoàn hảo.

### Bước 1: Khởi động Database (Postgres, Redis, ELK)
Mở terminal tại thư mục gốc của dự án (`ai-expense-app`) và chạy:
```bash
docker compose up -d
```
Lệnh này chạy dưới Desktop (background) nên bạn ko cần giữ Terminal mở.

### Bước 2: Khởi động Backend API (FastAPI)
Mở một giao diện Terminal mới tại thư mục gốc, kích hoạt môi trường Python (nếu dùng Conda) và start Uvicorn Server:
```bash
# Kích hoạt conda môi trường chứa các thư viện Python
conda activate python312

# Di chuyển vào folder backend
cd backend

# Khởi chạy server API ở port 8000
uvicorn main:app --reload --host 127.0.0.1 --port 8000
```
> **Lưu ý:** Terminal này phải được MỞ XUYÊN SUỐT trong quá trình sử dụng App. Cứ để đấy cho nó chạy ngầm nhé.

### Bước 3: Khởi động App Flutter (Giao diện hiển thị)
Mở thêm một Terminal mới tinh nữa (để tránh đè lên cái backend), di chuyển vào code frontend và chạy Web server:
```bash
cd frontend
flutter run -d web-server --web-port 8080
```
> **Lưu ý:** Tương tự backend, hãy giữ cửa sổ Terminal này luôn mở.

🎉 Chúc mừng! Giờ hãy mở trình duyệt lên và vào địa chỉ **`http://localhost:8080`** để sử dụng ứng dụng!

## 🛠️ Hướng Dẫn Build Ứng Dụng (Build App)

Để chạy ứng dụng trên điện thoại Android thật, bạn cần thực hiện build file APK theo các bước sau:

### Bước 1: Cấu hình IP Backend
Mở file `frontend/lib/core/api/api_config.dart` và cập nhật `baseUrl` sang địa chỉ IP LAN của máy tính chạy Backend (ví dụ: `192.168.2.163` thay vì `127.0.0.1`).
> **Lưu ý:** Cả điện thoại và máy tính phải kết nối chung một mạng WiFi.

### Bước 2: Thực hiện Build APK
Mở terminal tại thư mục `frontend` và chạy lệnh:
```bash
flutter build apk --release
```
File APK sau khi build xong sẽ nằm tại đường dẫn:  
`frontend/build/app/outputs/flutter-apk/app-release.apk`

### Bước 3: Cài đặt & Sử dụng
- Copy file `app-release.apk` sang điện thoại Android.
- Mở file trên điện thoại và tiến hành cài đặt.
- Đảm bảo Backend (Docker & FastAPI) đang chạy trên máy tính trước khi mở App trên điện thoại.
