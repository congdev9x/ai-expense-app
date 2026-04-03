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
