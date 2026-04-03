from typing import Any, Optional
from sqlalchemy.orm import Session
from app.crud.base import CRUDBase
from app.models.all_models import Category, Transaction, Budget
from app.schemas.category import CategoryCreate, CategoryUpdate
from app.schemas.transaction import TransactionCreate, TransactionUpdate
from app.schemas.budget import BudgetCreate, BudgetUpdate

class CRUDCategory(CRUDBase[Category, CategoryCreate, CategoryUpdate]):
    def get_by_name(self, db: Session, *, name: str) -> Optional[Category]:
        return db.query(Category).filter(Category.name == name).first()

class CRUDTransaction(CRUDBase[Transaction, TransactionCreate, TransactionUpdate]):
    def create_with_user(self, db: Session, *, obj_in: TransactionCreate, user_id: int) -> Transaction:
        db_obj = Transaction(
            **obj_in.model_dump(exclude_unset=True),
            user_id=user_id
        )
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj
        
    def get_multi_by_user(self, db: Session, *, user_id: int, skip: int = 0, limit: int = 100):
        return db.query(Transaction).filter(Transaction.user_id == user_id).offset(skip).limit(limit).all()

class CRUDBudget(CRUDBase[Budget, BudgetCreate, BudgetUpdate]):
    def get_by_user_category_month(self, db: Session, *, user_id: int, category_id: int, month_year: str) -> Optional[Budget]:
        return db.query(Budget).filter(
            Budget.user_id == user_id,
            Budget.category_id == category_id,
            Budget.month_year == month_year
        ).first()

    def create_with_user(self, db: Session, *, obj_in: BudgetCreate, user_id: int) -> Budget:
        db_obj = Budget(
            **obj_in.model_dump(),
            user_id=user_id
        )
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

category = CRUDCategory(Category)
transaction = CRUDTransaction(Transaction)
budget = CRUDBudget(Budget)
