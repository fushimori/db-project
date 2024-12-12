import React, { useEffect, useState } from 'react';
import { getSeries } from '../api/media'; // Функция получения данных из API
import MediaItem from './MediaItem';
import { useAuth } from '../context/AuthContext';

const SeriesPage = () => {
  const [seriesList, setSeriesList] = useState([]);
  const { isLoggedIn } = useAuth();

  useEffect(() => {
    console.log('Fetching series...');
    const fetchSeries = async () => {
      try {
        const data = await getSeries();
        console.log('Series data received:', data);  // Выводим полученные данные
        setSeriesList(data.series); // Обновляем состояние
      } catch (error) {
        console.error("Error fetching series data:", error);
      }
    };
    fetchSeries();
  }, []);  // Убедитесь, что массив зависимостей пустой
  
  return (
    <div>
      <h2>Series</h2>
      <div className="media-list">
        {seriesList.length > 0 ? (
          seriesList.map((series) => (
            <div key={series.id}> {/* Убедитесь, что ключ уникален */}
              <MediaItem media={series} status={isLoggedIn ? series.status : null} />
            </div>
          ))
        ) : (
          <p>No series available</p>  // Сообщение, если аниме нет
        )}
      </div>
    </div>
  );
};

export default SeriesPage;
