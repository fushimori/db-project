# db/queriers.py
from db.connection import Database
from app.auth import get_password_hash

async def get_user_by_username(username: str):
    pool = await Database.get_connection()
    async with pool.acquire() as conn:
        query = "SELECT * FROM Users WHERE username = $1"
        return await conn.fetchrow(query, username)

async def create_admin(username: str, email: str, password: str):
    pool = await Database.get_connection()
    async with pool.acquire() as conn:
        existing_admin = await get_user_by_username(username)
        if not existing_admin:
            hashed_password = get_password_hash(password)
            query = """
            INSERT INTO users (username, email, password, role)
            VALUES ($1, $2, $3, $4)
            """
            await conn.execute(query, username, email, hashed_password, "admin")

async def create_user(username: str, email: str, password: str):
    pool = await Database.get_connection()
    async with pool.acquire() as conn:
        query = "INSERT INTO Users (username, email, password, role) VALUES ($1, $2, $3, 'user')"
        await conn.execute(query, username, email, password)

async def get_all_users():
    pool = await Database.get_connection()
    async with pool.acquire() as conn:
        query = "SELECT * FROM Users"
        return await conn.fetch(query)
