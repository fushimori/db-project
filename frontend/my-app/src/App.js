// src/App.js
import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import Navbar from './components/Navbar';
import RegisterForm from './components/RegisterForm';
import LoginForm from './components/LoginForm';

const App = () => {
  return (
    <Router>  {/* Обертываем Router здесь */}
      <AuthProvider>
        <Navbar />
        <Routes>
          <Route path="/register" element={<RegisterForm />} />
          <Route path="/login" element={<LoginForm />} />
          <Route path="/" element={<h1>Home</h1>} />
        </Routes>
      </AuthProvider>
    </Router>
  );
};

export default App;
