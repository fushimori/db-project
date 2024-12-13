// src/api/auth.js

import axios from 'axios';

const API_URL = 'http://localhost:8000';

// Функция для регистрации
export const registerUser = async (username, email, password) => {
  try {
    const response = await axios.post(`${API_URL}/user/register`, { username, email, password });
    return response.data;
  } catch (error) {
    console.error('Registration error:', error);
    throw error;  // Пробрасываем ошибку для обработки в компоненте
  }
};

// Функция для логина
export const loginUser = async (username, password) => {
  try {
    const response = await axios.post(`${API_URL}/user/token`, 
      new URLSearchParams({
        username: username,
        password: password
      }), {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        }
      }
    );
    // Сохраняем токен в localStorage
    localStorage.setItem('token', response.data.access_token);
    return response.data;  // Возвращаем токен
  } catch (error) {
    console.error('Login error:', error);
    throw error;
  }
};

// Функция для получения роли пользователя
export const fetchUserRole = async (token) => {
  try {
    const response = await axios.get(`${API_URL}/users/me`, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });
    return response.data.role;  // Возвращаем роль
  } catch (error) {
    console.error('Error fetching user role:', error);
    throw error;  // Возвращаем ошибку, если не удалось получить роль
  }
};
