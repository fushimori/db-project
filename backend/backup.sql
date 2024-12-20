PGDMP         !                 |            postgres     13.18 (Debian 13.18-1.pgdg120+1)    15.10 (Debian 15.10-0+deb12u1) �    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    13468    postgres    DATABASE     s   CREATE DATABASE postgres WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';
    DROP DATABASE postgres;
                mori    false            �           0    0    DATABASE postgres    COMMENT     N   COMMENT ON DATABASE postgres IS 'default administrative connection database';
                   mori    false    3315                        2615    2200    public    SCHEMA     2   -- *not* creating schema, since initdb creates it
 2   -- *not* dropping schema, since initdb creates it
                mori    false            �           0    0    SCHEMA public    ACL     Q   REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;
                   mori    false    5            �           1247    18292    media_relationship_type_enum    TYPE     �   CREATE TYPE public.media_relationship_type_enum AS ENUM (
    'sequel',
    'prequel',
    'spin-off',
    'adaptation',
    'original'
);
 /   DROP TYPE public.media_relationship_type_enum;
       public          mori    false    5            �           1247    18304    media_status_enum    TYPE     p   CREATE TYPE public.media_status_enum AS ENUM (
    'ongoing',
    'completed',
    'hiatus',
    'cancelled'
);
 $   DROP TYPE public.media_status_enum;
       public          mori    false    5            �           1247    18314    media_type_enum    TYPE     p   CREATE TYPE public.media_type_enum AS ENUM (
    'anime',
    'manga',
    'book',
    'movie',
    'series'
);
 "   DROP TYPE public.media_type_enum;
       public          mori    false    5            �           1247    18326    user_media_status_enum    TYPE     �   CREATE TYPE public.user_media_status_enum AS ENUM (
    'watching',
    'completed',
    'planned',
    'on_hold',
    'dropped'
);
 )   DROP TYPE public.user_media_status_enum;
       public          mori    false    5            �           1247    18338    user_relationship_type_enum    TYPE     V   CREATE TYPE public.user_relationship_type_enum AS ENUM (
    'friend',
    'block'
);
 .   DROP TYPE public.user_relationship_type_enum;
       public          mori    false    5            �           1247    18344    user_role_enum    TYPE     U   CREATE TYPE public.user_role_enum AS ENUM (
    'admin',
    'editor',
    'user'
);
 !   DROP TYPE public.user_role_enum;
       public          mori    false    5            �            1255    18351    add_user_media_list() 	   PROCEDURE     _  CREATE PROCEDURE public.add_user_media_list()
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Добавление записи для пользователя 'd' и аниме 'Naruto'
    INSERT INTO usermedialist (user_id, media_id, status)
    VALUES (
        (SELECT id FROM users WHERE username = 'd'),
        (SELECT id FROM mediacontent WHERE title = 'Naruto' AND type = 'anime'),
        'watching'
    );

    -- Добавление записи для пользователя 'd' и аниме 'One Piece'
    INSERT INTO usermedialist (user_id, media_id, status)
    VALUES (
        (SELECT id FROM users WHERE username = 'd'),
        (SELECT id FROM mediacontent WHERE title = 'One Piece'),
        'completed'
    );

    -- Подтверждение выполнения
    RAISE NOTICE 'User media list entries added successfully.';
END;
$$;
 -   DROP PROCEDURE public.add_user_media_list();
       public          mori    false    5            �            1255    18352    insert_media_cast()    FUNCTION     �  CREATE FUNCTION public.insert_media_cast() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;
 *   DROP FUNCTION public.insert_media_cast();
       public          mori    false    5            �            1255    18353    insert_media_genre()    FUNCTION     �  CREATE FUNCTION public.insert_media_genre() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;
 +   DROP FUNCTION public.insert_media_genre();
       public          mori    false    5            �            1255    18354    insert_or_update_person()    FUNCTION     �  CREATE FUNCTION public.insert_or_update_person() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Проверка на существование записи с таким же name
    IF EXISTS (SELECT 1 FROM Persons WHERE name = NEW.name) THEN
        -- Обновление существующей записи
        UPDATE Persons
        SET birth_date = NEW.birth_date,
            nationality = NEW.nationality,
            main_role = NEW.main_role
        WHERE name = NEW.name;
        RETURN NULL; -- Возвращаем NULL, чтобы не вставить новую строку
    ELSE
        -- Если записи нет, вставляем новую
        RETURN NEW;
    END IF;
END;
$$;
 0   DROP FUNCTION public.insert_or_update_person();
       public          mori    false    5            �            1255    18355    log_changes()    FUNCTION     �  CREATE FUNCTION public.log_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO ChangeLogs (table_name, operation, changed_data)
        VALUES (TG_TABLE_NAME, TG_OP, row_to_json(NEW));
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO ChangeLogs (table_name, operation, changed_data)
        VALUES (TG_TABLE_NAME, TG_OP, jsonb_build_object(
            'old_data', row_to_json(OLD),
            'new_data', row_to_json(NEW)
        ));
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO ChangeLogs (table_name, operation, changed_data)
        VALUES (TG_TABLE_NAME, TG_OP, row_to_json(OLD));
    END IF;
    RETURN NULL;
END;
$$;
 $   DROP FUNCTION public.log_changes();
       public          mori    false    5            �            1255    18356    update_media_avg_rating()    FUNCTION       CREATE FUNCTION public.update_media_avg_rating() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE MediaContent
    SET avg_rating = (
        SELECT AVG(score) FROM Ratings WHERE media_id = NEW.media_id
    )
    WHERE id = NEW.media_id;
    RETURN NEW;
END;
$$;
 0   DROP FUNCTION public.update_media_avg_rating();
       public          mori    false    5                        1255    18357    update_media_status_on_end()    FUNCTION       CREATE FUNCTION public.update_media_status_on_end() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Проверяем, если end_date есть и он прошел, то устанавливаем статус 'completed'
    IF (NEW.end_date IS NOT NULL AND NEW.end_date <= CURRENT_DATE AND NEW.status != 'completed') THEN
        NEW.status := 'completed';
    END IF;
    
    -- Вставляем или обновляем данные по статусу медиа
    RETURN NEW;
