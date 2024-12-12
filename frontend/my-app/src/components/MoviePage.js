import React, { useEffect, useState } from 'react';
import { getMovie } from '../api/media'; // Функция получения данных из API
import MediaItem from './MediaItem';
import { useAuth } from '../context/AuthContext';

const MoviePage = () => {
  const [movieList, setMovieList] = useState([]);
  const { isLoggedIn } = useAuth();

  useEffect(() => {
    console.log('Fetching movie...');
    const fetchMovie = async () => {
      try {
        const data = await getMovie();
        console.log('Movie data received:', data);  // Выводим полученные данные
        setMovieList(data.movie); // Обновляем состояние
      } catch (error) {
        console.error("Error fetching movie data:", error);
      }
    };
    fetchMovie();
  }, []);  // Убедитесь, что массив зависимостей пустой
  
  return (
    <div>
      <h2>Movie</h2>
      <div className="media-list">
        {movieList.length > 0 ? (
          movieList.map((movie) => (
            <div key={movie.id}> {/* Убедитесь, что ключ уникален */}
              <MediaItem media={movie} status={isLoggedIn ? movie.status : null} />
            </div>
          ))
        ) : (
          <p>No movie available</p>  // Сообщение, если аниме нет
        )}
      </div>
    </div>
  );
};

export default MoviePage;
