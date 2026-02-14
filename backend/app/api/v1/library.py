from fastapi import APIRouter, Depends
from app.api.v1.users import get_current_user
from app.models.user import User
from app.schemas.book import BookOut

router = APIRouter(prefix="/library")

@router.get("", response_model=list[BookOut])
def my_library(current_user: User = Depends(get_current_user)):
    # فعلاً Mock (بعداً از DB می‌خونیم)
    return [
        BookOut(
            id=1,
            title="زیست دهم تستی",
            publisher="نشر نمونه",
            cover_url=None,
            purchased=True,
        ),
        BookOut(
            id=2,
            title="ریاضی جامع کنکور",
            publisher="نشر نمونه",
            cover_url=None,
            purchased=True,
        ),
    ]
