// src/api/insert_csv.js

import axios from 'axios';

// URL вашего бекенда
const API_URL = 'http://localhost:8000';

// Функция для загрузки CSV файла
export const uploadCsv = async (file, mediaType) => {
  const token = localStorage.getItem('token');
  const formData = new FormData();
  formData.append('file', file); // Добавляем файл в FormData

  try {
    const response = await axios.post(`${API_URL}/${mediaType}/upload-csv`, formData, {
      headers: {
        'Authorization': `Bearer ${token}`, // Передаем токен для авторизации
        'Content-Type': 'multipart/form-data', // Указываем, что отправляем форму с файлом
      },
    });
    return response.data;
  } catch (error) {
    console.error('Error uploading CSV:', error);
    throw error;
  }
};

// Функция для удаления медиа
export const deleteMedia = async (mediaId, mediaType) => {
  const token = localStorage.getItem('token');
  
  try {
    const response = await axios.delete(`${API_URL}/${mediaType}/delete-media/${mediaId}`, {
      headers: {
        'Authorization': `Bearer ${token}`,
      },
    });
    return response.data;
  } catch (error) {
    console.error('Error deleting media:', error);
    throw error;
  }
};

// Теперь создаем функции для каждого типа медиа:

// Пример использования для аниме
export const uploadAnimeCsv = (file) => uploadCsv(file, 'anime');
export const deleteAnime = (mediaId) => deleteMedia(mediaId, 'anime');

// Пример использования для манги
export const uploadMangaCsv = (file) => uploadCsv(file, 'manga');
export const deleteManga = (mediaId) => deleteMedia(mediaId, 'manga');

// Пример использования для фильмов
export const uploadMovieCsv = (file) => uploadCsv(file, 'movie');
export const deleteMovie = (mediaId) => deleteMedia(mediaId, 'movie');

export const uploadBookCsv = (file) => uploadCsv(file, 'book');
export const deleteBook = (mediaId) => deleteMedia(mediaId, 'book');

export const uploadSeriesCsv = (file) => uploadCsv(file, 'series');
export const deleteSeries = (mediaId) => deleteMedia(mediaId, 'series');


