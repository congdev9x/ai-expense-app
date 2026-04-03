from pydantic import BaseModel
from typing import Optional

class BudgetBase(BaseModel):
    category_id: int
    limit_amount: float
    month_year: str # e.g. "03-2026"

class BudgetCreate(BudgetBase):
    pass

class BudgetUpdate(BaseModel):
    limit_amount: Optional[float] = None

class BudgetInDBBase(BudgetBase):
    id: int
    user_id: int

    class Config:
        from_attributes = True

class Budget(BudgetInDBBase):
    pass
