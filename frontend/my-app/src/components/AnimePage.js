// src/components/AnimePage.js
import React, { useEffect, useState, useCallback } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { getAnime, searchAnime } from '../api/media';
import MediaItem from './MediaItem';
import SearchBar from './SearchBar';
import { useAuth } from '../context/AuthContext';
import { uploadAnimeCsv, deleteAnime } from '../api/insert_csv'; // Импортируем API функции

const AnimePage = () => {
  const [animeList, setAnimeList] = useState([]);
  const [filteredAnimeList, setFilteredAnimeList] = useState([]);
  const { role } = useAuth();  // Получаем роль из контекста
  const [file, setFile] = useState(null); // Состояние для хранения выбранного файла
  console.log('User role:', role); // Проверим, получаем ли роль
  const location = useLocation();
  const navigate = useNavigate();

  const getQueryParam = useCallback(() => {
    const params = new URLSearchParams(location.search);
    return params.get('query') || '';
  }, [location.search]);

  useEffect(() => {
    const fetchAnime = async () => {
      const query = getQueryParam();
      try {
        let data;
        if (query) {
          data = await searchAnime(query);
        } else {
          data = await getAnime();
        }
        setAnimeList(data.anime || data.results);
        setFilteredAnimeList(data.anime || data.results);
      } catch (error) {
        console.error("Error fetching anime data:", error);
      }
    };
    fetchAnime();
  }, [getQueryParam]);

  // Функция для добавления аниме через CSV
  const handleAddAnimeCsv = async () => {
    if (!file) {
      alert('Please select a CSV file');
      return;
    }

    try {
      await uploadAnimeCsv(file);  // Загружаем CSV файл
      alert('Anime added successfully');
      setFile(null);  // Очищаем выбранный файл
      window.location.reload();  // Перезагружаем страницу, чтобы увидеть новые данные
    } catch (error) {
      console.error('Error uploading CSV:', error);
      alert('Failed to upload CSV');
    }
  };

  // Функция для удаления аниме
  const handleDeleteAnime = async (animeId) => {
    if (window.confirm('Are you sure you want to delete this anime?')) {
      try {
        await deleteAnime(animeId);  // Удаляем аниме по ID
        alert('Anime deleted successfully');
        setAnimeList(animeList.filter(anime => anime.id !== animeId));
        setFilteredAnimeList(filteredAnimeList.filter(anime => anime.id !== animeId));
      } catch (error) {
        console.error('Error deleting anime:', error);
        alert('Failed to delete anime');
      }
    }
  };

  return (
    <div>
      <h2>Anime</h2>

      {/* Отображение кнопок только для администраторов */}
      {role === 'admin' && (
        <div>
          <input 
            type="file" 
            accept=".csv" 
            onChange={(e) => setFile(e.target.files[0])}  // Выбор файла
          />
          <button onClick={handleAddAnimeCsv}>Add Anime from CSV</button>
        </div>
      )}

      <SearchBar currentCategory="anime" onSearch={(query) => setFilteredAnimeList(animeList.filter(anime => anime.title.toLowerCase().includes(query.toLowerCase())))} />
      
      <div className="media-list">
        {filteredAnimeList.length > 0 ? (
          filteredAnimeList.map((anime) => (
            <div key={anime.id}>
              <MediaItem media={anime} status={anime.status} />
              {role === 'admin' && (
                <button onClick={() => handleDeleteAnime(anime.id)}>Delete Anime</button>
              )}
            </div>
          ))
        ) : (
          <p>No anime available</p>
        )}
      </div>
    </div>
  );
};

export default AnimePage;
