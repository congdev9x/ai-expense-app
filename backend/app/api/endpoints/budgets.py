from typing import Any
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.crud.crud_expense import budget as crud_budget
from app.schemas.budget import Budget, BudgetCreate
from app.api import deps
from app.models.all_models import User

router = APIRouter()

@router.post("/", response_model=Budget)
def create_budget(
    *,
    db: Session = Depends(deps.get_db),
    budget_in: BudgetCreate,
    current_user: User = Depends(deps.get_current_user),
) -> Any:
    budget = crud_budget.get_by_user_category_month(
        db=db, user_id=current_user.id, category_id=budget_in.category_id, month_year=budget_in.month_year
    )
    if budget:
        raise HTTPException(status_code=400, detail="Budget for this category and month already exists.")
    budget = crud_budget.create_with_user(
        db=db, obj_in=budget_in, user_id=current_user.id
    )
    return budget
