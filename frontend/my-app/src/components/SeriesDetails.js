import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { getSeriesDetails } from '../api/media'; // Импортируем API-функцию

const SeriesDetails = () => {
  const { seriesId } = useParams(); // Получаем seriesId из URL
  const [seriesDetails, setSeriesDetails] = useState(null);

  useEffect(() => {
    const fetchSeriesDetails = async () => {
      try {
        const data = await getSeriesDetails(seriesId); // Используем API-функцию
        setSeriesDetails(data.series_details); // Обновляем состояние
      } catch (error) {
        console.error("Error fetching series details:", error);
      }
    };

    fetchSeriesDetails();
  }, [seriesId]);

  if (!seriesDetails) {
    return <div>Loading...</div>;
  }

  return (
    <div className="series-details">
      <img src={`http://localhost:8000${seriesDetails.photo_path}`} alt={seriesDetails.title} />
      <h1>{seriesDetails.title}</h1>
      <p>{seriesDetails.description}</p>
      <p>Release Date: {seriesDetails.release_date}</p>
      {seriesDetails.end_date && <p>End date: {seriesDetails.end_date}</p>}
      <p>Type: {seriesDetails.type}</p>
      {seriesDetails.chapter_count && <p>Chapter Count: {seriesDetails.chapter_count}</p>}
      {seriesDetails.episode_count && <p>Episode Count: {seriesDetails.episode_count}</p> }
      <p>Average Rating: {seriesDetails.avg_rating}</p>
      {seriesDetails.user_status && <p>Your Status: {seriesDetails.user_status}</p>}

      {/* Отображение оценки пользователя */}
      {seriesDetails.user_rating && (
        <p>Your Rating: {seriesDetails.user_rating}</p>
      )}

      {/* Отображение отзыва пользователя */}
      {seriesDetails.user_review && (
        <div>
          <h3>Your Review:</h3>
          <p>{seriesDetails.user_review}</p>
        </div>
      )}
    </div>
  );
};

export default SeriesDetails;