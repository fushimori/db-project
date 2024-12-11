CREATE TABLE ChangeLogs (
    id BIGSERIAL PRIMARY KEY, -- Уникальный идентификатор для каждого лога
    table_name VARCHAR(255) NOT NULL, -- Название таблицы, в которой произошло изменение
    operation VARCHAR(10) NOT NULL, -- Тип операции: INSERT, UPDATE, DELETE
    changed_data JSONB, -- Изменённые данные в формате JSON
    change_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Время изменения
);
CREATE OR REPLACE FUNCTION log_changes()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

CREATE TRIGGER Users_log_trigger
AFTER INSERT OR UPDATE OR DELETE ON Users
FOR EACH ROW
EXECUTE FUNCTION log_changes();

CREATE TRIGGER MediaContent_log_trigger
AFTER INSERT OR UPDATE OR DELETE ON MediaContent
FOR EACH ROW
EXECUTE FUNCTION log_changes();

CREATE TRIGGER MediaCast_log_trigger
AFTER INSERT OR UPDATE OR DELETE ON MediaCast
FOR EACH ROW
EXECUTE FUNCTION log_changes();

CREATE TRIGGER Ratings_log_trigger
AFTER INSERT OR UPDATE OR DELETE ON Ratings
FOR EACH ROW
EXECUTE FUNCTION log_changes();

CREATE TRIGGER Reviews_log_trigger
AFTER INSERT OR UPDATE OR DELETE ON Reviews
FOR EACH ROW
EXECUTE FUNCTION log_changes();

CREATE TRIGGER UserMediaList_log_trigger
AFTER INSERT OR UPDATE OR DELETE ON UserMediaList
FOR EACH ROW
EXECUTE FUNCTION log_changes();

CREATE TRIGGER UserRelationships_log_trigger
AFTER INSERT OR UPDATE OR DELETE ON UserRelationships
FOR EACH ROW
EXECUTE FUNCTION log_changes();

CREATE TRIGGER Persons_log_trigger
AFTER INSERT OR UPDATE OR DELETE ON Persons
FOR EACH ROW
EXECUTE FUNCTION log_changes();

CREATE TRIGGER Characters_log_trigger
AFTER INSERT OR UPDATE OR DELETE ON CharactersList
FOR EACH ROW
EXECUTE FUNCTION log_changes();