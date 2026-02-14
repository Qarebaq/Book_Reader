from fastapi import APIRouter
from app.api.v1 import auth, users, library

router = APIRouter(prefix="/api/v1")
router.include_router(auth.router, tags=["auth"])
router.include_router(users.router, tags=["users"])
router.include_router(library.router, tags=["library"])
