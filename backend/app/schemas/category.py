from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class CategoryBase(BaseModel):
    name: str
    icon: Optional[str] = None
    is_default: Optional[bool] = False

class CategoryCreate(CategoryBase):
    pass

class CategoryUpdate(CategoryBase):
    pass

class CategoryInDBBase(CategoryBase):
    id: int

    class Config:
        from_attributes = True

class Category(CategoryInDBBase):
    pass
