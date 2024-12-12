import React, { useEffect, useState } from 'react';
import { getBook } from '../api/media'; // Функция получения данных из API
import MediaItem from './MediaItem';
import { useAuth } from '../context/AuthContext';

const BookPage = () => {
  const [bookList, setBookList] = useState([]);
  const { isLoggedIn } = useAuth();

  useEffect(() => {
    console.log('Fetching book...');
    const fetchBook = async () => {
      try {
        const data = await getBook();
        console.log('Book data received:', data);  // Выводим полученные данные
        setBookList(data.book); // Обновляем состояние
      } catch (error) {
        console.error("Error fetching book data:", error);
      }
    };
    fetchBook();
  }, []);  // Убедитесь, что массив зависимостей пустой
  
  return (
    <div>
      <h2>Book</h2>
      <div className="media-list">
        {bookList.length > 0 ? (
          bookList.map((book) => (
            <div key={book.id}> {/* Убедитесь, что ключ уникален */}
              <MediaItem media={book} status={isLoggedIn ? book.status : null} />
            </div>
          ))
        ) : (
          <p>No book available</p>  // Сообщение, если аниме нет
        )}
      </div>
    </div>
  );
};

export default BookPage;
