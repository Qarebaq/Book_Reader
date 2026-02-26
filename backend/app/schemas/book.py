from pydantic import BaseModel


class BookOut(BaseModel):
    id: int
    title: str
    publisher: str
    price: int
    cover_url: str | None = None
    purchased: bool = False


class BookDetailOut(BaseModel):
    id: int
    title: str
    publisher: str
    description: str | None = None
    price: int
    cover_url: str | None = None
    purchased: bool = False


class BookCreate(BaseModel):
    title: str
    publisher_id: int
    description: str | None = None
    price: int
    cover_url: str | None = None
