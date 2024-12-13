-- Процедура для обновления путей к изображениям в таблицах
CREATE OR REPLACE PROCEDURE update_photo_paths()
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