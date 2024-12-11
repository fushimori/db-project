# db/connection.py
import asyncpg
import os
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

class Database:
    pool = None

    @classmethod
    async def init_pool(cls):
        cls.pool = await asyncpg.create_pool(DATABASE_URL)

    @classmethod
    async def get_connection(cls):
        if cls.pool is None:
            raise RuntimeError("Database pool is not initialized")
        return cls.pool

    @classmethod
    async def close_pool(cls):
        if cls.pool:
            await cls.pool.close()
