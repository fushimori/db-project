import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { getBookDetails } from '../api/media'; // Импортируем API-функцию

const BookDetails = () => {
  const { bookId } = useParams(); // Получаем bookId из URL
  const [bookDetails, setBookDetails] = useState(null);

  useEffect(() => {
    const fetchBookDetails = async () => {
      try {
        const data = await getBookDetails(bookId); // Используем API-функцию
        setBookDetails(data.book_details); // Обновляем состояние
      } catch (error) {
        console.error("Error fetching book details:", error);
      }
    };

    fetchBookDetails();
  }, [bookId]);

  if (!bookDetails) {
    return <div>Loading...</div>;
  }

  return (
    <div className="book-details">
      <img src={`http://localhost:8000${bookDetails.photo_path}`} alt={bookDetails.title} />
      <h1>{bookDetails.title}</h1>
      <p>{bookDetails.description}</p>
      <p>Release Date: {bookDetails.release_date}</p>
      {bookDetails.end_date && <p>End date: {bookDetails.end_date}</p>}
      <p>Type: {bookDetails.type}</p>
      {bookDetails.chapter_count && <p>Chapter Count: {bookDetails.chapter_count}</p>}
      {bookDetails.episode_count && <p>Episode Count: {bookDetails.episode_count}</p> }
      <p>Average Rating: {bookDetails.avg_rating}</p>
      {bookDetails.user_status && <p>Your Status: {bookDetails.user_status}</p>}

      {/* Отображение оценки пользователя */}
      {bookDetails.user_rating && (
        <p>Your Rating: {bookDetails.user_rating}</p>
      )}

      {/* Отображение отзыва пользователя */}
      {bookDetails.user_review && (
        <div>
          <h3>Your Review:</h3>
          <p>{bookDetails.user_review}</p>
        </div>
      )}
    </div>
  );
};

export default BookDetails;