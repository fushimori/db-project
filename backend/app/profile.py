# app/profile.py
from fastapi import APIRouter, Depends
from app.auth import logged_in_required, get_current_user
from db.connection import Database

router = APIRouter()

@router.get("/")
async def get_profile(role: str = Depends(logged_in_required),
                       username: str = Depends(get_current_user)):
    pool = await Database.get_connection()
    async with pool.acquire() as conn:
        query = """
        SELECT username, photo_path
        FROM Users
        WHERE Users.username = $1
        """
        profile_data = await conn.fetchrow(query, username)
        print(profile_data)
        return {"profile": dict(profile_data)}


