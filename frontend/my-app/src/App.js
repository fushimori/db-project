// src/app.js
import './App.css'; 
import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import Navbar from './components/navigation/Navbar';
import RegisterForm from './components/auth/RegisterForm';
import LoginForm from './components/auth/LoginForm';
import AnimePage from './components/media/AnimePage';
import MangaPage from './components/media/MangaPage';
import MoviePage from './components/media/MoviePage';
import BookPage from './components/media/BookPage';
import SeriesPage from './components/media/SeriesPage';
import AnimeDetails from './components/media/AnimeDetails';
import MangaDetails from './components/media/MangaDetails';
import SeriesDetails from './components/media/SeriesDetails';
import MovieDetails from './components/media/MovieDetails';
import BookDetails from './components/media/BookDetails';
import PersonPage from './components/people/PersonPage';
import PersonDetails from './components/people/PersonDetails';
import ProfilePage from './components/profile/ProfilePage'; // Импортируем компонент профиля
import Home from './components/home/HomePage'; 

const App = () => {
  return (
    <Router>
      <AuthProvider>
        <div className="page-container">
          <div className="top-section">
            <Navbar />
            <div className="container">
              <Routes>
                <Route path="/register" element={<RegisterForm />} />
                <Route path="/login" element={<LoginForm />} />
                <Route path="/anime" element={<AnimePage />} />
                <Route path="/manga" element={<MangaPage />} />
                <Route path="/movie" element={<MoviePage />} />
                <Route path="/book" element={<BookPage />} />
                <Route path="/series" element={<SeriesPage />} />
                <Route path="/person" element={<PersonPage />} />
                <Route path="/profile" element={<ProfilePage />} /> {/* Добавляем маршрут для профиля */}
                <Route path="/" element={<Home />} /> {/* Обновлено на Home */}
                <Route path="/person/:personId" element={<PersonDetails />} />
                <Route path="/series/:mediaId" element={<SeriesDetails />} />
                <Route path="/book/:mediaId" element={<BookDetails />} />
                <Route path="/movie/:mediaId" element={<MovieDetails />} />
                <Route path="/manga/:mediaId" element={<MangaDetails />} />
                <Route path="/anime/:mediaId" element={<AnimeDetails />} />
              </Routes>
            </div>
          </div>
          <div className="bottom-section">
            {/* Нижняя часть страницы */}
            <p>© 2024 DB PROJECT. All rights reserved.</p>
          </div>
        </div>
      </AuthProvider>
    </Router>
  );
};

export default App;