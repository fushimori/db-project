// src/components/media.js
import axios from 'axios';

const API_URL = 'http://localhost:8000'; // URL вашего бекенда

export const getAnime = async () => {
  const token = localStorage.getItem('token');  // Получаем токен из localStorage
  
  try {
    const config = token
      ? { headers: { 'Authorization': `Bearer ${token}` } } // Если токен есть, передаем его
      : {};  // Если токен отсутствует, не передаем заголовок Authorization

    const response = await axios.get(`${API_URL}/anime`, config);
    return response.data;
  } catch (error) {
    console.error('Request failed with status code 401:', error);
    throw error;
  }
};

// Функция для получения деталей аниме
export const getAnimeDetails = async (animeId) => {
  const token = localStorage.getItem('token');  // Получаем токен из localStorage
  
  try {
    const config = token
      ? { headers: { 'Authorization': `Bearer ${token}` } } // Если токен есть, передаем его
      : {};  // Если токен отсутствует, не передаем заголовок Authorization

    const response = await axios.get(`${API_URL}/anime/${animeId}`, config);
    return response.data;
  } catch (error) {
    console.error('Request failed with status code 401:', error);
    throw error;
  }
};

export const getMovie = async () => {
  try {
    const response = await axios.get(`${API_URL}/movie`);
    return response.data;
  } catch (error) {
    console.error('Error fetching movie:', error);
    throw error;
  }
};

export const getMovieDetails = async (movieId) => {
  const token = localStorage.getItem('token');  // Получаем токен из localStorage
  
  try {
    const config = token
      ? { headers: { 'Authorization': `Bearer ${token}` } } // Если токен есть, передаем его
      : {};  // Если токен отсутствует, не передаем заголовок Authorization

    const response = await axios.get(`${API_URL}/movie/${movieId}`, config);
    return response.data;
  } catch (error) {
    console.error('Request failed with status code 401:', error);
    throw error;
  }
};

export const getBook = async () => {
  try {
    const response = await axios.get(`${API_URL}/book`);
    return response.data;
  } catch (error) {
    console.error('Error fetching book:', error);
    throw error;
  }
};

export const getBookDetails = async (bookId) => {
  const token = localStorage.getItem('token');  // Получаем токен из localStorage
  
  try {
    const config = token
      ? { headers: { 'Authorization': `Bearer ${token}` } } // Если токен есть, передаем его
      : {};  // Если токен отсутствует, не передаем заголовок Authorization

    const response = await axios.get(`${API_URL}/book/${bookId}`, config);
    return response.data;
  } catch (error) {
    console.error('Request failed with status code 401:', error);
    throw error;
  }
};

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

export const getSeries = async () => {
  try {
    const response = await axios.get(`${API_URL}/series`);
    return response.data;
  } catch (error) {
    console.error('Error fetching series:', error);
    throw error;
  }
};

export const getSeriesDetails = async (seriesId) => {
  const token = localStorage.getItem('token');  // Получаем токен из localStorage
  
  try {
    const config = token
      ? { headers: { 'Authorization': `Bearer ${token}` } } // Если токен есть, передаем его
      : {};  // Если токен отсутствует, не передаем заголовок Authorization

    const response = await axios.get(`${API_URL}/series/${seriesId}`, config);
    return response.data;
  } catch (error) {
    console.error('Request failed with status code 401:', error);
    throw error;
  }
};

export const getManga = async () => {
  try {
    const response = await axios.get(`${API_URL}/manga`);
    return response.data;
  } catch (error) {
    console.error('Error fetching manga:', error);
    throw error;
  }
};

export const getMangaDetails = async (mangaId) => {
  const token = localStorage.getItem('token');  // Получаем токен из localStorage
  
  try {
    const config = token
      ? { headers: { 'Authorization': `Bearer ${token}` } } // Если токен есть, передаем его
      : {};  // Если токен отсутствует, не передаем заголовок Authorization

    const response = await axios.get(`${API_URL}/manga/${mangaId}`, config);
    return response.data;
  } catch (error) {
    console.error('Request failed with status code 401:', error);
    throw error;
  }
};

export const searchMedia = async (query, category) => {
  const token = localStorage.getItem('token');  // Получаем токен из localStorage
  
  try {
    const config = token
      ? { headers: { 'Authorization': `Bearer ${token}` } } // Если токен есть, передаем его
      : {};  // Если токен отсутствует, не передаем заголовок Authorization

    const response = await axios.get(`${API_URL}/search`, {
      params: { query, category },
      ...config
    });
    return response.data;
  } catch (error) {
    console.error('Request failed with status code 401:', error);
    throw error;
  }
};