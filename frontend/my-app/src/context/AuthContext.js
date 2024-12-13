// authContext.js
import jwtDecode from 'jwt-decode'; // Библиотека для декодирования JWT-токена
import React, { createContext, useState, useEffect, useContext } from 'react';
import { useNavigate } from 'react-router-dom';
import { loginUser, registerUser } from '../api/auth'; // Импортируем все необходимые функции

const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [role, setRole] = useState('guest');
  const [loading, setLoading] = useState(true); // Для управления состоянием загрузки
  const navigate = useNavigate();

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (token) {
      const decodedToken = jwtDecode(token);
      setRole(decodedToken.role); // Устанавливаем роль из декодированного токена
      setIsLoggedIn(true); // Если токен есть, считаем пользователя залогиненным
    } else {
      setIsLoggedIn(false); // Если токен отсутствует, устанавливаем статус выхода
    }
    setLoading(false); // Завершаем загрузку состояния
  }, []);

  // Логин
  const login = async (username, password) => {
    setLoading(true); // Устанавливаем загрузку
    try {
      const { access_token } = await loginUser(username, password); // Входим через API
      setIsLoggedIn(true);
      const decodedToken = jwtDecode(access_token);
      setRole(decodedToken.role); // Устанавливаем роль из декодированного токена
      navigate('/'); // Перенаправляем на главную страницу
    } catch (error) {
      console.error('Login failed:', error);
      alert('Invalid credentials');
    } finally {
      setLoading(false); // Завершаем загрузку
    }
  };

  // Регистрация
  const register = async (username, email, password) => {
    setLoading(true); // Устанавливаем загрузку
    try {
      await registerUser(username, email, password); // Регистрируем пользователя через API
      alert('Registration successful!');
      navigate('/login'); // Перенаправляем на страницу логина
    } catch (error) {
      console.error('Registration failed:', error);
      alert('Registration failed');
    } finally {
      setLoading(false); // Завершаем загрузку
    }
  };

  // Выход
  const logout = () => {
    localStorage.removeItem('token');
    setIsLoggedIn(false);
    setRole('guest');
    navigate('/login'); // Перенаправляем на страницу логина
  };

  if (loading) {
    return <div>Loading...</div>; // Показать индикатор загрузки, пока мы проверяем токен
  }

  return (
    <AuthContext.Provider value={{ isLoggedIn, role, login, logout, register }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
