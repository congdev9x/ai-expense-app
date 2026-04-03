from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class TransactionBase(BaseModel):
    amount: float
    type: str # 'in' or 'out'
    category_id: int
    note: Optional[str] = None
    image_url: Optional[str] = None
    created_at: Optional[datetime] = None

class TransactionCreate(TransactionBase):
    pass

class TransactionUpdate(BaseModel):
    amount: Optional[float] = None
    type: Optional[str] = None
    category_id: Optional[int] = None
    note: Optional[str] = None
    image_url: Optional[str] = None

class TransactionInDBBase(TransactionBase):
    id: int
    user_id: int
    created_at: datetime

    class Config:
        from_attributes = True

class Transaction(TransactionInDBBase):
    pass
