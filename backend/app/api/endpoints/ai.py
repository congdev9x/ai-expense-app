from typing import Any
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.api import deps
from app.models.all_models import User
from app.services.ai_service import parse_expense_text
from app.crud.crud_expense import category as crud_category
from app.schemas.category import CategoryCreate
from pydantic import BaseModel

class AIInput(BaseModel):
    text: str

router = APIRouter()

@router.post("/parse-text")
def parse_text_expense(
    input_data: AIInput,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_user),
) -> Any:
    """
    Phân tích câu nhập liệu tự do bằng Gemini AI.
    Trả về dự đoán số tiền và danh mục để Frontend điền tự động vào Form.
    """
    if not input_data.text.strip():
        raise HTTPException(status_code=400, detail="Text cannot be empty")
        
    # Lấy danh sách danh mục hiện có trong DB để gợi ý cho AI
    existing_categories = crud_category.get_multi(db)
    category_names = [c.name for c in existing_categories]
    
    result = parse_expense_text(input_data.text, categories=category_names)
    
    # Tìm category_id phù hợp với category_hint
    category_hint = result.get("category_hint", "Khác")
    matched_category = next((c for c in existing_categories if c.name.lower() == category_hint.lower()), None)
    
    if matched_category:
        result["category_id"] = matched_category.id
    else:
        # Nếu AI trả về 1 danh mục mới chưa từng có, tự động tạo mới
        new_cat = crud_category.create(db, obj_in=CategoryCreate(name=category_hint, icon="category", is_default=False))
        result["category_id"] = new_cat.id

    return {
        "success": True,
        "parsed_data": result
    }
