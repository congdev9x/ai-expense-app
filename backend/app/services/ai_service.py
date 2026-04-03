import google.generativeai as genai
import json
from datetime import datetime, timedelta
from app.core.config import get_settings

settings = get_settings()
genai.configure(api_key=settings.GEMINI_API_KEY)

# Use the latest fast model
model = genai.GenerativeModel('gemini-2.5-flash')

def parse_expense_text(text: str, categories: list = None) -> dict:
    """
    Sử dụng Gemini để phân tích một câu nói/nhập liệu text
    thành object chứa số tiền (amount), loại danh mục (category) và ngày (date).
    """
    now = datetime.now()
    today_str = now.strftime("%Y-%m-%d")
    yesterday_str = (now - timedelta(days=1)).strftime("%Y-%m-%d")
    
    # Lấy thông tin thứ trong tuần (0: Thứ 2, 6: Chủ nhật)
    weekdays = ["Thứ 2", "Thứ 3", "Thứ 4", "Thứ 5", "Thứ 6", "Thứ 7", "Chủ Nhật"]
    current_weekday = weekdays[now.weekday()]
    current_year = now.year
    
    categories_hint = f"Các danh mục bạn đã từng dùng: {', '.join(categories)}. \n    NẾU KHÔNG CÓ DANH MỤC NÀO PHÙ HỢP với nội dung chi tiêu, HOẶC DANH SÁCH TRÊN CÒN TRỐNG, hãy TỰ ĐẶT RA một Tên danh mục mới ngắn gọn (VD: Di chuyển, Mua sắm, v.v...)." if categories else "Ví dụ: An uong, Mua sam, Di lai, Giai tri, Hoa don, Khac"
    
    prompt = f"""
    Bạn là một trợ lý tài chính thông minh. Người dùng sẽ cung cấp một đoạn văn bản (Text) ghi chép chi tiêu hoặc thu nhập.
    Nhiệm vụ của bạn là trích xuất số tiền (dạng số nguyên VND, nếu viết 30k thì là 30000), loại giao dịch, loại danh mục và ngày tháng gốc.
    - Phân loại Giao dịch: Trả về chữ "in" nếu đó là Khoản thu/Thu nhập (VD: nhận lương, được thưởng, bán đồ cũ). Trả về "out" nếu đó là Khoản chi/Chi tiêu.
    - {categories_hint}
    - Suy luận ngày tháng dựa vào ngữ cảnh câu nói. Định dạng trả về BẮT BUỘC là YYYY-MM-DD. 
      Lưu ý các mốc thời gian thực tế: 
      + Hôm nay là: {current_weekday}, năm {current_year}, ngày {today_str}
      + Hôm qua là: {yesterday_str}
      Hãy tự tính toán (cộng trừ ngày) nếu người dùng nhắc đến "thứ 2 tuần trước", "tháng trước", "hôm kia", v.v... dựa vào mốc Hôm nay.
      Nếu người dùng chỉ nhập ngày/tháng (VD: 15/2) mà không nhập năm, hãy tự hiểu là năm {current_year}!
      Nếu không đề cập đến thời gian, hoặc không rõ, hãy lấy ngày {today_str}.
      Nếu không đề cập đến thời gian, hoặc không rõ, hãy lấy ngày {today_str}.
    
    Văn bản người dùng: "{text}"
    
    Phản hồi DUY NHẤT bằng một valid JSON có định dạng sau (không chứa ký tự Markdown ```json):
    {{
        "amount": 30000,
        "type": "out",
        "category_hint": "Tên danh mục",
        "date": "2026-03-01",
        "note": "cafe"
    }}
    """
    
    response = model.generate_content(prompt)
    try:
        # Làm sạch nếu AI trả về markdown code block
        result_text = response.text.strip()
        if result_text.startswith("```json"):
            result_text = result_text[7:]
        if result_text.endswith("```"):
            result_text = result_text[:-3]
            
        return json.loads(result_text.strip())
    except Exception as e:
        print(f"Error parsing Gemini response: {e}")
        return {"amount": 0, "type": "out", "category_hint": "Khac", "date": datetime.now().strftime("%Y-%m-%d"), "note": text}
