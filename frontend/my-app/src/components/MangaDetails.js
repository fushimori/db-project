import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { getMangaDetails } from '../api/media'; // Импортируем API-функцию

const MangaDetails = () => {
  const { mangaId } = useParams(); // Получаем mangaId из URL
  const [mangaDetails, setMangaDetails] = useState(null);

  useEffect(() => {
    const fetchMangaDetails = async () => {
      try {
        const data = await getMangaDetails(mangaId); // Используем API-функцию
        setMangaDetails(data.manga_details); // Обновляем состояние
      } catch (error) {
        console.error("Error fetching manga details:", error);
      }
    };

    fetchMangaDetails();
  }, [mangaId]);

  if (!mangaDetails) {
    return <div>Loading...</div>;
  }

  return (
    <div className="manga-details">
      <img src={`http://localhost:8000${mangaDetails.photo_path}`} alt={mangaDetails.title} />
      <h1>{mangaDetails.title}</h1>
      <p>{mangaDetails.description}</p>
      <p>Release Date: {mangaDetails.release_date}</p>
      {mangaDetails.end_date && <p>End date: {mangaDetails.end_date}</p>}
      <p>Type: {mangaDetails.type}</p>
      {mangaDetails.chapter_count && <p>Chapter Count: {mangaDetails.chapter_count}</p>}
      {mangaDetails.episode_count && <p>Episode Count: {mangaDetails.episode_count}</p> }
      <p>Average Rating: {mangaDetails.avg_rating}</p>
      {mangaDetails.user_status && <p>Your Status: {mangaDetails.user_status}</p>}

      {/* Отображение оценки пользователя */}
      {mangaDetails.user_rating && (
        <p>Your Rating: {mangaDetails.user_rating}</p>
      )}

      {/* Отображение отзыва пользователя */}
      {mangaDetails.user_review && (
        <div>
          <h3>Your Review:</h3>
          <p>{mangaDetails.user_review}</p>
        </div>
      )}
    </div>
  );
};

export default MangaDetails;