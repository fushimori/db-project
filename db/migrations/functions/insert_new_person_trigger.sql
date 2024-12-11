CREATE OR REPLACE FUNCTION insert_or_update_person()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_insert_or_update_person
BEFORE INSERT ON Persons
FOR EACH ROW
EXECUTE FUNCTION insert_or_update_person();
