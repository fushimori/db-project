// src/components/LoginForm.js
import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';  // Контекст для обновления состояния аутентификации

const LoginForm = () => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const navigate = useNavigate();
  const { login } = useAuth();  // Используем login из контекста

  const handleLogin = async (e) => {
    e.preventDefault();
    try {
      await login(username, password);  // Используем login из контекста, который уже обрабатывает токен и роль
      navigate('/');  // Перенаправляем на главную страницу после успешного логина
    } catch (error) {
      alert('Error during login');
    }
  };

  return (
    <div>
      <h2>Login</h2>
      <form onSubmit={handleLogin}>
        <input
          type="text"
          placeholder="Username"
          value={username}
          onChange={(e) => setUsername(e.target.value)}
        />
        <input
          type="password"
          placeholder="Password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
        />
        <button type="submit">Login</button>
      </form>
    </div>
  );
};

export default LoginForm;
