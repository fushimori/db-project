import React, { useEffect, useState } from 'react';
import { getManga } from '../api/media'; // Функция получения данных из API
import MediaItem from './MediaItem';
import { useAuth } from '../context/AuthContext';

const MangaPage = () => {
  const [mangaList, setMangaList] = useState([]);
  const { isLoggedIn } = useAuth();

  useEffect(() => {
    console.log('Fetching manga...');
    const fetchManga = async () => {
      try {
        const data = await getManga();
        console.log('Manga data received:', data);  // Выводим полученные данные
        setMangaList(data.manga); // Обновляем состояние
      } catch (error) {
        console.error("Error fetching manga data:", error);
      }
    };
    fetchManga();
  }, []);  // Убедитесь, что массив зависимостей пустой
  
  return (
    <div>
      <h2>Manga</h2>
      <div className="media-list">
        {mangaList.length > 0 ? (
          mangaList.map((manga) => (
            <div key={manga.id}> {/* Убедитесь, что ключ уникален */}
              <MediaItem media={manga} status={isLoggedIn ? manga.status : null} />
            </div>
          ))
        ) : (
          <p>No manga available</p>  // Сообщение, если аниме нет
        )}
      </div>
    </div>
  );
};

export default MangaPage;
