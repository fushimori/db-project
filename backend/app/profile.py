from fastapi import APIRouter, Depends
from app.auth import logged_in_required, get_current_user
from db.connection import Database

router = APIRouter()

@router.get("/")
async def get_profile(role: str = Depends(logged_in_required),
                      username: str = Depends(get_current_user)):
    pool = await Database.get_connection()
    async with pool.acquire() as conn:
        # Запрос для получения базовой информации профиля
        profile_query = """
        SELECT id, username, photo_path
        FROM Users
        WHERE Users.username = $1
        """
        profile_data = await conn.fetchrow(profile_query, username)
        if not profile_data:
            return {"error": "User not found"}

        # Запрос для получения списка друзей
        friends_query = """
        SELECT u.id, u.username, u.photo_path
        FROM UserRelationships ur
        JOIN Users u ON (u.id = ur.user_id_second AND ur.user_id_first = $1)
        WHERE u.id != $1
        """
        friends_list = await conn.fetch(friends_query, profile_data["id"])

        # Запрос для получения списка медиа с их статусом и оценкой
        media_query = """
        SELECT mc.id, mc.title, mc.type, uml.status, r.score
        FROM UserMediaList uml
        JOIN MediaContent mc ON mc.id = uml.media_id
        LEFT JOIN Ratings r ON r.media_id = mc.id AND r.user_id = uml.user_id
        WHERE uml.user_id = $1
        """
        media_list = await conn.fetch(media_query, profile_data["id"])

        return {
            "profile": dict(profile_data),
            "friends": [dict(friend) for friend in friends_list],
            "media_list": [dict(media) for media in media_list]
        }
