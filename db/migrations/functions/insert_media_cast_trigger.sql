CREATE TABLE MediaCastRequests (
    id BIGSERIAL PRIMARY KEY,
    media_title VARCHAR(255) NOT NULL,
    media_type media_type_enum NOT NULL,
    person_name VARCHAR(255),
    person_role_name VARCHAR(255),
    character_name VARCHAR(255),
    character_role_name VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION insert_media_cast()
RETURNS TRIGGER AS $$
DECLARE
    media_id BIGINT;
    person_id BIGINT;
    role_id BIGINT;
    character_id BIGINT;
BEGIN
    -- Проверка на NULL для title или type в MediaContent
    IF NEW.media_title IS NULL OR NEW.media_type IS NULL THEN
        RAISE EXCEPTION 'Title or type cannot be NULL';
    END IF;

    -- Вставка медиа в MediaContent, если его еще нет
    INSERT INTO MediaContent (title, type)
    VALUES (NEW.media_title, NEW.media_type)
    ON CONFLICT (title, type) DO NOTHING
    RETURNING id INTO media_id;

    -- Если медиа не существует, получаем id
    IF media_id IS NULL THEN
        SELECT id INTO media_id
        FROM MediaContent
        WHERE title = NEW.media_title AND type = NEW.media_type
        LIMIT 1;
    END IF;

    -- Обработка вставки персоны, если имя не NULL
    IF NEW.person_name IS NOT NULL THEN
        INSERT INTO Persons (name)
        VALUES (NEW.person_name)
        ON CONFLICT (name) DO NOTHING
        RETURNING id INTO person_id;
        
        IF person_id IS NULL THEN
            SELECT id INTO person_id
            FROM Persons
            WHERE name = NEW.person_name
            LIMIT 1;
        END IF;
    ELSE
        person_id := NULL;
    END IF;

    -- Обработка вставки роли персоны
    IF NEW.person_role_name IS NOT NULL THEN
        INSERT INTO PersonsRoles (name)
        VALUES (NEW.person_role_name)
        ON CONFLICT (name) DO NOTHING
        RETURNING id INTO role_id;
        
        IF role_id IS NULL THEN
            SELECT id INTO role_id
            FROM PersonsRoles
            WHERE name = NEW.person_role_name
            LIMIT 1;
        END IF;
    ELSE
        role_id := NULL;
    END IF; 

    -- Обработка вставки персонажа, если имя не NULL
    IF NEW.character_name IS NOT NULL THEN
        INSERT INTO CharactersList (name)
        VALUES (NEW.character_name)
        ON CONFLICT (name) DO NOTHING
        RETURNING id INTO character_id;
        
        IF character_id IS NULL THEN
            SELECT id INTO character_id
            FROM CharactersList
            WHERE name = NEW.character_name
            LIMIT 1;
        END IF;
    ELSE
        character_id := NULL;
    END IF;

    -- Обработка вставки роли персонажа, если имя не NULL
    IF NEW.character_role_name IS NOT NULL THEN
        INSERT INTO CharactersRoles (name)
        VALUES (NEW.character_role_name)
        ON CONFLICT (name) DO NOTHING
        RETURNING id INTO role_id;
        
        IF role_id IS NULL THEN
            SELECT id INTO role_id
            FROM CharactersRoles
            WHERE name = NEW.character_role_name
            LIMIT 1;
        END IF;
    ELSE
        role_id := NULL;
    END IF; 

    -- Вставка записи в MediaCast с полученными id (если их нет, ставим NULL)
    INSERT INTO MediaCast (media_id, person_id, person_role_id, character_id, character_role_id)
    VALUES (media_id, person_id, role_id, character_id, role_id);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER insert_media_cast_trigger
AFTER INSERT ON MediaCastRequests
FOR EACH ROW
EXECUTE FUNCTION insert_media_cast();

