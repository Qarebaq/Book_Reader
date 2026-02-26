from app.db.session import engine
from app.db.base import Base
from app.models.user import User  # noqa: F401
from app.models.publisher import Publisher  # noqa: F401
from app.models.book import Book  # noqa: F401
from app.models.purchase import Purchase  # noqa: F401

Base.metadata.create_all(bind=engine)
print("Tables created.")
