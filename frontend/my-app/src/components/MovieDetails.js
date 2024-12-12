import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { getMovieDetails } from '../api/media'; // Импортируем API-функцию

const MovieDetails = () => {
  const { movieId } = useParams(); // Получаем movieId из URL
  const [movieDetails, setMovieDetails] = useState(null);

  useEffect(() => {
    const fetchMovieDetails = async () => {
      try {
        const data = await getMovieDetails(movieId); // Используем API-функцию
        setMovieDetails(data.movie_details); // Обновляем состояние
      } catch (error) {
        console.error("Error fetching movie details:", error);
      }
    };

    fetchMovieDetails();
  }, [movieId]);

  if (!movieDetails) {
    return <div>Loading...</div>;
  }

  return (
    <div className="movie-details">
      <img src={`http://localhost:8000${movieDetails.photo_path}`} alt={movieDetails.title} />
      <h1>{movieDetails.title}</h1>
      <p>{movieDetails.description}</p>
      <p>Release Date: {movieDetails.release_date}</p>
      {movieDetails.end_date && <p>End date: {movieDetails.end_date}</p>}
      <p>Type: {movieDetails.type}</p>
      {movieDetails.chapter_count && <p>Chapter Count: {movieDetails.chapter_count}</p>}
      {movieDetails.episode_count && <p>Episode Count: {movieDetails.episode_count}</p> }
      <p>Average Rating: {movieDetails.avg_rating}</p>
      {movieDetails.user_status && <p>Your Status: {movieDetails.user_status}</p>}

      {/* Отображение оценки пользователя */}
      {movieDetails.user_rating && (
        <p>Your Rating: {movieDetails.user_rating}</p>
      )}

      {/* Отображение отзыва пользователя */}
      {movieDetails.user_review && (
        <div>
          <h3>Your Review:</h3>
          <p>{movieDetails.user_review}</p>
        </div>
      )}
    </div>
  );
};

export default MovieDetails;