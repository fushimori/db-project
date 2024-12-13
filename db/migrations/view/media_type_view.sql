-- db/migrations/view/media_type_view.sql
-- Представление для типа 'anime'
CREATE OR REPLACE VIEW media_content_anime AS
SELECT * 
FROM MediaContent
WHERE type = 'anime';

-- Представление для типа 'manga'
CREATE OR REPLACE VIEW media_content_manga AS
SELECT * 
FROM MediaContent
WHERE type = 'manga';

-- Представление для типа 'book'
CREATE OR REPLACE VIEW media_content_book AS
SELECT * 
FROM MediaContent
WHERE type = 'book';

-- Представление для типа 'movie'
CREATE OR REPLACE VIEW media_content_movie AS
SELECT * 
FROM MediaContent
WHERE type = 'movie';

-- Представление для типа 'series'
CREATE OR REPLACE VIEW media_content_series AS
SELECT * 
FROM MediaContent
WHERE type = 'series';
