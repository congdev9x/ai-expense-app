from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime

class UserBase(BaseModel):
    email: EmailStr
    currency_pref: Optional[str] = "VND"

class UserCreate(UserBase):
    password: str

class UserUpdate(BaseModel):
    currency_pref: Optional[str] = None
    password: Optional[str] = None

class UserInDBBase(UserBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True

class User(UserInDBBase):
    pass
