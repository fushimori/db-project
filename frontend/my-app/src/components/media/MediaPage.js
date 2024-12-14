// src/components/MediaPage.js
import React, { useEffect, useState, useCallback } from 'react';
import { useLocation } from 'react-router-dom';
import MediaItem from './MediaItem';
import SearchBar from '../navigation/SearchBar';
import { useAuth } from '../../context/AuthContext';
import './MediaPage.css';

const MediaPage = ({ mediaType, getMedia, searchMedia, uploadCsv, deleteMediaById }) => {
    const [mediaList, setMediaList] = useState([]);
    const [filteredMediaList, setFilteredMediaList] = useState([]);
    const { role } = useAuth();  // Получаем роль из контекста
    const [file, setFile] = useState(null); // Состояние для хранения выбранного файла
    const location = useLocation();
  
    const getQueryParam = useCallback(() => {
      const params = new URLSearchParams(location.search);
      return params.get('query') || '';
    }, [location.search]);
  
    useEffect(() => {
        const fetchMedia = async () => {
            const query = getQueryParam();
            try {
              let data;
              if (query) {
                data = await searchMedia(query);
              } else {
                data = await getMedia();
              }
              console.log(data); // Логирование полученных данных
              setMediaList(data.results);
              setFilteredMediaList(data.results);
            } catch (error) {
              console.error(`Error fetching ${mediaType} data:`, error);
            }
        };          
      fetchMedia();
    }, [getQueryParam, mediaType, getMedia, searchMedia]);
  
    // Функция для добавления медиа через CSV
    const handleAddMediaCsv = async () => {
      if (!file) {
        alert('Please select a CSV file');
        return;
      }
  
      try {
        await uploadCsv(file, mediaType);  // Используем переданную функцию uploadCsv
        alert(`${mediaType.charAt(0).toUpperCase() + mediaType.slice(1)} added successfully`);
        setFile(null);  // Очищаем выбранный файл
        window.location.reload();  // Перезагружаем страницу, чтобы увидеть новые данные
      } catch (error) {
        console.error(`Error uploading ${mediaType} CSV:`, error);
        alert(`Failed to upload ${mediaType}`);
      }
    };
  
    // Функция для удаления медиа
    const handleDeleteMedia = async (mediaId) => {
      if (window.confirm(`Are you sure you want to delete this ${mediaType}?`)) {
        try {
          await deleteMediaById(mediaId, mediaType);  // Используем переданную функцию deleteMediaById
          alert(`${mediaType.charAt(0).toUpperCase() + mediaType.slice(1)} deleted successfully`);
          setMediaList(mediaList.filter(media => media.id !== mediaId));
          setFilteredMediaList(filteredMediaList.filter(media => media.id !== mediaId));
        } catch (error) {
          console.error(`Error deleting ${mediaType}:`, error);
          alert(`Failed to delete ${mediaType}`);
        }
      }
    };
  
    return (
      <div>
        <h2>{mediaType.charAt(0).toUpperCase() + mediaType.slice(1)}</h2>
  
        {/* Отображение кнопок только для администраторов */}
        {role === 'admin' && (
          <div>
            <input 
              type="file" 
              accept=".csv" 
              onChange={(e) => setFile(e.target.files[0])}  // Выбор файла
            />
            <button onClick={handleAddMediaCsv}>Add {mediaType.charAt(0).toUpperCase() + mediaType.slice(1)} from CSV</button>
          </div>
        )}
  
        <SearchBar currentCategory={mediaType} onSearch={(query) => setFilteredMediaList(mediaList.filter(media => media.title.toLowerCase().includes(query.toLowerCase())))} />
        
        <div className="media-list">
          {filteredMediaList && filteredMediaList.length > 0 ? (
            filteredMediaList.map((media) => (
              <div key={media.id}>
                <MediaItem media={media} status={media.status} />
                {role === 'admin' && (
                  <button onClick={() => handleDeleteMedia(media.id)}>Delete {mediaType.charAt(0).toUpperCase() + mediaType.slice(1)}</button>
                )}
              </div>
            ))
          ) : (
            <p>No {mediaType} available</p>
          )}
        </div>
      </div>
    );
  };
  
  export default MediaPage;
  