CREATE OR REPLACE FUNCTION update_media_status_on_end()
RETURNS TRIGGER AS $$
BEGIN
    -- Проверяем, если end_date есть и он прошел, то устанавливаем статус 'completed'
    IF (NEW.end_date IS NOT NULL AND NEW.end_date <= CURRENT_DATE AND NEW.status != 'completed') THEN
        NEW.status := 'completed';
    END IF;
    
    -- Вставляем или обновляем данные по статусу медиа
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER media_status_update_trigger
BEFORE INSERT OR UPDATE ON MediaContent
FOR EACH ROW
EXECUTE FUNCTION update_media_status_on_end();
