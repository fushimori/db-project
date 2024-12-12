import React, { useEffect, useState } from 'react';
import { getAnime } from '../api/media'; // Функция получения данных из API
import MediaItem from './MediaItem';
import { useAuth } from '../context/AuthContext';

const AnimePage = () => {
  const [animeList, setAnimeList] = useState([]);
  const { isLoggedIn } = useAuth();

  useEffect(() => {
    console.log('Fetching anime...');
    const fetchAnime = async () => {
      try {
        const data = await getAnime();
        console.log('Anime data received:', data);  // Выводим полученные данные
        setAnimeList(data.anime); // Обновляем состояние
      } catch (error) {
        console.error("Error fetching anime data:", error);
      }
    };
    fetchAnime();
  }, []);  // Убедитесь, что массив зависимостей пустой
  
  return (
    <div>
      <h2>Anime</h2>
      <div className="media-list">
        {animeList.length > 0 ? (
          animeList.map((anime) => (
            <div key={anime.id}> {/* Убедитесь, что ключ уникален */}
              <MediaItem media={anime} status={isLoggedIn ? anime.status : null} />
            </div>
          ))
        ) : (
          <p>No anime available</p>  // Сообщение, если аниме нет
        )}
      </div>
    </div>
  );
};

export default AnimePage;
