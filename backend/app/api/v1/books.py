from pathlib import Path
from uuid import uuid4
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form, status
from fastapi.responses import FileResponse
from sqlalchemy import select
from sqlalchemy.orm import Session
from app.api.v1.users import get_current_user, get_current_user_optional
from app.db.session import get_db
from app.models.book import Book
from app.models.publisher import Publisher
from app.models.purchase import Purchase
from app.models.user import User
from app.schemas.book import BookOut, BookDetailOut
from app.services.drm import encrypt_bytes
from app.core.config import settings

router = APIRouter(prefix="/books")


def _book_to_out(book: Book, purchased: bool = False) -> BookOut:
    return BookOut(
        id=book.id,
        title=book.title,
        publisher=book.publisher.name,
        price=book.price,
        cover_url=book.cover_url,
        purchased=purchased,
    )


def _book_to_detail(book: Book, purchased: bool = False) -> BookDetailOut:
    return BookDetailOut(
        id=book.id,
        title=book.title,
        publisher=book.publisher.name,
        description=book.description,
        price=book.price,
        cover_url=book.cover_url,
        purchased=purchased,
    )


@router.post("", response_model=BookDetailOut)
async def create_book(
    title: str = Form(...),
    publisher_id: int = Form(...),
    description: str | None = Form(None),
    price: int = Form(...),
    cover_url: str | None = Form(None),
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    publisher = db.scalar(select(Publisher).where(Publisher.id == publisher_id))
    if not publisher:
        raise HTTPException(status_code=404, detail="Publisher not found")

    storage_dir = Path(settings.STORAGE_DIR)
    storage_dir.mkdir(parents=True, exist_ok=True)

    original_suffix = Path(file.filename or "").suffix
    file_name = f\"{uuid4().hex}{original_suffix}\"
    file_path = storage_dir / file_name

    raw = await file.read()
    encrypted = encrypt_bytes(raw)
    file_path.write_bytes(encrypted)

    book = Book(
        title=title,
        publisher_id=publisher_id,
        description=description,
        price=price,
        cover_url=cover_url,
        file_path=str(file_path),
    )
    db.add(book)
    db.commit()
    db.refresh(book)
    db.refresh(book, attribute_names=[\"publisher\"])
    return _book_to_detail(book)


@router.get("", response_model=list[BookOut])
def list_books(db: Session = Depends(get_db)):
    books = db.scalars(select(Book).order_by(Book.created_at.desc())).all()
    for book in books:
        if not book.publisher:
            db.refresh(book, attribute_names=[\"publisher\"])
    return [_book_to_out(book) for book in books]


@router.get("/{book_id}", response_model=BookDetailOut)
def get_book(
    book_id: int,
    db: Session = Depends(get_db),
    current_user: User | None = Depends(get_current_user_optional),
):
    book = db.scalar(select(Book).where(Book.id == book_id))
    if not book:
        raise HTTPException(status_code=404, detail="Book not found")
    if not book.publisher:
        db.refresh(book, attribute_names=[\"publisher\"])
    purchased = False
    if current_user:
        existing = db.scalar(
            select(Purchase).where(Purchase.user_id == current_user.id, Purchase.book_id == book_id)
        )
        purchased = existing is not None
    return _book_to_detail(book, purchased=purchased)


@router.post("/{book_id}/purchase", response_model=BookDetailOut)
def purchase_book(
    book_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    book = db.scalar(select(Book).where(Book.id == book_id))
    if not book:
        raise HTTPException(status_code=404, detail="Book not found")

    existing = db.scalar(
        select(Purchase).where(Purchase.user_id == current_user.id, Purchase.book_id == book_id)
    )
    if existing:
        if not book.publisher:
            db.refresh(book, attribute_names=[\"publisher\"])
        return _book_to_detail(book, purchased=True)

    purchase = Purchase(user_id=current_user.id, book_id=book_id)
    db.add(purchase)
    db.commit()
    if not book.publisher:
        db.refresh(book, attribute_names=[\"publisher\"])
    return _book_to_detail(book, purchased=True)


@router.get("/{book_id}/download")
def download_book(
    book_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    book = db.scalar(select(Book).where(Book.id == book_id))
    if not book:
        raise HTTPException(status_code=404, detail="Book not found")

    existing = db.scalar(
        select(Purchase).where(Purchase.user_id == current_user.id, Purchase.book_id == book_id)
    )
    if not existing:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Purchase required")

    path = Path(book.file_path)
    if not path.exists():
        raise HTTPException(status_code=404, detail="File not found")

    filename = f\"{book.title}{path.suffix}\" if path.suffix else book.title
    return FileResponse(path, filename=filename, media_type=\"application/octet-stream\")
