-- Enums
CREATE TYPE media_type_enum AS ENUM ('anime', 'manga', 'book', 'movie', 'series');
CREATE TYPE media_status_enum AS ENUM ('ongoing', 'completed', 'hiatus', 'cancelled');
CREATE TYPE media_relationship_type_enum AS ENUM ('sequel', 'prequel', 'spin-off', 'adaptation', 'original');
CREATE TYPE user_role_enum AS ENUM ('admin', 'editor', 'user');
CREATE TYPE user_relationship_type_enum AS ENUM ('friend', 'block');
CREATE TYPE user_media_status_enum AS ENUM ('watching', 'completed', 'planned', 'on_hold', 'dropped');

-- Tables
CREATE TABLE PersonsRoles (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE CharactersRoles (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE CharactersList (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE Persons (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL,
  birth_date DATE,
  nationality VARCHAR(255),
  main_role VARCHAR(255)
);

CREATE TABLE MediaContent (
  id BIGSERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  avg_rating FLOAT CHECK (avg_rating >= 1 AND avg_rating <= 10),
  type media_type_enum NOT NULL,
  release_date DATE,
  status media_status_enum,
  end_date DATE,
  chapter_count BIGINT,
  episode_count BIGINT
);

CREATE TABLE MediaCast (
  id BIGSERIAL PRIMARY KEY,
  media_id BIGINT REFERENCES MediaContent(id) ON DELETE CASCADE,
  person_id BIGINT REFERENCES Persons(id) ON DELETE CASCADE,
  person_role_id BIGINT REFERENCES PersonsRoles(id) ON DELETE CASCADE,
  character_id BIGINT REFERENCES CharactersList(id) ON DELETE CASCADE,
  character_role_id BIGINT REFERENCES CharactersRoles(id) ON DELETE CASCADE
);

CREATE TABLE MediaRelationships (
  id BIGSERIAL PRIMARY KEY,
  media_id_first BIGINT REFERENCES MediaContent(id) ON DELETE CASCADE,
  media_id_second BIGINT REFERENCES MediaContent(id) ON DELETE CASCADE,
  relationship_type media_relationship_type_enum NOT NULL
);

CREATE TABLE Genres (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE MediaGenres (
  id BIGSERIAL PRIMARY KEY,
  media_id BIGINT REFERENCES MediaContent(id) ON DELETE CASCADE,
  genre_id BIGINT REFERENCES Genres(id) ON DELETE CASCADE
);

CREATE TABLE Users (
  id BIGSERIAL PRIMARY KEY,
  username VARCHAR(255) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role user_role_enum DEFAULT 'user'
);

CREATE TABLE UserRelationships (
  id BIGSERIAL PRIMARY KEY,
  user_id_first BIGINT REFERENCES Users(id) ON DELETE CASCADE,
  user_id_second BIGINT REFERENCES Users(id) ON DELETE CASCADE,
  relationship_type user_relationship_type_enum NOT NULL
);

CREATE TABLE UserMediaList (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT REFERENCES Users(id) ON DELETE CASCADE,
  media_id BIGINT REFERENCES MediaContent(id) ON DELETE CASCADE,
  status user_media_status_enum NOT NULL
);

CREATE TABLE Ratings (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT REFERENCES Users(id) ON DELETE CASCADE,
  media_id BIGINT REFERENCES MediaContent(id) ON DELETE CASCADE,
  score INT CHECK (score >= 1 AND score <= 10)
);

CREATE TABLE Reviews (
  id BIGSERIAL PRIMARY KEY,
  media_id BIGINT REFERENCES MediaContent(id) ON DELETE CASCADE,
  user_id BIGINT REFERENCES Users(id) ON DELETE CASCADE,
  creation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  review_text TEXT
);