END;
$$;
 3   DROP FUNCTION public.update_media_status_on_end();
       public          mori    false    5                       1255    18358    update_photo_paths() 	   PROCEDURE     �  CREATE PROCEDURE public.update_photo_paths()
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Обновление путей к изображениям в таблице mediacontent
    UPDATE mediacontent SET photo_path = '/static/anime/naruto.jpeg' WHERE title = 'Naruto' AND type = 'anime';
    UPDATE mediacontent SET photo_path = '/static/anime/one_piece.jpeg' WHERE title = 'One Piece' AND type = 'anime';
    UPDATE mediacontent SET photo_path = '/static/anime/your_name.jpeg' WHERE title = 'Your Name' AND type = 'anime';
    UPDATE mediacontent SET photo_path = '/static/anime/dragon_ball_z.jpeg' WHERE title = 'Dragon Ball Z' AND type = 'anime';
    UPDATE mediacontent SET photo_path = '/static/anime/shingeki_no_kyojin_the_final_season.jpeg' WHERE title = 'Shingeki no Kyojin: The Final Season' AND type = 'anime';
    UPDATE mediacontent SET photo_path = '/static/anime/jujutsu_kaisen.jpeg' WHERE title = 'Jujutsu Kaisen' AND type = 'anime';
    UPDATE mediacontent SET photo_path = '/static/movie/ringu.jpg' WHERE title = 'Ringu' AND type = 'movie';
    UPDATE mediacontent SET photo_path = '/static/book/norwegian_wood.jpg' WHERE title = 'Norwegian Wood' AND type = 'book';
    UPDATE mediacontent SET photo_path = '/static/manga/naruto.png' WHERE title = 'Naruto' AND type = 'manga';
    UPDATE mediacontent SET photo_path = '/static/series/the_naked_director.jpg' WHERE title = 'The Naked Director' AND type = 'series';
    UPDATE mediacontent SET photo_path = '/static/manga/my_hero_academy.jpeg' WHERE title = 'My Hero Academia' AND type = 'manga';

    -- Обновление путей к изображениям в таблице persons
    UPDATE persons SET photo_path = '/static/person/mayumi_tanaka.jpeg' WHERE name = 'Mayumi Tanaka';
    UPDATE persons SET photo_path = '/static/person/haruki_murakami.jpg' WHERE name = 'Haruki Murakami';
    UPDATE persons SET photo_path = '/static/person/hajime_isayama.jpg' WHERE name = 'Hajime Isayama';
    UPDATE persons SET photo_path = '/static/person/masako_nozawa.jpg' WHERE name = 'Masako Nozawa';
    UPDATE persons SET photo_path = '/static/person/nanako_matsushima.jpg' WHERE name = 'Nanako Matsushima';
    UPDATE persons SET photo_path = '/static/person/takayuki_yamada.jpg' WHERE name = 'Takayuki Yamada';
    UPDATE persons SET photo_path = '/static/person/takahiro_sakurai.jpg' WHERE name = 'Takahiro Sakurai';

    -- Обновление путей к изображениям в таблице users
    UPDATE users SET photo_path = '/static/user/dog.png' WHERE id = 1;
    UPDATE users SET photo_path = '/static/user/lion.png' WHERE id = 2;
    UPDATE users SET photo_path = '/static/user/jaguar.png' WHERE id = 3;
    UPDATE users SET photo_path = '/static/user/unicorn.png' WHERE id = 4;
    UPDATE users SET photo_path = '/static/user/snake.png' WHERE id = 5;

    -- Обновление путей к изображениям в таблице characterslist
    UPDATE characterslist SET photo_path = '/static/character/levi.jpg' WHERE name = 'Levi';
    UPDATE characterslist SET photo_path = '/static/character/goku.jpg' WHERE name = 'Goku';
    UPDATE characterslist SET photo_path = '/static/character/sasuke_uchiha.jpg' WHERE name = 'Sasuke Uchiha';
    UPDATE characterslist SET photo_path = '/static/character/naruto_uzumaki.jpg' WHERE name = 'Naruto Uzumaki';
    UPDATE characterslist SET photo_path = '/static/character/monkey_d_luffy.jpg' WHERE name = 'Monkey D. Luffy';
    UPDATE characterslist SET photo_path = '/static/character/sadako_yamamura.jpg' WHERE name = 'Sadako Yamamura';
    UPDATE characterslist SET photo_path = '/static/character/toru_watanabe.jpg' WHERE name = 'Toru Watanabe';
    UPDATE characterslist SET photo_path = '/static/character/ryuichi_hirose.jpg' WHERE name = 'Ryuichi Hirose';
    UPDATE characterslist SET photo_path = '/static/character/eren_yeger.jpg' WHERE name = 'Eren Yeger';

    -- Подтверждение выполнения
    RAISE NOTICE 'Photo paths updated successfully.';
