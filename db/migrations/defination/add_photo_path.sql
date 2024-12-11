-- add_photo_path_columns.sql

-- Добавление новых полей в таблицы
ALTER TABLE Users ADD COLUMN photo_path VARCHAR(255) DEFAULT '/static/default.png';
ALTER TABLE Persons ADD COLUMN photo_path VARCHAR(255) DEFAULT '/static/default.png';
ALTER TABLE MediaContent ADD COLUMN photo_path VARCHAR(255) DEFAULT '/static/default.png';
ALTER TABLE CharactersList ADD COLUMN photo_path VARCHAR(255) DEFAULT '/static/default.png';
