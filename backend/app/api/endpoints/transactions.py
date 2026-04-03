from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.crud.crud_expense import transaction as crud_transaction
from app.schemas.transaction import Transaction, TransactionCreate, TransactionUpdate
from app.api import deps
from app.models.all_models import User

router = APIRouter()

@router.get("/", response_model=List[Transaction])
def read_transactions(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(deps.get_current_user),
) -> Any:
    transactions = crud_transaction.get_multi_by_user(
        db=db, user_id=current_user.id, skip=skip, limit=limit
    )
    return transactions

@router.post("/", response_model=Transaction)
def create_transaction(
    *,
    db: Session = Depends(deps.get_db),
    transaction_in: TransactionCreate,
    current_user: User = Depends(deps.get_current_user),
) -> Any:
    transaction = crud_transaction.create_with_user(
        db=db, obj_in=transaction_in, user_id=current_user.id
    )
    return transaction

@router.put("/{id}", response_model=Transaction)
def update_transaction(
    *,
    db: Session = Depends(deps.get_db),
    id: int,
    transaction_in: TransactionUpdate,
    current_user: User = Depends(deps.get_current_user),
) -> Any:
    transaction = crud_transaction.get(db=db, id=id)
    if not transaction:
        raise HTTPException(status_code=404, detail="Giao dịch không tồn tại")
    if transaction.user_id != current_user.id:
        raise HTTPException(status_code=400, detail="Không đủ quyền truy cập")
    transaction = crud_transaction.update(db=db, db_obj=transaction, obj_in=transaction_in)
    return transaction

@router.delete("/{id}", response_model=Transaction)
def delete_transaction(
    *,
    db: Session = Depends(deps.get_db),
    id: int,
    current_user: User = Depends(deps.get_current_user),
) -> Any:
    transaction = crud_transaction.get(db=db, id=id)
    if not transaction:
        raise HTTPException(status_code=404, detail="Giao dịch không tồn tại")
    if transaction.user_id != current_user.id:
        raise HTTPException(status_code=400, detail="Không đủ quyền truy cập")
    transaction = crud_transaction.remove(db=db, id=id)
    return transaction