END;
$$;
 ,   DROP PROCEDURE public.update_photo_paths();
       public          mori    false    5            �            1259    18359 
   changelogs    TABLE     �   CREATE TABLE public.changelogs (
    id bigint NOT NULL,
    table_name character varying(255) NOT NULL,
    operation character varying(10) NOT NULL,
    changed_data jsonb,
    change_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
    DROP TABLE public.changelogs;
       public         heap    mori    false    5            �            1259    18366    changelogs_id_seq    SEQUENCE     z   CREATE SEQUENCE public.changelogs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.changelogs_id_seq;
       public          mori    false    200    5            �           0    0    changelogs_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.changelogs_id_seq OWNED BY public.changelogs.id;
          public          mori    false    201            �            1259    18368    characterslist    TABLE     �   CREATE TABLE public.characterslist (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    photo_path character varying(255) DEFAULT '/static/default.png'::character varying
);
 "   DROP TABLE public.characterslist;
       public         heap    mori    false    5            �            1259    18375    characterslist_id_seq    SEQUENCE     ~   CREATE SEQUENCE public.characterslist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.characterslist_id_seq;
       public          mori    false    202    5            �           0    0    characterslist_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.characterslist_id_seq OWNED BY public.characterslist.id;
          public          mori    false    203            �            1259    18377    charactersroles    TABLE     j   CREATE TABLE public.charactersroles (
    id bigint NOT NULL,
    name character varying(255) NOT NULL
);
 #   DROP TABLE public.charactersroles;
       public         heap    mori    false    5            �            1259    18380    charactersroles_id_seq    SEQUENCE        CREATE SEQUENCE public.charactersroles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.charactersroles_id_seq;
       public          mori    false    204    5            �           0    0    charactersroles_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.charactersroles_id_seq OWNED BY public.charactersroles.id;
          public          mori    false    205            �            1259    18382    genres    TABLE     a   CREATE TABLE public.genres (
    id bigint NOT NULL,
    name character varying(255) NOT NULL
);
    DROP TABLE public.genres;
       public         heap    mori    false    5            �            1259    18385    genres_id_seq    SEQUENCE     v   CREATE SEQUENCE public.genres_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.genres_id_seq;
       public          mori    false    5    206            �           0    0    genres_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.genres_id_seq OWNED BY public.genres.id;
          public          mori    false    207            �            1259    18387    mediacontent    TABLE     -  CREATE TABLE public.mediacontent (
    id bigint NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    avg_rating double precision,
    type public.media_type_enum NOT NULL,
    release_date date,
    status public.media_status_enum,
    end_date date,
    chapter_count bigint,
    episode_count bigint,
    photo_path character varying(255) DEFAULT '/static/default.png'::character varying,
    CONSTRAINT mediacontent_avg_rating_check CHECK (((avg_rating >= (1)::double precision) AND (avg_rating <= (10)::double precision)))
);
     DROP TABLE public.mediacontent;
       public         heap    mori    false    672    675    5            �            1259    18395    media_content_anime    VIEW     �  CREATE VIEW public.media_content_anime AS
 SELECT mediacontent.id,
    mediacontent.title,
    mediacontent.description,
    mediacontent.avg_rating,
    mediacontent.type,
    mediacontent.release_date,
    mediacontent.status,
    mediacontent.end_date,
    mediacontent.chapter_count,
    mediacontent.episode_count,
    mediacontent.photo_path
   FROM public.mediacontent
  WHERE (mediacontent.type = 'anime'::public.media_type_enum);
 &   DROP VIEW public.media_content_anime;
       public          mori    false    208    208    208    208    208    208    208    208    208    208    208    675    675    5    672            �            1259    18399    media_content_book    VIEW     �  CREATE VIEW public.media_content_book AS
 SELECT mediacontent.id,
    mediacontent.title,
    mediacontent.description,
    mediacontent.avg_rating,
    mediacontent.type,
    mediacontent.release_date,
    mediacontent.status,
    mediacontent.end_date,
    mediacontent.chapter_count,
    mediacontent.episode_count,
    mediacontent.photo_path
   FROM public.mediacontent
  WHERE (mediacontent.type = 'book'::public.media_type_enum);
 %   DROP VIEW public.media_content_book;
       public          mori    false    208    208    208    208    208    208    208    208    208    208    208    675    675    5    672            �            1259    18403    media_content_manga    VIEW     �  CREATE VIEW public.media_content_manga AS
 SELECT mediacontent.id,
    mediacontent.title,
    mediacontent.description,
    mediacontent.avg_rating,
    mediacontent.type,
    mediacontent.release_date,
    mediacontent.status,
    mediacontent.end_date,
    mediacontent.chapter_count,
    mediacontent.episode_count,
    mediacontent.photo_path
   FROM public.mediacontent
  WHERE (mediacontent.type = 'manga'::public.media_type_enum);
 &   DROP VIEW public.media_content_manga;
       public          mori    false    208    208    208    208    208    208    208    208    208    208    208    675    672    675    5            �            1259    18407    media_content_movie    VIEW     �  CREATE VIEW public.media_content_movie AS
 SELECT mediacontent.id,
    mediacontent.title,
    mediacontent.description,
    mediacontent.avg_rating,
    mediacontent.type,
    mediacontent.release_date,
    mediacontent.status,
    mediacontent.end_date,
    mediacontent.chapter_count,
    mediacontent.episode_count,
    mediacontent.photo_path
   FROM public.mediacontent
  WHERE (mediacontent.type = 'movie'::public.media_type_enum);
 &   DROP VIEW public.media_content_movie;
       public          mori    false    208    208    208    208    208    208    208    208    208    208    208    675    672    5    675            �            1259    18411    media_content_series    VIEW     �  CREATE VIEW public.media_content_series AS
 SELECT mediacontent.id,
    mediacontent.title,
    mediacontent.description,
    mediacontent.avg_rating,
    mediacontent.type,
    mediacontent.release_date,
    mediacontent.status,
    mediacontent.end_date,
    mediacontent.chapter_count,
    mediacontent.episode_count,
    mediacontent.photo_path
   FROM public.mediacontent
  WHERE (mediacontent.type = 'series'::public.media_type_enum);
 '   DROP VIEW public.media_content_series;
       public          mori    false    208    208    208    208    208    208    208    208    208    208    675    208    5    672    675            �            1259    18415 	   mediacast    TABLE     �   CREATE TABLE public.mediacast (
    id bigint NOT NULL,
    media_id bigint,
    person_id bigint,
    person_role_id bigint,
    character_id bigint,
    character_role_id bigint
);
    DROP TABLE public.mediacast;
       public         heap    mori    false    5            �            1259    18418    mediacast_id_seq    SEQUENCE     y   CREATE SEQUENCE public.mediacast_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.mediacast_id_seq;
       public          mori    false    214    5            �           0    0    mediacast_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.mediacast_id_seq OWNED BY public.mediacast.id;
          public          mori    false    215            �            1259    18420    mediacastrequests    TABLE     �  CREATE TABLE public.mediacastrequests (
    id bigint NOT NULL,
    media_title character varying(255) NOT NULL,
    media_type public.media_type_enum NOT NULL,
    person_name character varying(255),
    person_role_name character varying(255),
    character_name character varying(255),
    character_role_name character varying(255),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
 %   DROP TABLE public.mediacastrequests;
       public         heap    mori    false    675    5            �            1259    18427    mediacastrequests_id_seq    SEQUENCE     �   CREATE SEQUENCE public.mediacastrequests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.mediacastrequests_id_seq;
       public          mori    false    5    216            �           0    0    mediacastrequests_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.mediacastrequests_id_seq OWNED BY public.mediacastrequests.id;
          public          mori    false    217            �            1259    18429    mediacontent_id_seq    SEQUENCE     |   CREATE SEQUENCE public.mediacontent_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.mediacontent_id_seq;
       public          mori    false    5    208            �           0    0    mediacontent_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.mediacontent_id_seq OWNED BY public.mediacontent.id;
          public          mori    false    218            �            1259    18431    mediagenrerequests    TABLE       CREATE TABLE public.mediagenrerequests (
    id bigint NOT NULL,
    media_title character varying(255) NOT NULL,
    media_type public.media_type_enum NOT NULL,
    genre_name character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
 &   DROP TABLE public.mediagenrerequests;
       public         heap    mori    false    675    5            �            1259    18438    mediagenrerequests_id_seq    SEQUENCE     �   CREATE SEQUENCE public.mediagenrerequests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.mediagenrerequests_id_seq;
       public          mori    false    219    5            �           0    0    mediagenrerequests_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.mediagenrerequests_id_seq OWNED BY public.mediagenrerequests.id;
          public          mori    false    220            �            1259    18440    mediagenres    TABLE     f   CREATE TABLE public.mediagenres (
    id bigint NOT NULL,
    media_id bigint,
    genre_id bigint
);
    DROP TABLE public.mediagenres;
       public         heap    mori    false    5            �            1259    18443    mediagenres_id_seq    SEQUENCE     {   CREATE SEQUENCE public.mediagenres_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.mediagenres_id_seq;
       public          mori    false    5    221            �           0    0    mediagenres_id_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.mediagenres_id_seq OWNED BY public.mediagenres.id;
          public          mori    false    222            �            1259    18445    mediarelationships    TABLE     �   CREATE TABLE public.mediarelationships (
    id bigint NOT NULL,
    media_id_first bigint,
    media_id_second bigint,
    relationship_type public.media_relationship_type_enum NOT NULL
);
 &   DROP TABLE public.mediarelationships;
       public         heap    mori    false    669    5            �            1259    18448    mediarelationships_id_seq    SEQUENCE     �   CREATE SEQUENCE public.mediarelationships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.mediarelationships_id_seq;
       public          mori    false    223    5            �           0    0    mediarelationships_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.mediarelationships_id_seq OWNED BY public.mediarelationships.id;
          public          mori    false    224            �            1259    18450    persons    TABLE       CREATE TABLE public.persons (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    birth_date date,
    nationality character varying(255),
    main_role character varying(255),
    photo_path character varying(255) DEFAULT '/static/default.png'::character varying
);
    DROP TABLE public.persons;
       public         heap    mori    false    5            �            1259    18457    persons_id_seq    SEQUENCE     w   CREATE SEQUENCE public.persons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.persons_id_seq;
       public          mori    false    5    225                        0    0    persons_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.persons_id_seq OWNED BY public.persons.id;
          public          mori    false    226            �            1259    18459    personsroles    TABLE     g   CREATE TABLE public.personsroles (
    id bigint NOT NULL,
    name character varying(255) NOT NULL
);
     DROP TABLE public.personsroles;
       public         heap    mori    false    5            �            1259    18462    personsroles_id_seq    SEQUENCE     |   CREATE SEQUENCE public.personsroles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.personsroles_id_seq;
       public          mori    false    227    5                       0    0    personsroles_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.personsroles_id_seq OWNED BY public.personsroles.id;
          public          mori    false    228            �            1259    18464    ratings    TABLE     �   CREATE TABLE public.ratings (
    id bigint NOT NULL,
    user_id bigint,
    media_id bigint,
    score integer,
    CONSTRAINT ratings_score_check CHECK (((score >= 1) AND (score <= 10)))
);
    DROP TABLE public.ratings;
       public         heap    mori    false    5            �            1259    18468    ratings_id_seq    SEQUENCE     w   CREATE SEQUENCE public.ratings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.ratings_id_seq;
       public          mori    false    229    5                       0    0    ratings_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.ratings_id_seq OWNED BY public.ratings.id;
          public          mori    false    230            �            1259    18470    reviews    TABLE     �   CREATE TABLE public.reviews (
    id bigint NOT NULL,
    media_id bigint,
    user_id bigint,
    creation_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    review_text text
);
    DROP TABLE public.reviews;
       public         heap    mori    false    5            �            1259    18477    reviews_id_seq    SEQUENCE     w   CREATE SEQUENCE public.reviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.reviews_id_seq;
       public          mori    false    5    231                       0    0    reviews_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.reviews_id_seq OWNED BY public.reviews.id;
          public          mori    false    232            �            1259    18479    usermedialist    TABLE     �   CREATE TABLE public.usermedialist (
    id bigint NOT NULL,
    user_id bigint,
    media_id bigint,
    status public.user_media_status_enum NOT NULL
);
 !   DROP TABLE public.usermedialist;
       public         heap    mori    false    678    5            �            1259    18482    usermedialist_id_seq    SEQUENCE     }   CREATE SEQUENCE public.usermedialist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.usermedialist_id_seq;
       public          mori    false    233    5                       0    0    usermedialist_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.usermedialist_id_seq OWNED BY public.usermedialist.id;
          public          mori    false    234            �            1259    18484    userrelationships    TABLE     �   CREATE TABLE public.userrelationships (
    id bigint NOT NULL,
    user_id_first bigint,
    user_id_second bigint,
    relationship_type public.user_relationship_type_enum NOT NULL
);
 %   DROP TABLE public.userrelationships;
       public         heap    mori    false    681    5            �            1259    18487    userrelationships_id_seq    SEQUENCE     �   CREATE SEQUENCE public.userrelationships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.userrelationships_id_seq;
       public          mori    false    235    5                       0    0    userrelationships_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.userrelationships_id_seq OWNED BY public.userrelationships.id;
          public          mori    false    236            �            1259    18489    users    TABLE     [  CREATE TABLE public.users (
    id bigint NOT NULL,
    username character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    role public.user_role_enum DEFAULT 'user'::public.user_role_enum,
    photo_path character varying(255) DEFAULT '/static/default.png'::character varying
);
    DROP TABLE public.users;
       public         heap    mori    false    684    684    5            �            1259    18497    users_id_seq    SEQUENCE     u   CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.users_id_seq;
       public          mori    false    5    237                       0    0    users_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;
          public          mori    false    238            �           2604    18499    changelogs id    DEFAULT     n   ALTER TABLE ONLY public.changelogs ALTER COLUMN id SET DEFAULT nextval('public.changelogs_id_seq'::regclass);
 <   ALTER TABLE public.changelogs ALTER COLUMN id DROP DEFAULT;
       public          mori    false    201    200            �           2604    18500    characterslist id    DEFAULT     v   ALTER TABLE ONLY public.characterslist ALTER COLUMN id SET DEFAULT nextval('public.characterslist_id_seq'::regclass);
 @   ALTER TABLE public.characterslist ALTER COLUMN id DROP DEFAULT;
       public          mori    false    203    202            �           2604    18501    charactersroles id    DEFAULT     x   ALTER TABLE ONLY public.charactersroles ALTER COLUMN id SET DEFAULT nextval('public.charactersroles_id_seq'::regclass);
 A   ALTER TABLE public.charactersroles ALTER COLUMN id DROP DEFAULT;
       public          mori    false    205    204            �           2604    18502 	   genres id    DEFAULT     f   ALTER TABLE ONLY public.genres ALTER COLUMN id SET DEFAULT nextval('public.genres_id_seq'::regclass);
 8   ALTER TABLE public.genres ALTER COLUMN id DROP DEFAULT;
       public          mori    false    207    206            �           2604    18503    mediacast id    DEFAULT     l   ALTER TABLE ONLY public.mediacast ALTER COLUMN id SET DEFAULT nextval('public.mediacast_id_seq'::regclass);
 ;   ALTER TABLE public.mediacast ALTER COLUMN id DROP DEFAULT;
       public          mori    false    215    214            �           2604    18504    mediacastrequests id    DEFAULT     |   ALTER TABLE ONLY public.mediacastrequests ALTER COLUMN id SET DEFAULT nextval('public.mediacastrequests_id_seq'::regclass);
 C   ALTER TABLE public.mediacastrequests ALTER COLUMN id DROP DEFAULT;
       public          mori    false    217    216            �           2604    18505    mediacontent id    DEFAULT     r   ALTER TABLE ONLY public.mediacontent ALTER COLUMN id SET DEFAULT nextval('public.mediacontent_id_seq'::regclass);
 >   ALTER TABLE public.mediacontent ALTER COLUMN id DROP DEFAULT;
       public          mori    false    218    208            �           2604    18506    mediagenrerequests id    DEFAULT     ~   ALTER TABLE ONLY public.mediagenrerequests ALTER COLUMN id SET DEFAULT nextval('public.mediagenrerequests_id_seq'::regclass);
 D   ALTER TABLE public.mediagenrerequests ALTER COLUMN id DROP DEFAULT;
       public          mori    false    220    219            �           2604    18507    mediagenres id    DEFAULT     p   ALTER TABLE ONLY public.mediagenres ALTER COLUMN id SET DEFAULT nextval('public.mediagenres_id_seq'::regclass);
 =   ALTER TABLE public.mediagenres ALTER COLUMN id DROP DEFAULT;
       public          mori    false    222    221            �           2604    18508    mediarelationships id    DEFAULT     ~   ALTER TABLE ONLY public.mediarelationships ALTER COLUMN id SET DEFAULT nextval('public.mediarelationships_id_seq'::regclass);
 D   ALTER TABLE public.mediarelationships ALTER COLUMN id DROP DEFAULT;
       public          mori    false    224    223            �           2604    18509 
   persons id    DEFAULT     h   ALTER TABLE ONLY public.persons ALTER COLUMN id SET DEFAULT nextval('public.persons_id_seq'::regclass);
 9   ALTER TABLE public.persons ALTER COLUMN id DROP DEFAULT;
       public          mori    false    226    225            �           2604    18510    personsroles id    DEFAULT     r   ALTER TABLE ONLY public.personsroles ALTER COLUMN id SET DEFAULT nextval('public.personsroles_id_seq'::regclass);
 >   ALTER TABLE public.personsroles ALTER COLUMN id DROP DEFAULT;
       public          mori    false    228    227            �           2604    18511 
   ratings id    DEFAULT     h   ALTER TABLE ONLY public.ratings ALTER COLUMN id SET DEFAULT nextval('public.ratings_id_seq'::regclass);
 9   ALTER TABLE public.ratings ALTER COLUMN id DROP DEFAULT;
       public          mori    false    230    229            �           2604    18512 
   reviews id    DEFAULT     h   ALTER TABLE ONLY public.reviews ALTER COLUMN id SET DEFAULT nextval('public.reviews_id_seq'::regclass);
 9   ALTER TABLE public.reviews ALTER COLUMN id DROP DEFAULT;
       public          mori    false    232    231            �           2604    18513    usermedialist id    DEFAULT     t   ALTER TABLE ONLY public.usermedialist ALTER COLUMN id SET DEFAULT nextval('public.usermedialist_id_seq'::regclass);
 ?   ALTER TABLE public.usermedialist ALTER COLUMN id DROP DEFAULT;
       public          mori    false    234    233            �           2604    18514    userrelationships id    DEFAULT     |   ALTER TABLE ONLY public.userrelationships ALTER COLUMN id SET DEFAULT nextval('public.userrelationships_id_seq'::regclass);
 C   ALTER TABLE public.userrelationships ALTER COLUMN id DROP DEFAULT;
       public          mori    false    236    235            �           2604    18515    users id    DEFAULT     d   ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);
 7   ALTER TABLE public.users ALTER COLUMN id DROP DEFAULT;
       public          mori    false    238    237            �          0    18359 
   changelogs 
   TABLE DATA           Z   COPY public.changelogs (id, table_name, operation, changed_data, change_time) FROM stdin;
    public          mori    false    200   J      �          0    18368    characterslist 
   TABLE DATA           >   COPY public.characterslist (id, name, photo_path) FROM stdin;
    public          mori    false    202   ;+      �          0    18377    charactersroles 
   TABLE DATA           3   COPY public.charactersroles (id, name) FROM stdin;
    public          mori    false    204   ',      �          0    18382    genres 
   TABLE DATA           *   COPY public.genres (id, name) FROM stdin;
    public          mori    false    206   ],      �          0    18415 	   mediacast 
   TABLE DATA           m   COPY public.mediacast (id, media_id, person_id, person_role_id, character_id, character_role_id) FROM stdin;
    public          mori    false    214   �,      �          0    18420    mediacastrequests 
   TABLE DATA           �   COPY public.mediacastrequests (id, media_title, media_type, person_name, person_role_name, character_name, character_role_name, created_at) FROM stdin;
    public          mori    false    216   "-      �          0    18387    mediacontent 
   TABLE DATA           �   COPY public.mediacontent (id, title, description, avg_rating, type, release_date, status, end_date, chapter_count, episode_count, photo_path) FROM stdin;
    public          mori    false    208   �.      �          0    18431    mediagenrerequests 
   TABLE DATA           a   COPY public.mediagenrerequests (id, media_title, media_type, genre_name, created_at) FROM stdin;
    public          mori    false    219   �1      �          0    18440    mediagenres 
   TABLE DATA           =   COPY public.mediagenres (id, media_id, genre_id) FROM stdin;
    public          mori    false    221   �2      �          0    18445    mediarelationships 
   TABLE DATA           d   COPY public.mediarelationships (id, media_id_first, media_id_second, relationship_type) FROM stdin;
    public          mori    false    223   3      �          0    18450    persons 
   TABLE DATA           [   COPY public.persons (id, name, birth_date, nationality, main_role, photo_path) FROM stdin;
    public          mori    false    225   )3      �          0    18459    personsroles 
   TABLE DATA           0   COPY public.personsroles (id, name) FROM stdin;
    public          mori    false    227   A4      �          0    18464    ratings 
   TABLE DATA           ?   COPY public.ratings (id, user_id, media_id, score) FROM stdin;
    public          mori    false    229   �4      �          0    18470    reviews 
   TABLE DATA           T   COPY public.reviews (id, media_id, user_id, creation_time, review_text) FROM stdin;
    public          mori    false    231   �4      �          0    18479    usermedialist 
   TABLE DATA           F   COPY public.usermedialist (id, user_id, media_id, status) FROM stdin;
    public          mori    false    233   R5      �          0    18484    userrelationships 
   TABLE DATA           a   COPY public.userrelationships (id, user_id_first, user_id_second, relationship_type) FROM stdin;
    public          mori    false    235   �5      �          0    18489    users 
   TABLE DATA           P   COPY public.users (id, username, email, password, role, photo_path) FROM stdin;
    public          mori    false    237   �5                 0    0    changelogs_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.changelogs_id_seq', 126, true);
          public          mori    false    201                       0    0    characterslist_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.characterslist_id_seq', 14, true);
          public          mori    false    203            	           0    0    charactersroles_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.charactersroles_id_seq', 9, true);
          public          mori    false    205            
           0    0    genres_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.genres_id_seq', 14, true);
          public          mori    false    207                       0    0    mediacast_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.mediacast_id_seq', 7, true);
          public          mori    false    215                       0    0    mediacastrequests_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.mediacastrequests_id_seq', 7, true);
          public          mori    false    217                       0    0    mediacontent_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.mediacontent_id_seq', 35, true);
          public          mori    false    218                       0    0    mediagenrerequests_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.mediagenrerequests_id_seq', 9, true);
          public          mori    false    220                       0    0    mediagenres_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.mediagenres_id_seq', 9, true);
          public          mori    false    222                       0    0    mediarelationships_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.mediarelationships_id_seq', 1, false);
          public          mori    false    224                       0    0    persons_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.persons_id_seq', 11, true);
          public          mori    false    226                       0    0    personsroles_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.personsroles_id_seq', 9, true);
          public          mori    false    228                       0    0    ratings_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.ratings_id_seq', 7, true);
          public          mori    false    230                       0    0    reviews_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.reviews_id_seq', 2, true);
          public          mori    false    232                       0    0    usermedialist_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.usermedialist_id_seq', 19, true);
          public          mori    false    234                       0    0    userrelationships_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.userrelationships_id_seq', 2, true);
          public          mori    false    236                       0    0    users_id_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.users_id_seq', 5, true);
          public          mori    false    238            �           2606    18517    changelogs changelogs_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.changelogs
    ADD CONSTRAINT changelogs_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.changelogs DROP CONSTRAINT changelogs_pkey;
       public            mori    false    200            �           2606    18519 &   characterslist characterslist_name_key 
   CONSTRAINT     a   ALTER TABLE ONLY public.characterslist
    ADD CONSTRAINT characterslist_name_key UNIQUE (name);
 P   ALTER TABLE ONLY public.characterslist DROP CONSTRAINT characterslist_name_key;
       public            mori    false    202            �           2606    18521 "   characterslist characterslist_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.characterslist
    ADD CONSTRAINT characterslist_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.characterslist DROP CONSTRAINT characterslist_pkey;
       public            mori    false    202            �           2606    18523 (   charactersroles charactersroles_name_key 
   CONSTRAINT     c   ALTER TABLE ONLY public.charactersroles
    ADD CONSTRAINT charactersroles_name_key UNIQUE (name);
 R   ALTER TABLE ONLY public.charactersroles DROP CONSTRAINT charactersroles_name_key;
       public            mori    false    204            �           2606    18525 $   charactersroles charactersroles_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.charactersroles
    ADD CONSTRAINT charactersroles_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.charactersroles DROP CONSTRAINT charactersroles_pkey;
       public            mori    false    204            �           2606    18527    genres genres_name_key 
   CONSTRAINT     Q   ALTER TABLE ONLY public.genres
    ADD CONSTRAINT genres_name_key UNIQUE (name);
 @   ALTER TABLE ONLY public.genres DROP CONSTRAINT genres_name_key;
       public            mori    false    206            �           2606    18529    genres genres_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.genres
    ADD CONSTRAINT genres_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.genres DROP CONSTRAINT genres_pkey;
       public            mori    false    206                        2606    18531    mediacast mediacast_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.mediacast
    ADD CONSTRAINT mediacast_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.mediacast DROP CONSTRAINT mediacast_pkey;
       public            mori    false    214                       2606    18533 (   mediacastrequests mediacastrequests_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.mediacastrequests
    ADD CONSTRAINT mediacastrequests_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.mediacastrequests DROP CONSTRAINT mediacastrequests_pkey;
       public            mori    false    216            �           2606    18535    mediacontent mediacontent_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.mediacontent
    ADD CONSTRAINT mediacontent_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.mediacontent DROP CONSTRAINT mediacontent_pkey;
       public            mori    false    208                       2606    18537 *   mediagenrerequests mediagenrerequests_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.mediagenrerequests
    ADD CONSTRAINT mediagenrerequests_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.mediagenrerequests DROP CONSTRAINT mediagenrerequests_pkey;
       public            mori    false    219                       2606    18539    mediagenres mediagenres_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.mediagenres
    ADD CONSTRAINT mediagenres_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.mediagenres DROP CONSTRAINT mediagenres_pkey;
       public            mori    false    221            
           2606    18541 *   mediarelationships mediarelationships_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.mediarelationships
    ADD CONSTRAINT mediarelationships_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.mediarelationships DROP CONSTRAINT mediarelationships_pkey;
       public            mori    false    223                       2606    18543    persons persons_name_key 
   CONSTRAINT     S   ALTER TABLE ONLY public.persons
    ADD CONSTRAINT persons_name_key UNIQUE (name);
 B   ALTER TABLE ONLY public.persons DROP CONSTRAINT persons_name_key;
       public            mori    false    225                       2606    18545    persons persons_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.persons
    ADD CONSTRAINT persons_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.persons DROP CONSTRAINT persons_pkey;
       public            mori    false    225                       2606    18547 "   personsroles personsroles_name_key 
   CONSTRAINT     ]   ALTER TABLE ONLY public.personsroles
    ADD CONSTRAINT personsroles_name_key UNIQUE (name);
 L   ALTER TABLE ONLY public.personsroles DROP CONSTRAINT personsroles_name_key;
       public            mori    false    227                       2606    18549    personsroles personsroles_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.personsroles
    ADD CONSTRAINT personsroles_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.personsroles DROP CONSTRAINT personsroles_pkey;
       public            mori    false    227                       2606    18551    ratings ratings_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT ratings_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.ratings DROP CONSTRAINT ratings_pkey;
       public            mori    false    229                       2606    18553    reviews reviews_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.reviews DROP CONSTRAINT reviews_pkey;
       public            mori    false    231                       2606    18555     usermedialist usermedialist_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.usermedialist
    ADD CONSTRAINT usermedialist_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.usermedialist DROP CONSTRAINT usermedialist_pkey;
       public            mori    false    233                       2606    18557 (   userrelationships userrelationships_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.userrelationships
    ADD CONSTRAINT userrelationships_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.userrelationships DROP CONSTRAINT userrelationships_pkey;
       public            mori    false    235            !           2606    18559    users users_email_key 
   CONSTRAINT     Q   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);
 ?   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key;
       public            mori    false    237            #           2606    18561    users users_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
       public            mori    false    237            %           2606    18563    users users_username_key 
   CONSTRAINT     W   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_username_key;
       public            mori    false    237                       1259    18564    unique_media_cast_index    INDEX     �   CREATE UNIQUE INDEX unique_media_cast_index ON public.mediacast USING btree (media_id, person_id, character_id, person_role_id);
 +   DROP INDEX public.unique_media_cast_index;
       public            mori    false    214    214    214    214                       1259    18565    unique_media_genre_index    INDEX     e   CREATE UNIQUE INDEX unique_media_genre_index ON public.mediagenres USING btree (media_id, genre_id);
 ,   DROP INDEX public.unique_media_genre_index;
       public            mori    false    221    221                       1259    18566    unique_media_relationship_index    INDEX     �   CREATE UNIQUE INDEX unique_media_relationship_index ON public.mediarelationships USING btree (media_id_first, media_id_second, relationship_type);
 3   DROP INDEX public.unique_media_relationship_index;
       public            mori    false    223    223    223            �           1259    18567    unique_media_title_type_index    INDEX     d   CREATE UNIQUE INDEX unique_media_title_type_index ON public.mediacontent USING btree (title, type);
 1   DROP INDEX public.unique_media_title_type_index;
       public            mori    false    208    208                       1259    18568 $   unique_media_user_relationship_index    INDEX     r   CREATE UNIQUE INDEX unique_media_user_relationship_index ON public.usermedialist USING btree (user_id, media_id);
 8   DROP INDEX public.unique_media_user_relationship_index;
       public            mori    false    233    233                       1259    18569    unique_rating_index    INDEX     [   CREATE UNIQUE INDEX unique_rating_index ON public.ratings USING btree (user_id, media_id);
 '   DROP INDEX public.unique_rating_index;
       public            mori    false    229    229                       1259    18570    unique_review_index    INDEX     h   CREATE UNIQUE INDEX unique_review_index ON public.reviews USING btree (user_id, media_id, review_text);
 '   DROP INDEX public.unique_review_index;
       public            mori    false    231    231    231                       1259    18571    unique_user_relationship_index    INDEX     �   CREATE UNIQUE INDEX unique_user_relationship_index ON public.userrelationships USING btree (user_id_first, user_id_second, relationship_type);
 2   DROP INDEX public.unique_user_relationship_index;
       public            mori    false    235    235    235            7           2620    18572 %   characterslist characters_log_trigger    TRIGGER     �   CREATE TRIGGER characters_log_trigger AFTER INSERT OR DELETE OR UPDATE ON public.characterslist FOR EACH ROW EXECUTE FUNCTION public.log_changes();
 >   DROP TRIGGER characters_log_trigger ON public.characterslist;
       public          mori    false    254    202            ;           2620    18573 +   mediacastrequests insert_media_cast_trigger    TRIGGER     �   CREATE TRIGGER insert_media_cast_trigger AFTER INSERT ON public.mediacastrequests FOR EACH ROW EXECUTE FUNCTION public.insert_media_cast();
 D   DROP TRIGGER insert_media_cast_trigger ON public.mediacastrequests;
       public          mori    false    251    216            <           2620    18574 -   mediagenrerequests insert_media_genre_trigger    TRIGGER     �   CREATE TRIGGER insert_media_genre_trigger AFTER INSERT ON public.mediagenrerequests FOR EACH ROW EXECUTE FUNCTION public.insert_media_genre();
 F   DROP TRIGGER insert_media_genre_trigger ON public.mediagenrerequests;
       public          mori    false    252    219            8           2620    18575 (   mediacontent media_status_update_trigger    TRIGGER     �   CREATE TRIGGER media_status_update_trigger BEFORE INSERT OR UPDATE ON public.mediacontent FOR EACH ROW EXECUTE FUNCTION public.update_media_status_on_end();
 A   DROP TRIGGER media_status_update_trigger ON public.mediacontent;
       public          mori    false    256    208            :           2620    18576    mediacast mediacast_log_trigger    TRIGGER     �   CREATE TRIGGER mediacast_log_trigger AFTER INSERT OR DELETE OR UPDATE ON public.mediacast FOR EACH ROW EXECUTE FUNCTION public.log_changes();
 8   DROP TRIGGER mediacast_log_trigger ON public.mediacast;
       public          mori    false    254    214            9           2620    18577 %   mediacontent mediacontent_log_trigger    TRIGGER     �   CREATE TRIGGER mediacontent_log_trigger AFTER INSERT OR DELETE OR UPDATE ON public.mediacontent FOR EACH ROW EXECUTE FUNCTION public.log_changes();
 >   DROP TRIGGER mediacontent_log_trigger ON public.mediacontent;
       public          mori    false    254    208            =           2620    18578    persons persons_log_trigger    TRIGGER     �   CREATE TRIGGER persons_log_trigger AFTER INSERT OR DELETE OR UPDATE ON public.persons FOR EACH ROW EXECUTE FUNCTION public.log_changes();
 4   DROP TRIGGER persons_log_trigger ON public.persons;
       public          mori    false    254    225            ?           2620    18579    ratings ratings_log_trigger    TRIGGER     �   CREATE TRIGGER ratings_log_trigger AFTER INSERT OR DELETE OR UPDATE ON public.ratings FOR EACH ROW EXECUTE FUNCTION public.log_changes();
 4   DROP TRIGGER ratings_log_trigger ON public.ratings;
       public          mori    false    254    229            A           2620    18580    reviews reviews_log_trigger    TRIGGER     �   CREATE TRIGGER reviews_log_trigger AFTER INSERT OR DELETE OR UPDATE ON public.reviews FOR EACH ROW EXECUTE FUNCTION public.log_changes();
 4   DROP TRIGGER reviews_log_trigger ON public.reviews;
       public          mori    false    254    231            >           2620    18581 '   persons trigger_insert_or_update_person    TRIGGER     �   CREATE TRIGGER trigger_insert_or_update_person BEFORE INSERT ON public.persons FOR EACH ROW EXECUTE FUNCTION public.insert_or_update_person();
 @   DROP TRIGGER trigger_insert_or_update_person ON public.persons;
       public          mori    false    225    253            @           2620    18582 !   ratings update_avg_rating_trigger    TRIGGER     �   CREATE TRIGGER update_avg_rating_trigger AFTER INSERT OR DELETE OR UPDATE ON public.ratings FOR EACH ROW EXECUTE FUNCTION public.update_media_avg_rating();
 :   DROP TRIGGER update_avg_rating_trigger ON public.ratings;
       public          mori    false    255    229            B           2620    18583 '   usermedialist usermedialist_log_trigger    TRIGGER     �   CREATE TRIGGER usermedialist_log_trigger AFTER INSERT OR DELETE OR UPDATE ON public.usermedialist FOR EACH ROW EXECUTE FUNCTION public.log_changes();
 @   DROP TRIGGER usermedialist_log_trigger ON public.usermedialist;
       public          mori    false    233    254            C           2620    18584 /   userrelationships userrelationships_log_trigger    TRIGGER     �   CREATE TRIGGER userrelationships_log_trigger AFTER INSERT OR DELETE OR UPDATE ON public.userrelationships FOR EACH ROW EXECUTE FUNCTION public.log_changes();
 H   DROP TRIGGER userrelationships_log_trigger ON public.userrelationships;
       public          mori    false    254    235            D           2620    18585    users users_log_trigger    TRIGGER     �   CREATE TRIGGER users_log_trigger AFTER INSERT OR DELETE OR UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.log_changes();
 0   DROP TRIGGER users_log_trigger ON public.users;
       public          mori    false    254    237            &           2606    18586 %   mediacast mediacast_character_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.mediacast
    ADD CONSTRAINT mediacast_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.characterslist(id) ON DELETE CASCADE;
 O   ALTER TABLE ONLY public.mediacast DROP CONSTRAINT mediacast_character_id_fkey;
       public          mori    false    202    214    3059            '           2606    18591 *   mediacast mediacast_character_role_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.mediacast
    ADD CONSTRAINT mediacast_character_role_id_fkey FOREIGN KEY (character_role_id) REFERENCES public.charactersroles(id) ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.mediacast DROP CONSTRAINT mediacast_character_role_id_fkey;
       public          mori    false    214    3063    204            (           2606    18596 !   mediacast mediacast_media_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.mediacast
    ADD CONSTRAINT mediacast_media_id_fkey FOREIGN KEY (media_id) REFERENCES public.mediacontent(id) ON DELETE CASCADE;
 K   ALTER TABLE ONLY public.mediacast DROP CONSTRAINT mediacast_media_id_fkey;
       public          mori    false    214    3069    208            )           2606    18601 "   mediacast mediacast_person_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.mediacast
    ADD CONSTRAINT mediacast_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.persons(id) ON DELETE CASCADE;
 L   ALTER TABLE ONLY public.mediacast DROP CONSTRAINT mediacast_person_id_fkey;
       public          mori    false    214    3087    225            *           2606    18606 '   mediacast mediacast_person_role_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.mediacast
    ADD CONSTRAINT mediacast_person_role_id_fkey FOREIGN KEY (person_role_id) REFERENCES public.personsroles(id) ON DELETE CASCADE;
 Q   ALTER TABLE ONLY public.mediacast DROP CONSTRAINT mediacast_person_role_id_fkey;
       public          mori    false    214    3091    227            +           2606    18611 %   mediagenres mediagenres_genre_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.mediagenres
    ADD CONSTRAINT mediagenres_genre_id_fkey FOREIGN KEY (genre_id) REFERENCES public.genres(id) ON DELETE CASCADE;
 O   ALTER TABLE ONLY public.mediagenres DROP CONSTRAINT mediagenres_genre_id_fkey;
       public          mori    false    3067    221    206            ,           2606    18616 %   mediagenres mediagenres_media_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.mediagenres
    ADD CONSTRAINT mediagenres_media_id_fkey FOREIGN KEY (media_id) REFERENCES public.mediacontent(id) ON DELETE CASCADE;
 O   ALTER TABLE ONLY public.mediagenres DROP CONSTRAINT mediagenres_media_id_fkey;
       public          mori    false    208    3069    221            -           2606    18621 9   mediarelationships mediarelationships_media_id_first_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.mediarelationships
    ADD CONSTRAINT mediarelationships_media_id_first_fkey FOREIGN KEY (media_id_first) REFERENCES public.mediacontent(id) ON DELETE CASCADE;
 c   ALTER TABLE ONLY public.mediarelationships DROP CONSTRAINT mediarelationships_media_id_first_fkey;
       public          mori    false    223    208    3069            .           2606    18626 :   mediarelationships mediarelationships_media_id_second_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.mediarelationships
    ADD CONSTRAINT mediarelationships_media_id_second_fkey FOREIGN KEY (media_id_second) REFERENCES public.mediacontent(id) ON DELETE CASCADE;
 d   ALTER TABLE ONLY public.mediarelationships DROP CONSTRAINT mediarelationships_media_id_second_fkey;
       public          mori    false    223    208    3069            /           2606    18631    ratings ratings_media_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT ratings_media_id_fkey FOREIGN KEY (media_id) REFERENCES public.mediacontent(id) ON DELETE CASCADE;
 G   ALTER TABLE ONLY public.ratings DROP CONSTRAINT ratings_media_id_fkey;
       public          mori    false    3069    229    208            0           2606    18636    ratings ratings_user_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT ratings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;
 F   ALTER TABLE ONLY public.ratings DROP CONSTRAINT ratings_user_id_fkey;
       public          mori    false    229    3107    237            1           2606    18641    reviews reviews_media_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_media_id_fkey FOREIGN KEY (media_id) REFERENCES public.mediacontent(id) ON DELETE CASCADE;
 G   ALTER TABLE ONLY public.reviews DROP CONSTRAINT reviews_media_id_fkey;
       public          mori    false    3069    208    231            2           2606    18646    reviews reviews_user_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;
 F   ALTER TABLE ONLY public.reviews DROP CONSTRAINT reviews_user_id_fkey;
       public          mori    false    237    3107    231            3           2606    18651 )   usermedialist usermedialist_media_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.usermedialist
    ADD CONSTRAINT usermedialist_media_id_fkey FOREIGN KEY (media_id) REFERENCES public.mediacontent(id) ON DELETE CASCADE;
 S   ALTER TABLE ONLY public.usermedialist DROP CONSTRAINT usermedialist_media_id_fkey;
       public          mori    false    208    3069    233            4           2606    18656 (   usermedialist usermedialist_user_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.usermedialist
    ADD CONSTRAINT usermedialist_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;
 R   ALTER TABLE ONLY public.usermedialist DROP CONSTRAINT usermedialist_user_id_fkey;
       public          mori    false    3107    237    233            5           2606    18661 6   userrelationships userrelationships_user_id_first_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.userrelationships
    ADD CONSTRAINT userrelationships_user_id_first_fkey FOREIGN KEY (user_id_first) REFERENCES public.users(id) ON DELETE CASCADE;
 `   ALTER TABLE ONLY public.userrelationships DROP CONSTRAINT userrelationships_user_id_first_fkey;
       public          mori    false    237    3107    235            6           2606    18666 7   userrelationships userrelationships_user_id_second_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.userrelationships
    ADD CONSTRAINT userrelationships_user_id_second_fkey FOREIGN KEY (user_id_second) REFERENCES public.users(id) ON DELETE CASCADE;
 a   ALTER TABLE ONLY public.userrelationships DROP CONSTRAINT userrelationships_user_id_second_fkey;
       public          mori    false    237    3107    235            �      x��]�r�6��->�*U�E���9��Kl�D��I�*4�f(q�Y^4om�y�}�}�� G�\��F��3IU�pHt�׍F4�^��,�{����o�{�܏���/�~&ݗ���������G����	7�b$�<��L~|�wLl��|?e���p��P"�b(�+��a��Y��8��k�X�9�� ۈX=�﹖I/\�4�M���Q\�E�G"��7|�3��y{oܱ�H���qE��1��⢖�#��B�G�h��g 	T�6���Ĳ��XT�®!�w=DM���R��~��X��#4�2a��C�L�J���|?�	g9��P��
������}Q����I"��9@|�Ka@�g8:��O)G�Ƽ�Q�@ĵ�s��[�.�\� �8�y�rβ��F�"CE��o�A �$�=�Ė����ai�a9b�-`�a���L��>��(f]!����+� �,0kh�n�Dh2�Gc.��!��(/�<�	���b�@��	a۵ �i�t ;Zc�C���F�u�����5ty��L ��":�?X>E#q_򙈦����@H��Wm�V������bz���H�K�$�ϖ�B�	���WpL��!�  �:�~�����`���� ��F�X���,�~�@�1�a�i1~W^�E^��,�y��Ӛ���V==�Kf�N�b�r���+d9:�CI��,�*@��^��@����D��2F�@��"N{�t���8)O�u����X$h�Ngؓ����|�ޱ1Ky���e�<yq�Ƣϒ�X:��akT@.Y�<<�
�����[��o R��mP����o`�,��a��ژ#tG\l�$��Z�C�Xi0���A��&|��.D�Z
ôtz��=�T\��A�!7���H.�(���ϕ[ND��:\�w	$0���9���� �t�%�q���lv��UX���4��u��CgL�-���,��5`q��9X5��	��+������-_eg��P�Fe^�7������@�SO��?�k�ރ�2p|0�$q�4���K�s8��[9b��C擁E]���'s�O`vq��g�q�:h�z���"��Stl�_����:�{z���WO���匇R����9ʧ"+��`);��M���9ڿM�t��ę��B<���-b���{�sԉv�&�pu�ڰxr���q��Y77�r�͞�t=�a!��8�zY�ߩ~o������-'�FÛ�fo��ۇ���=��F�ꖚ�o��0��B��T6��N8[ɛ�xg�p	�V
�9 �%q1m���,���%^�^#���y���]ȉ�ۜM��m�;��*^���~������)�g/j�_�i�V���B}� �1_������_~��d�ڻc���X�Y�C{�R{΢��%���[��-������}	�y���?S2�è`�4x��W��4x����u�/�
a_$Hz��#��x�M%�8�.�C��笪�_��Tc�|��4�۰�l�(�-B,A�B�J�(4s��S	���Mw�UB�/B���#oKo�Xz7X~�����)�HH||��a����]O���ǁ�U�#���^�y�z���/�M$QW>A�
���mװ�60������b�1���#A��HO�1m���}�!�v�"O	�M�z��6@���a��L�֩�G�y��dG�-�X$��8�]Bа1��}���l?_�,x�^�h��}��Y8v����g�Қ���>��L�T���f�������[apd������w��ۋ�>��}@ʸb��Nzt&n+}��ҡb��u�^k��C]����C��n�ת/�A�
�w��tW�>mm�O�������Ʈ����?���ᶍ�}m��պClņ���n{��5��� ��؍�7w�$՛�N�.������M��Gb����g^��Ŏ�ɲ�hϡ&<�mc���Y�����+�cӦ.�@O���O���������l��ݎ�.a��Zj�ۆ�����KO���sX��ݭ�ֿ��>���{��9iZ��,�V���-�*�@�PL^ 6bߪ�yZ�} �WŴ|	�	�xt�X;�e�`��TK�Տ��)�&�����j,gד���ǈ�D���n# s����0��ˇ�X���<��b�Y����
u�Px�-�!^�7T�j��N6H��� 6}P��'��V��u�J�C!�gi鵊��-KOpySM���F;���Y&��K��>�s�ȸJsU̚f@]�1<��ط���ô�Q8������Aږc�Mf盞�J��=��Nmm"��XP�.����<�-�5<�9�aj���P.4���_2��+nI6��K��(���}zpK�%�mF��ȅ�4^s�K����%P>��Im��l��w�بM:�q�"����!��0�)Ʉ�o��|��o7��8�Q����ox�3ߛ.�Q[�EM'��訍{��7z� nw���:X)]9��r'}���y��� ,�4	��iW$�l�<�Zw���*���$S��dV�T�sL*:���~�![�����kr���m�ݴ�3��)קԥ���/�=������wtF`�"�x��~ɶU4�Y8�S�T��ٻ=�3�q�h�ۦ�ﭰTsw��o����'�6_��v��i8J!�(MՓ��(��h���yԽU�.�XF�N�Ӫ�W	�&V)���kl8������Tkt���m�w۠��5.f��f�Ѭ����-���¡��u�|[�hx��7hK
a\Sh{}���ځBL�]�oU��	�d�xI%L+*�԰��=��N �noW���"ҊF8���M[W�B�
P��b�
A�Q�(�ӊB75lY�f%�'0��*�yڪsʐ�¼&�M[Z�B����g���sn���a$uBon����܁bPr7������9���E�)�v�7�Je鶮F_R�6��{��k�t*RlV`Ǡ+��[N�Ͼ�^�����ȴ���.&])�6�m[5�V�Q�I���B#�ës+d�@djЕ�w���w���̱��
=�'�^�Z!�O}bt�@v��y�2�"��)������E�7 �����]*��ʛ�_�����.��,1��ϦF�/������ta8���X��i4��������W������m����4z[M�?���7��]JO���}������O�����x�괯k ���	��v́*Lf���w��w@�5�F��`���P��E��<N�1�o2���!+P���2N供�Hy��UͲ�����}{��C�s�� c�U��j1~$G�`	:J�C>���C/3Qy6l��&��oLJw>Nr:�fEn��UF��a��\����� �Q!s/2!��+q&7U�L���Z�=4��Z�i��H��7	wX9���$aS�>�%sDAS��!{����q�*s(���+�$�슧�!G�l'Su�JN��.Y�gi�n`9��wZZtO
���~f�p"Kpq�)w�'2Q�e��>���(���Jb+WN��M���C�4��wm#X���X�{�;�el�l[���������|;�5���PǕS��\C;׀}@UfJ�hB{���?����R�4��7�ei��.B{���Z���
�V���!���1-��X�K��x7�u� d�(�T�lkA޹�v���,��I@隝�u�&�8P,������.hf��頸��+�_������2�s4�>����1=�;���[_�_^z��-���@�����A.W[��]0��
#KU�Vʋ A70��������6���R\���B��-_{3њ��T��Ęb� M����**KD��Se[j�U�L��ti�-�^��KH�� �QB������Z��"=�6-��ս\�����8�'=%v���om(R�����aw�"^3���۲2��Mס�{�Mf�	b�t�,{�7��%	T�}�%�4Zy.�h�}�D��ls��n@����!�,n|G��p�qP^��u�#��="��y���,�K�e� �   ��MMϡX�D_J/���M��n&�䎢ы�~s(�D��P�z���P��i��LO�|���ӯ
S=*s'p?��^%Wybү_�qt��3���_�������Ʉ�|{�޿qo�T�������5Y���mz �����x4(B�]�s�rTl5�aNỸ2T���*\�����m�H�I�D�1�%�NIl}�w]��_�0���AT      �   �   x�m�MN�0FדS�	- ���B���!�$Ɖ]9P8=�b������w�ȩaG�)b4u�P�<���bu;�6���1`)TC:�_礬`�-g�.�EY�'���uoz̨�p�g�G���<��Mp"h^�n��;K�z*Վ�v�d����E��1l�zu�G��C�WC�{8���#:��L�?W.���l�G��?墰�A���(�?�	�p      �   &   x�3��M��Sp�H,JL.I-�2��LIE����� ��      �   `   x���
@P��|��K%Y���t�P�h\�ۻ�S'�ƅ]5��%<�S���PPk|2J��mz�;>P��\ބ㏬iԓ�y��j��9��8s      �   E   x����0���T�<h����@�,���?V'�/��Np���*�ZM^FJ$/�|YEQە��~$<�      �   T  x����N�@F������*ܩğ� j4��@ǥ;ɶ��O�Vф;�l��nv�w��CB�W
��:i��>~�������eN�Ҋ�Q<���n�q4�N'��7��g�a'�{�� �2�������+�d�TR��Rs��k��p�ۺe �\쎍�U���M�W9�X�㒩T{pCoa�ےj*�}���������C�:ک�����ϭ$���'}�]��-�F�>
}��f윪җ���3��0yIYs�\
��u������FՄz�=��,C����R��e�- ��|CB�3�����%;�V�P7�&|vd�������8-��ֽN��ȴӻ      �   /  x�e�Qn�8���S�dKr[}ˢ�]$�[��.�( �%Z�-q���>��^O�!�8�`�"���?L�M�H<BKmW�Ԫ��[�h�h�b=�a]�q�FI�KQP�����/�"^����F�i,֡S�"Z�1?����⣖�I�B�G=Qk�A'-X���+]��8#�vF�E62$Y�y�!]o���$q|+MZ����W�l�?��Լv�����N�fKe�3�-��.4J&\=�Cϒ�fɁ�^�7X��?���?�*H3Ƶѱ���,OR;6����@�ћ�,��D�%�2	-�n�ʀ�o!�>p��o�<*��=�~/{	*�5|�>�f�ju�NqOآ�V��?�7�<e�G�u�T`ݷ��3���v2���S��8�&�(͂�7�v$�5��@����w0�p(�A<u����QY�m�J����b������)����NU{�sWt�J�}6O&�!��̥w7��A7?݁f->�!.~��N�u�p�-�JI[��J���뱟�&�ߚ���pda�$�W�LlȜe�PÿD�5����a���<���l�52��:�&�[����O݄�x^i���~���x|�ˇ7��b�����R��z����%�������z��,��8�����SN	�N'��h�n�G�'0�Du�㬾�n�ˮv������:>�ƴ��p)���������7	q��p&饌���GV{�Ƀ!K�� �c��lrA����
���[h%�,�"�ҙ��)W��y�+zu��}���>�R�����m>��~߈�      �   �   x����N�0Dϛ���J���ފ*T�UAB .��JMc/Z�E�{�D��y�4SA��"z�6&Z��K��*=�j��u�\/������)4<zR{K�.Lw&�P��aT;V�9����O�����+h������{��d��
����z���+�K�)������-��ȃK8X�'p|�;a�寡e��ޢW/�|0�`Fs�{k���H�)'���
�8����;�a~�E���'      �   7   x�ȱ�0����^����:��l��6����$������[�P�H}���b�      �      x������ � �      �     x����j�0���S�R���^���M�`Pj*I�D�{�%����A���}���H�=��ȹY^�<xզ��5�Ɣ�Z]yI6� ��+ZOc���W�Ü�K.��$�UiI�̠�d��d�b��<� F:I��������PwmE�ᠷ���p���dg��K�bU+���F��0�pM�8����\��ᶈR^}k��� *�'�ʒ���9^�5�~���[��?�~Ō �2��N����U�����l����y��WI�| `}��      �   2   x�3��IMLQpL.�/�2�t�,J3�9��3�S�����%@F� �-      �   5   x���  �7cy������ij�U��r��x�o��[l?�4�      �   z   x�u�1�0 ��f�Q���`1�4�H��@%^OŎN��CC��*:�{ ?�ø��H�{sV�5��8�'�	�i�kR�n,���g
�����R�%�Y�|}��ʡ�Vg/�Z���(      �   _   x�U��
� Dϻ��ٿ%�v����Ɯޛa�y�{�G��җ��WIw�8���X�E��SO��E��j1�@�:�V�G��G�SS��/�,�      �      x�3�4�4�L+�L�K�22a�=... q�      �   2  x�u�Os�0���sx����uhG���K$1��!�oE=8�^����{��5�$�����C�*��r*T�-� 8�]F-��RC�DE�K�*�������c ��[ a��Wu{��s?�� ��4��,ߧ�p<I�3���S"���7�҉tv�\)\[�ڿE>�rD=r0�.�#��X�+�pLe�֌�g���MT�c��6��i��@�-����2K��~��(<�I"7�^�(Oգ�͆Ӣ��钓{o{�g���4�_P��mkNBc�V3F�Q��*dO��5M��ӕ�     