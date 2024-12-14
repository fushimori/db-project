# app/media.py
from datetime import datetime
from io import StringIO
from fastapi import UploadFile, HTTPException
import csv
from db.connection import Database


async def fetch_media_list(media_type: str, table_name: str, current_user: str = None):
    """
    Получает список медиа из указанной таблицы с учетом авторизации пользователя.
    """
    pool = await Database.get_connection()
    async with pool.acquire() as conn:
        base_query = f"SELECT id, title, photo_path, type FROM {table_name}"
        media_list = await conn.fetch(base_query)

        if current_user:
            extended_data = []
            for media in media_list:
                media_dict = dict(media)
                status_query = """
                SELECT status FROM UserMediaList
                WHERE user_id = (SELECT id FROM Users WHERE username = $1)
                AND media_id = $2
                """
                status_record = await conn.fetchrow(status_query, current_user, media["id"])
                media_dict["status"] = status_record["status"] if status_record else None
                extended_data.append(media_dict)
            return extended_data

        return [dict(media) for media in media_list]


async def search_media(query: str, table_name: str, current_user: str = None):
    """
    Выполняет поиск медиа по названию в указанной таблице.
    """
    pool = await Database.get_connection()
    async with pool.acquire() as conn:
        base_query = f"""
        SELECT id, title, photo_path, type FROM {table_name}
        WHERE title ILIKE $1
        """
        search_results = await conn.fetch(base_query, f"%{query}%")

        if current_user:
            extended_data = []
            for result in search_results:
                result_dict = dict(result)
                status_query = """
                SELECT status FROM UserMediaList
                WHERE user_id = (SELECT id FROM Users WHERE username = $1)
                AND media_id = $2
                """
                status_record = await conn.fetchrow(status_query, current_user, result["id"])
                result_dict["status"] = status_record["status"] if status_record else None
                extended_data.append(result_dict)
            return extended_data

        return [dict(result) for result in search_results]


async def fetch_media_details(media_id: int, table_name: str, current_user: str = None):
    """
    Получает подробную информацию о медиа из указанной таблицы.
    """
    pool = await Database.get_connection()
    async with pool.acquire() as conn:
        # Основная информация о медиа
        query = f"""
        SELECT id, title, photo_path, description,
               type, release_date, avg_rating, status,
               end_date, chapter_count, episode_count
        FROM {table_name}
        WHERE id = $1
        """
        media_details = await conn.fetchrow(query, media_id)
        if not media_details:
            return None

        media_details_dict = dict(media_details)

        # Информация о пользователе (если указан)
        if current_user:
            status_query = """
            SELECT status FROM UserMediaList
            WHERE user_id = (SELECT id FROM Users WHERE username = $1)
            AND media_id = $2
            """
            status_record = await conn.fetchrow(status_query, current_user, media_id)
            media_details_dict["user_status"] = status_record["status"] if status_record else None

            rating_query = """
            SELECT score FROM ratings
            WHERE user_id = (SELECT id FROM Users WHERE username = $1)
            AND media_id = $2
            """
            rating_record = await conn.fetchrow(rating_query, current_user, media_id)
            media_details_dict["user_rating"] = rating_record["score"] if rating_record else None

            review_query = """
            SELECT id FROM reviews
            WHERE user_id = (SELECT id FROM Users WHERE username = $1)
            AND media_id = $2
            """
            review_record = await conn.fetchrow(review_query, current_user, media_id)
            media_details_dict["user_review_id"] = review_record["id"] if review_record else None

        # Каст медиа
        cast_query = """
        SELECT p.name AS person_name, pr.name AS person_role,
               c.name AS character_name, cr.name AS character_role
        FROM MediaCast mc
        JOIN Persons p ON mc.person_id = p.id
        JOIN PersonsRoles pr ON mc.person_role_id = pr.id
        LEFT JOIN CharactersList c ON mc.character_id = c.id
        LEFT JOIN CharactersRoles cr ON mc.character_role_id = cr.id
        WHERE mc.media_id = $1
        """
        cast_records = await conn.fetch(cast_query, media_id)
        media_details_dict["cast"] = [dict(record) for record in cast_records]

        # Жанры медиа
        genres_query = """
        SELECT g.name AS genre_name
        FROM MediaGenres mg
        JOIN Genres g ON mg.genre_id = g.id
        WHERE mg.media_id = $1
        """
        genres_records = await conn.fetch(genres_query, media_id)
        media_details_dict["genres"] = [record["genre_name"] for record in genres_records]

        # Связанные медиа
        related_media_query = """
        SELECT mc.title AS related_title, mr.relationship_type
        FROM MediaRelationships mr
        JOIN MediaContent mc ON mr.media_id_second = mc.id
        WHERE mr.media_id_first = $1
        """
        related_media_records = await conn.fetch(related_media_query, media_id)
        media_details_dict["related_media"] = [dict(record) for record in related_media_records]

        return media_details_dict
    
