# app/main.py
import uvicorn
from fastapi import FastAPI
from app.user import router as user_router
from app.admin import router as admin_router
from db.connection import Database
from db.queriers import create_admin
from typing import AsyncGenerator
from fastapi.middleware.cors import CORSMiddleware

async def lifespan(app: FastAPI) -> AsyncGenerator:
    await Database.init_pool()
    await create_admin("admin", "admin@admin.com", "admin")
    yield
    await Database.close_pool()

app = FastAPI(lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],  # Разрешите доступ для фронтенда
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"message": "Welcome to the API!"}

app.include_router(user_router, prefix="/users", tags=["users"])
app.include_router(admin_router, prefix="/admin", tags=["admin"])

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)
