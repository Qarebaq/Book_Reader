from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import select
from app.api.v1.users import get_current_user
from app.db.session import get_db
from app.models.publisher import Publisher
from app.models.user import User
from app.schemas.publisher import PublisherCreate, PublisherOut

router = APIRouter(prefix="/publishers")


def require_admin(current_user: User = Depends(get_current_user)) -> User:
    if not current_user.is_admin:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admin access required")
    return current_user


@router.post("", response_model=PublisherOut)
def create_publisher(
    payload: PublisherCreate,
    db: Session = Depends(get_db),
    _: User = Depends(require_admin),
):
    existing = db.scalar(select(Publisher).where(Publisher.name == payload.name))
    if existing:
        raise HTTPException(status_code=409, detail="Publisher already exists")

    publisher = Publisher(name=payload.name, contact_info=payload.contact_info)
    db.add(publisher)
    db.commit()
    db.refresh(publisher)
    return publisher