async def manage_media_for_user_list(username: str, media_id: int, media_type: str, action: str = "add", status: str = None):
    """
    Универсальная функция для добавления, обновления или удаления медиа любого типа в/из списка пользователя.
    
    :param username: Имя пользователя
    :param media_id: ID медиа
    :param media_type: Тип медиа (например, anime, movie, etc.)
    :param action: Действие, которое нужно выполнить ("add", "update", "remove")
    :param status: Статус медиа, только для добавления или обновления
    """
    valid_statuses = {'watching', 'completed', 'planned', 'on_hold', 'dropped'}
    print(username, media_id, media_type, action, status)
    if action not in ['add', 'update', 'remove']:
        raise HTTPException(status_code=400, detail="Invalid action. Allowed values: 'add', 'update', 'remove'.")

    if action in ['add', 'update'] and status not in valid_statuses:
        raise HTTPException(status_code=400, detail=f"Invalid status. Allowed values: {', '.join(valid_statuses)}")

    pool = await Database.get_connection()
    async with pool.acquire() as conn:
        # Проверяем, существует ли медиа указанного типа
        media_exists = await conn.fetchrow(
            """
            SELECT id FROM MediaContent WHERE id = $1 AND type = $2
            """,
            media_id, media_type
        )

        if not media_exists:
            raise HTTPException(status_code=404, detail="Media not found")

        # Получаем ID пользователя по username
        user_id_record = await conn.fetchrow(
            """
            SELECT id FROM Users WHERE username = $1
            """,
            username
        )

        if not user_id_record:
            raise HTTPException(status_code=404, detail="User not found")

        user_id = user_id_record["id"]

        async with conn.transaction():
            if action == 'add' or action == 'update':
                # Добавляем или обновляем запись
                existing_record = await conn.fetchrow(
                    """
                    SELECT id FROM UserMediaList WHERE user_id = $1 AND media_id = $2
                    """,
                    user_id, media_id
                )

                if existing_record:
                    # Обновляем статус, если запись уже существует
                    await conn.execute(
                        """
                        UPDATE UserMediaList SET status = $1 WHERE id = $2
                        """,
                        status, existing_record["id"]
                    )
                else:
                    # Добавляем новую запись
                    await conn.execute(
                        """
                        INSERT INTO UserMediaList (user_id, media_id, status) VALUES ($1, $2, $3)
                        """,
                        user_id, media_id, status
                    )
            else:
                # Удаляем запись
                await conn.execute(
                    """
                    DELETE FROM UserMediaList WHERE user_id = $1 AND media_id = $2
                    """,
                    user_id, media_id
                )


async def upload_csv_to_table(file: UploadFile):
    """
    Загрузка CSV-файла в таблицу с проверкой на существующие записи.
    """
    contents = await file.read()
    csv_file = StringIO(contents.decode('utf-8'))
    reader = csv.DictReader(csv_file)

    pool = await Database.get_connection()
    async with pool.acquire() as conn:
        async with conn.transaction():
            for row in reader:
                # Преобразуем строки в данные для добавления в таблицу
                title = row.get('title')
                description = row.get('description')
                avg_rating = (
                    float(row['avg_rating']) if row.get('avg_rating') and row['avg_rating'] != 'null' else None
                )
                media_type = row.get('type')
                release_date = (
                    datetime.strptime(row['release_date'], '%Y-%m-%d').date()
                    if row.get('release_date') and row['release_date'] != 'null'
                    else None
                )
                status = row.get('status')
                end_date = (
                    datetime.strptime(row['end_date'], '%Y-%m-%d').date()
                    if row.get('end_date') and row['end_date'] != 'null'
                    else None
                )
                chapter_count = (
                    int(row['chapter_count']) if row.get('chapter_count') and row['chapter_count'] != 'null' else None
                )
                episode_count = (
                    int(row['episode_count']) if row.get('episode_count') and row['episode_count'] != 'null' else None
                )
                photo_path = row.get('photo_path')

                # Проверка на существование записи
                existing_record = await conn.fetchrow(
                    """
                    SELECT id FROM MediaContent WHERE title = $1 AND type = $2
                    """,
                    title, media_type
                )

                if existing_record:
                    # Логируем или игнорируем, если запись существует
                    print(f"Запись с title={title} и type={media_type} уже существует.")
                    continue

                # Вставка данных в таблицу
                await conn.execute(
                    """
                    INSERT INTO MediaContent (title, description, avg_rating, type, release_date, 
                                              status, end_date, chapter_count, episode_count, photo_path)
                    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
                    """,
                    title, description, avg_rating, media_type, release_date, status, end_date, chapter_count, episode_count, photo_path
                )

    return {"message": "CSV file uploaded successfully, duplicates skipped!"}


async def delete_media_from_table(media_id: int, table_name: str):
    """
    Удаляет запись медиа из указанной таблицы по ID.
    """
    pool = await Database.get_connection()
    async with pool.acquire() as conn:
        # Проверяем, существует ли запись
        media = await conn.fetchrow(f"SELECT * FROM {table_name} WHERE id = $1", media_id)
        if not media:
            raise HTTPException(status_code=404, detail="Media not found")
        
        # Удаляем запись
        await conn.execute(f"DELETE FROM {table_name} WHERE id = $1", media_id)

    return {"message": "Media deleted successfully"}
