-- Вставка пользователей
INSERT INTO Users (username, email, password, role)
VALUES
  ('user1', 'user1@example.com', 'password123', 'user'),
  ('moderator1', 'mod1@example.com', 'password123', 'editor');

-- Вставка медиа (аниме, манга, японские фильмы, японские сериалы)
INSERT INTO MediaContent (title, description, avg_rating, type, release_date, status, end_date, chapter_count, episode_count)
VALUES
  ('Naruto', 'A popular anime about ninjas.', 8.5, 'anime', '2002-10-03', 'completed', '2007-02-08', NULL, 220),
  ('One Piece', 'An anime about pirates searching for treasure.', 9.0, 'anime', '1999-10-20', 'ongoing', NULL, NULL, 1000),
  ('My Hero Academia', 'A manga series about a world where people have superpowers.', 8.7, 'manga', '2014-07-07', 'ongoing', NULL, 350, NULL),
  ('Your Name', 'A romantic fantasy movie about body-swapping.', 8.8, 'anime', '2016-08-26', 'completed', '2016-08-26', NULL, 1),
  ('Dragon Ball Z', 'An iconic anime about Goku’s adventures and training.', 9.2, 'anime', '1989-04-26', 'completed', '1996-01-31', NULL, 291),
  ('Jujutsu Kaisen', 'A supernatural anime with sorcerers fighting curses.', 9.1, 'anime', '2020-10-03', 'ongoing', NULL, NULL, 24),
  ('Shingeki no Kyojin: The Final Season', 'A live-action Japanese TV series about a post-apocalyptic world.', 8.4, 'anime', '2020-12-07', 'ongoing', '2021-03-29', NULL, 16),
  ('Ringu', 'A Japanese horror movie about a cursed videotape.', 8.0, 'movie', '1998-01-31', 'completed', '1998-01-31', NULL, 1),
  ('Norwegian Wood', 'A Japanese novel by Haruki Murakami about love and loss.', 8.6, 'book', '1987-09-04', 'completed', '1987-09-04', 1, NULL),
  ('The Naked Director', 'A Japanese drama based on the true story of a man who revolutionized the adult film industry in Japan.', 8.3, 'series', '2019-08-08', 'completed', '2020-08-28', NULL, 12);

-- Вставка жанров
INSERT INTO Genres (name)
VALUES
  ('Action'),
  ('Adventure'),
  ('Fantasy'),
  ('Drama'),
  ('Psychological');

-- Вставка связей между медиа и жанрами
INSERT INTO MediaGenreRequests (media_title, media_type, genre_name)
VALUES
  ('Naruto', 'anime', 'Action'),
  ('One Piece', 'anime', 'Adventure'),
  ('My Hero Academia', 'manga', 'Supernatural'),
  ('Your Name', 'anime', 'Romance'),
  ('Dragon Ball Z', 'anime', 'Action'),
  ('Jujutsu Kaisen', 'anime', 'Fantasy'),
  ('Ringu', 'movie', 'Horror'),
  ('Norwegian Wood', 'book', 'Psychological'),
  ('The Naked Director', 'series', 'Drama');

-- Вставка ролей и персонажей
INSERT INTO PersonsRoles (name)
VALUES
  ('Lead Actor'),
  ('Director'),
  ('Voice Actor');

INSERT INTO CharactersRoles (name)
VALUES
  ('Main Character'),
  ('Side Character');

INSERT INTO CharactersList (name)
VALUES
  ('Naruto Uzumaki'),
  ('Sasuke Uchiha'),
  ('Monkey D. Luffy'),
  ('Eren Yeager'),
  ('Toru Watanabe'),  -- персонаж из "Norwegian Wood"
  ('Ryuichi Hirose'),  -- персонаж из "The Naked Director"
  ('Sadako Yamamura');

