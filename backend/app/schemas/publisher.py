from pydantic import BaseModel


class PublisherCreate(BaseModel):
    name: str
    contact_info: str | None = None


class PublisherOut(BaseModel):
    id: int
    name: str
    contact_info: str | None = None

    class Config:
        from_attributes = True
