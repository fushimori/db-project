CREATE TABLE MediaGenreRequests (
    id BIGSERIAL PRIMARY KEY,
    media_title VARCHAR(255) NOT NULL,
    media_type media_type_enum NOT NULL,
    genre_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION insert_media_genre()
RETURNS TRIGGER AS $$
DECLARE
    media_id BIGINT;
    genre_id BIGINT;
BEGIN
    -- Проверка на NULL
    IF NEW.media_title IS NULL OR NEW.media_type IS NULL OR NEW.genre_name IS NULL THEN
        RAISE EXCEPTION 'Title, type, or genre_name cannot be NULL';
    END IF;

    -- Вставка медиа в MediaContent, если его еще нет
    INSERT INTO MediaContent (title, type)
    VALUES (NEW.media_title, NEW.media_type)
    ON CONFLICT (title, type) DO NOTHING
    RETURNING id INTO media_id;

    -- Получение id, если медиа уже существует
    IF media_id IS NULL THEN
        SELECT id INTO media_id
        FROM MediaContent
        WHERE title = NEW.media_title AND type = NEW.media_type
        LIMIT 1;
    END IF;

    -- Вставка жанра в Genres, если его еще нет
    INSERT INTO Genres (name)
    VALUES (NEW.genre_name)
    ON CONFLICT (name) DO NOTHING
    RETURNING id INTO genre_id;

    -- Получение id, если жанр уже существует
    IF genre_id IS NULL THEN
        SELECT id INTO genre_id
        FROM Genres
        WHERE name = NEW.genre_name
        LIMIT 1;
    END IF;

    -- Вставка связи в MediaGenres
    INSERT INTO MediaGenres (media_id, genre_id)
    VALUES (media_id, genre_id);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER insert_media_genre_trigger
AFTER INSERT ON MediaGenreRequests
FOR EACH ROW
EXECUTE FUNCTION insert_media_genre();
