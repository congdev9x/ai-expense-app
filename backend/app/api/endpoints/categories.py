from typing import Any, List
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.crud.crud_expense import category as crud_category
from app.schemas.category import Category, CategoryCreate
from app.api import deps

router = APIRouter()

@router.get("/", response_model=List[Category])
def read_categories(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
) -> Any:
    categories = crud_category.get_multi(db, skip=skip, limit=limit)
    return categories

@router.post("/", response_model=Category)
def create_category(
    *,
    db: Session = Depends(deps.get_db),
    category_in: CategoryCreate,
) -> Any:
    category = crud_category.create(db, obj_in=category_in)
    return category
