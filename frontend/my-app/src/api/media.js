// src/api/media.js
import axios from 'axios';

const API_URL = 'http://localhost:8000'; // URL вашего бекенда

// Функция для создания конфигурации с токеном
const getAuthConfig = () => {
  const token = localStorage.getItem('token');
  return token ? { headers: { 'Authorization': `Bearer ${token}` } } : {};
};

// Универсальная функция поиска для различных типов медиа
export const searchMedia = async (query, category) => {
  try {
    const config = getAuthConfig();
    const response = await axios.get(`${API_URL}/${category}/search`, { params: { query }, ...config });
    return response.data;
  } catch (error) {
    console.error(`Error searching ${category}:`, error.response?.data || error.message);
    throw error;
  }
};

export const getMedia = async (category) => {
  try {
    const config = getAuthConfig();
    const response = await axios.get(`${API_URL}/${category}`, config);
    return response.data;
  } catch (error) {
    console.error(`Error fetching ${category}:`, error.response?.data || error.message);
    throw error;
  }
};

// Универсальная функция для получения деталей медиа
export const getMediaDetails = async (category, id) => {
  try {
    const config = getAuthConfig();
    const response = await axios.get(`${API_URL}/${category}/${id}`, config);
    return response.data;
  } catch (error) {
    console.error(`Error fetching ${category} details:`, error.response?.data || error.message);
    throw error;
  }
};

// Добавление медиа в список пользователя
export const addToUserList = async (mediaId, status, category) => {
  try {
    console.log(mediaId, status, category);
    const config = getAuthConfig();
    const response = await axios.post(
      `${API_URL}/${category}/${mediaId}/add-to-list?status=${status}`,
      {},  // Empty body
      config
    );
    return response.data;
  } catch (error) {
    console.error(`Error adding ${category} to list:`, error.response?.data || error.message);
    throw error;
  }
};


// Удаление медиа из списка пользователя
export const removeFromUserList = async (mediaId, category) => {
  try {
    const config = getAuthConfig();
    const response = await axios.post(`${API_URL}/${category}/${mediaId}/remove-from-list`, {}, config);
    return response.data;
  } catch (error) {
    console.error(`Error removing ${category} from list:`, error.response?.data || error.message);
    throw error;
  }
};

// Пример использования для аниме
export const getAnime = () => getMedia('anime');
export const getAnimeDetails = (animeId) => getMediaDetails('anime', animeId);
export const searchAnime = (query) => searchMedia(query, 'anime');
export const addAnimeToList = (mediaId, status) => addToUserList(mediaId, status, 'anime');
export const removeAnimeFromList = (mediaId) => removeFromUserList(mediaId, 'anime');

// Пример использования для манги
export const getManga = () => getMedia('manga');
export const getMangaDetails = (mangaId) => getMediaDetails('manga', mangaId);
export const searchManga = (query) => searchMedia(query, 'manga');
export const addMangaToList = (mediaId, status) => addToUserList(mediaId, status, 'manga');
export const removeMangaFromList = (mediaId) => removeFromUserList(mediaId, 'manga');

// Пример использования для фильмов
export const getMovie = () => getMedia('movie');
export const getMovieDetails = (movieId) => getMediaDetails('movie', movieId);
export const searchMovie = (query) => searchMedia(query, 'movie');
export const addMovieToList = (mediaId, status) => addToUserList(mediaId, status, 'movie');
export const removeMovieFromList = (mediaId) => removeFromUserList(mediaId, 'movie');

// Пример использования для книг
export const getBook = () => getMedia('book');
export const getBookDetails = (bookId) => getMediaDetails('book', bookId);
export const searchBook = (query) => searchMedia(query, 'book');
export const addBookToList = (mediaId, status) => addToUserList(mediaId, status, 'book');
export const removeBookFromList = (mediaId) => removeFromUserList(mediaId, 'book');

// Пример использования для сериалов
export const getSeries = () => getMedia('series');
export const getSeriesDetails = (seriesId) => getMediaDetails('series', seriesId);
export const searchSeries = (query) => searchMedia(query, 'series');
export const addSeriesToList = (mediaId, status) => addToUserList(mediaId, status, 'series');
export const removeSeriesFromList = (mediaId) => removeFromUserList(mediaId, 'series');


export const getPerson = async () => {
  try {
    const response = await axios.get(`${API_URL}/person`);
    return response.data;
  } catch (error) {
    console.error('Error fetching person:', error);
    throw error;
  }
};

export const getPersonDetails = async (personId) => {
  try {
    const response = await axios.get(`${API_URL}/person/${personId}/`);
    return response.data;
  } catch (error) {
    console.error('Error fetching person details:', error);
    throw error;
  }
};

export const searchPerson = async (query) => {
  try {
    const response = await axios.get(`${API_URL}/person/search`, {
      params: { query }, // Передаем параметры поиска
    });
    return response.data;
  } catch (error) {
    console.error('Error searching person:', error);
    throw error;
  }
};

