from pydantic import BaseModel

class BookOut(BaseModel):
    id: int
    title: str
    publisher: str
    cover_url: str | None = None
    purchased: bool = True
