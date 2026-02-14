from fastapi import FastAPI
from app.api.v1.router import router as v1_router

app = FastAPI(title="Ketabkhan API")
app.include_router(v1_router)

@app.get("/api/v1/health")
def health():
    return {"status": "ok"}
