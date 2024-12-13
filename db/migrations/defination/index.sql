-- db/migrations/defination/index.sql
CREATE UNIQUE INDEX unique_media_title_type_index ON MediaContent (title, type);
CREATE UNIQUE INDEX unique_media_user_relationship_index ON UserMediaList (user_id, media_id);
CREATE UNIQUE INDEX unique_rating_index ON Ratings (user_id, media_id);
CREATE UNIQUE INDEX unique_review_index ON Reviews (user_id, media_id, review_text);
CREATE UNIQUE INDEX unique_media_cast_index ON MediaCast (media_id, person_id, character_id, person_role_id);
CREATE UNIQUE INDEX unique_media_relationship_index ON MediaRelationships (media_id_first, media_id_second, relationship_type);
CREATE UNIQUE INDEX unique_media_genre_index ON MediaGenres (media_id, genre_id);
CREATE UNIQUE INDEX unique_user_relationship_index ON UserRelationships (user_id_first, user_id_second, relationship_type);