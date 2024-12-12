// src/api/profile.js
import axios from 'axios';

const API_URL = 'http://localhost:8000'; // URL вашего бекенда

// Функция для получения профиля
export const getProfile = async () => {
  const token = localStorage.getItem('token');
  try {
    const config = token
      ? { headers: { 'Authorization': `Bearer ${token}` } } // Если токен есть, передаем его
      : {};  // Если токен отсутствует, не передаем заголовок Authorization

  const response = await axios.get(`${API_URL}/profile`, config);
  return response.data;
  } catch (error) {
    console.error('Request failed with status code 401:', error);
    throw error;
  }
};