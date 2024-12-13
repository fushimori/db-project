// src/api/media.js
import axios from 'axios';

const API_URL = 'http://localhost:8000'; // URL вашего бекенда

// Универсальная функция поиска для различных типов медиа
export const searchMedia = async (query, category) => {
  const token = localStorage.getItem('token');  // Получаем токен из localStorage
  try {
    const config = token
      ? { headers: { 'Authorization': `Bearer ${token}` } } // Если токен есть, передаем его
      : {};  // Если токен отсутствует, не передаем заголовок Authorization

    const response = await axios.get(`${API_URL}/${category}/search`, {
      params: { query },
      ...config
    });
    return response.data;
  } catch (error) {
    console.error(`Error searching ${category}:`, error);
    throw error;
  }
};

export const getMedia = async (category) => {
  const token = localStorage.getItem('token');  // Получаем токен из localStorage
  console.log(token);
  try {
    const config = token
      ? { headers: { 'Authorization': `Bearer ${token}` } } // Если токен есть, передаем его
      : {};  // Если токен отсутствует, не передаем заголовок Authorization

    const response = await axios.get(`${API_URL}/${category}`, config);
    return response.data;
  } catch (error) {
    console.error(`Error fetching ${category}:`, error);
    throw error;
  }
};

// Универсальная функция для получения деталей медиа
export const getMediaDetails = async (category, id) => {
  const token = localStorage.getItem('token');  // Получаем токен из localStorage
  try {
    const config = token
      ? { headers: { 'Authorization': `Bearer ${token}` } } // Если токен есть, передаем его
      : {};  // Если токен отсутствует, не передаем заголовок Authorization

    const response = await axios.get(`${API_URL}/${category}/${id}`, config);
    return response.data;
  } catch (error) {
    console.error(`Error fetching ${category} details:`, error);
    throw error;
  }
};

export const getAnime = () => getMedia('anime');
export const getAnimeDetails = (animeId) => getMediaDetails('anime', animeId);
export const searchAnime = (query) => searchMedia(query, 'anime');

// Пример использования для манги
export const getManga = () => getMedia('manga');
export const getMangaDetails = (mangaId) => getMediaDetails('manga', mangaId);
export const searchManga = (query) => searchMedia(query, 'manga');

// Пример использования для фильмов
export const getMovie = () => getMedia('movie');
export const getMovieDetails = (movieId) => getMediaDetails('movie', movieId);
export const searchMovie = (query) => searchMedia(query, 'movie');

// Пример использования для книг
export const getBook = () => getMedia('book');
export const getBookDetails = (bookId) => getMediaDetails('book', bookId);
export const searchBook = (query) => searchMedia(query, 'book');

// Пример использования для сериалов
export const getSeries = () => getMedia('series');
export const getSeriesDetails = (seriesId) => getMediaDetails('series', seriesId);
export const searchSeries = (query) => searchMedia(query, 'series');


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
    const response = await axios.get(`${API_URL}/person/${personId}`);
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

