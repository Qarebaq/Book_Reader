from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.orm import Session
from app.api.v1.users import get_current_user
from app.db.session import get_db
from app.models.purchase import Purchase
from app.models.user import User
from app.schemas.book import BookOut

router = APIRouter(prefix="/library")

@router.get("", response_model=list[BookOut])
def my_library(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    purchases = db.scalars(
        select(Purchase).where(Purchase.user_id == current_user.id).order_by(Purchase.purchased_at.desc())
    ).all()
    books = []
    for purchase in purchases:
        book = purchase.book
        if not book.publisher:
            db.refresh(book, attribute_names=["publisher"])
        books.append(
            BookOut(
                id=book.id,
                title=book.title,
                publisher=book.publisher.name,
                price=book.price,
                cover_url=book.cover_url,
                purchased=True,
            )
        )
    return books
