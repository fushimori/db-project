import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { getAnimeDetails } from '../api/media'; // Импортируем API-функцию

const AnimeDetails = () => {
  const { animeId } = useParams(); // Получаем animeId из URL
  const [animeDetails, setAnimeDetails] = useState(null);

  useEffect(() => {
    const fetchAnimeDetails = async () => {
      try {
        const data = await getAnimeDetails(animeId); // Используем API-функцию
        setAnimeDetails(data.anime_details); // Обновляем состояние
      } catch (error) {
        console.error("Error fetching anime details:", error);
      }
    };

    fetchAnimeDetails();
  }, [animeId]);

  if (!animeDetails) {
    return <div>Loading...</div>;
  }

  return (
    <div className="anime-details">
      <img src={`http://localhost:8000${animeDetails.photo_path}`} alt={animeDetails.title} />
      <h1>{animeDetails.title}</h1>
      <p>{animeDetails.description}</p>
      <p>Release Date: {animeDetails.release_date}</p>
      {animeDetails.end_date && <p>End date: {animeDetails.end_date}</p>}
      <p>Type: {animeDetails.type}</p>
      {animeDetails.chapter_count && <p>Chapter Count: {animeDetails.chapter_count}</p>}
      {animeDetails.episode_count && <p>Episode Count: {animeDetails.episode_count}</p> }
      <p>Average Rating: {animeDetails.avg_rating}</p>
      {animeDetails.user_status && <p>Your Status: {animeDetails.user_status}</p>}

      {/* Отображение оценки пользователя */}
      {animeDetails.user_rating && (
        <p>Your Rating: {animeDetails.user_rating}</p>
      )}

      {/* Отображение отзыва пользователя */}
      {animeDetails.user_review && (
        <div>
          <h3>Your Review:</h3>
          <p>{animeDetails.user_review}</p>
        </div>
      )}
    </div>
  );
};

export default AnimeDetails;