-- Процедура для добавления записей в таблицу usermedialist
CREATE OR REPLACE PROCEDURE add_user_media_list()
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