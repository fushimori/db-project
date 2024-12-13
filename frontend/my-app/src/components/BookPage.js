// src/components/BookPage.js
import React, { useEffect, useState, useCallback } from 'react';
import { useLocation } from 'react-router-dom';
import { getBook, searchBook } from '../api/media';
import MediaItem from './MediaItem';
import SearchBar from './SearchBar';

const BookPage = () => {
  const [bookList, setBookList] = useState([]);
  const [filteredBookList, setFilteredBookList] = useState([]);
  const location = useLocation();

  const getQueryParam = useCallback(() => {
    const params = new URLSearchParams(location.search);
    return params.get('query') || '';
  }, [location.search]);

  useEffect(() => {
    const fetchBooks = async () => {
      const query = getQueryParam();
      try {
        let data;
        if (query) {
          data = await searchBook(query);
        } else {
          data = await getBook();
        }
        setBookList(data.book || data.results);
        setFilteredBookList(data.book || data.results);
      } catch (error) {
        console.error("Error fetching book data:", error);
      }
    };
    fetchBooks();
  }, [getQueryParam]);

  const handleSearch = (query) => {
    setFilteredBookList(bookList.filter(book => book.title.toLowerCase().includes(query.toLowerCase())));
  };

  return (
    <div>
      <h2>Books</h2>
      <SearchBar currentCategory="book" onSearch={handleSearch} />
      <div className="media-list">
        {filteredBookList.length > 0 ? (
          filteredBookList.map((book) => (
            <div key={book.id}>
              <MediaItem media={book} />
            </div>
          ))
        ) : (
          <p>No books available</p>
        )}
      </div>
    </div>
  );
};

export default BookPage;