-- Вставка кастинга медиа (с японскими актерами и актерами озвучки)
INSERT INTO MediaCastRequests (media_title, media_type, person_name, person_role_name, character_name, character_role_name)
VALUES
  ('Naruto', 'manga', NULL, NULL, 'Naruto Uzumaki', 'Main Character'),
  ('One Piece', 'anime', 'Mayumi Tanaka', 'Voice Actor', 'Monkey D. Luffy', 'Main Character'),
  ('Shingeki no Kyojin: The Final Season', 'anime', 'Hajime Isayama', 'Author', 'Levi', 'Side Character'),
  ('Dragon Ball Z', 'anime', 'Masako Nozawa', 'Voice Actor', 'Goku', 'Main Character'),
  ('Ringu', 'movie', 'Nanako Matsushima', 'Lead Actor', 'Sadako Yamamura', 'Main Character'),
  ('Norwegian Wood', 'book', 'Haruki Murakami', 'Author', 'Toru Watanabe', 'Main Character'),
  ('The Naked Director', 'series', 'Takayuki Yamada', 'Lead Actor', 'Ryuichi Hirose', 'Main Character');

-- Вставка японских актеров
INSERT INTO Persons (name, birth_date, nationality, main_role)
VALUES
  ('Masako Nozawa', '1936-10-25', 'Japanese', 'Voice Actor'),
  ('Hajime Isayama', '1986-08-29', 'Japanese', 'Author'),
  ('Nanako Matsushima', '1973-10-08', 'Japanese', 'Actor'),
  ('Takahiro Sakurai', '1974-06-13', 'Japanese', 'Voice Actor'),
  ('Takayuki Yamada', '1983-07-20', 'Japanese', 'Actor');


-- Вставка рейтингов
INSERT INTO Ratings (user_id, media_id, score)
VALUES
  ((SELECT id FROM Users WHERE username = 'user1'), (SELECT id FROM MediaContent WHERE title = 'Naruto' and type = 'manga'), 8),
  ((SELECT id FROM Users WHERE username = 'user1'), (SELECT id FROM MediaContent WHERE title = 'One Piece'), 9),
  ((SELECT id FROM Users WHERE username = 'moderator1'), (SELECT id FROM MediaContent WHERE title = 'Your Name'), 8),
  ((SELECT id FROM Users WHERE username = 'user1'), (SELECT id FROM MediaContent WHERE title = 'Dragon Ball Z'), 9),
  ((SELECT id FROM Users WHERE username = 'user1'), (SELECT id FROM MediaContent WHERE title = 'Shingeki no Kyojin: The Final Season'), 8),
  ((SELECT id FROM Users WHERE username = 'moderator1'), (SELECT id FROM MediaContent WHERE title = 'Ringu'), 7),
  ((SELECT id FROM Users WHERE username = 'user1'), (SELECT id FROM MediaContent WHERE title = 'Norwegian Wood'), 9);

-- Вставка обзоров
INSERT INTO Reviews (media_id, user_id, review_text)
VALUES
  ((SELECT id FROM MediaContent WHERE title = 'Naruto' and type = 'manga'), (SELECT id FROM Users WHERE username = 'user1'), 'Great show, amazing fight scenes!'),
  ((SELECT id FROM MediaContent WHERE title = 'One Piece'), (SELECT id FROM Users WHERE username = 'moderator1'), 'Epic adventure with memorable characters.');

-- Вставка связей пользователей
INSERT INTO UserRelationships (user_id_first, user_id_second, relationship_type)
VALUES
  ((SELECT id FROM Users WHERE username = 'user1'), (SELECT id FROM Users WHERE username = 'moderator1'), 'friend'),
  ((SELECT id FROM Users WHERE username = 'moderator1'), (SELECT id FROM Users WHERE username = 'user1'), 'friend');

-- Вставка в пользовательские списки
INSERT INTO UserMediaList (user_id, media_id, status)
VALUES
  ((SELECT id FROM Users WHERE username = 'user1'), (SELECT id FROM MediaContent WHERE title = 'Naruto' and type = 'anime'), 'watching'),
  ((SELECT id FROM Users WHERE username = 'moderator1'), (SELECT id FROM MediaContent WHERE title = 'One Piece'), 'completed');
