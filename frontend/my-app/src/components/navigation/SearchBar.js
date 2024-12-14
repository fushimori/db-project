// src/components/SearchBar.js
import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import './SearchBar.css'; // Импортируем CSS-файл

const SearchBar = ({ currentCategory, onSearch }) => {
  const [query, setQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState(currentCategory);
  const navigate = useNavigate();

  // Обработчик изменения текста в поле ввода
  const handleSearchChange = (e) => {
    const newQuery = e.target.value;
    setQuery(newQuery);
    if (onSearch) onSearch(newQuery); // Вызываем onSearch на каждое изменение текста
  };

  // Обработчик выбора категории
  const handleCategoryChange = (e) => {
    setSelectedCategory(e.target.value);
  };

  // Обработчик нажатия Enter или клика по кнопке
  const handleSearch = (e) => {
    e.preventDefault(); // Предотвращаем перезагрузку страницы
    // Обновляем URL с выбранной категорией и запросом
    navigate(`/${selectedCategory}?query=${query}`);
    if (onSearch) onSearch(query); // Запускаем onSearch, если он передан
  };

  return (
    <form className="search-bar" onSubmit={handleSearch}> {/* Добавляем класс search-bar */}
      <input
        type="text"
        placeholder="Search..."
        value={query}
        onChange={handleSearchChange} // Добавлено динамическое обновление
      />
      <select value={selectedCategory} onChange={handleCategoryChange}>
        <option value="anime">Anime</option>
        <option value="manga">Manga</option>
        <option value="movie">Movie</option>
        <option value="book">Book</option>
        <option value="series">Series</option>
        <option value="person">Person</option>
      </select>
      <button type="submit">Search</button> {/* Кнопка для выполнения поиска */}
    </form>
  );
};

export default SearchBar;