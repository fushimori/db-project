# app/main.py
import uvicorn
from fastapi.staticfiles import StaticFiles
from fastapi import FastAPI, Depends
from app.user import router as user_router
from app.admin import router as admin_router
from app.profile import router as profile_router
from app.manga import router as manga_router
from app.anime import router as anime_router
from app.movie import router as movie_router
from app.series import router as serial_router
from app.book import router as book_router
from app.person import router as person_router
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
app.mount("/static", StaticFiles(directory="static"), name="static")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"message": "Welcome to the API!"}

app.include_router(admin_router, prefix="/admin", tags=["admin"])
app.include_router(user_router, prefix="/user", tags=["user"])
app.include_router(profile_router, prefix="/profile", tags=["profile"])
app.include_router(manga_router, prefix="/manga", tags=["manga"])
app.include_router(anime_router, prefix="/anime", tags=["anime"])
app.include_router(movie_router, prefix="/movie", tags=["movie"])
app.include_router(serial_router, prefix="/series", tags=["series"])
app.include_router(book_router, prefix="/book", tags=["book"])
app.include_router(person_router, prefix="/person", tags=["person"])


if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)
