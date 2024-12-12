import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import Navbar from './components/Navbar';
import RegisterForm from './components/RegisterForm';
import LoginForm from './components/LoginForm';
import AnimePage from './components/AnimePage';
import MangaPage from './components/MangaPage';
import MoviePage from './components/MoviePage';
import BookPage from './components/BookPage';
import SeriesPage from './components/SeriesPage';
import AnimeDetails from './components/AnimeDetails';
import MangaDetails from './components/MangaDetails';
import SeriesDetails from './components/SeriesDetails';
import MovieDetails from './components/MovieDetails';
import BookDetails from './components/BookDetails';
import PersonPage from './components/PersonPage';
import PersonDetails from './components/PersonDetails';
import ProfilePage from './components/ProfilePage'; // Импортируем компонент профиля
import SearchPage from './components/SearchPage';

const App = () => {
  return (
    <Router>
      <AuthProvider>
        <Navbar />
        <Routes>
          <Route path="/register" element={<RegisterForm />} />
          <Route path="/login" element={<LoginForm />} />
          <Route path="/anime" element={<AnimePage />} />
          <Route path="/anime/:animeId" element={<AnimeDetails />} />
          <Route path="/manga" element={<MangaPage />} />
          <Route path="/manga/:mangaId" element={<MangaDetails />} />
          <Route path="/movie" element={<MoviePage />} />
          <Route path="/movie/:movieId" element={<MovieDetails />} />
          <Route path="/book" element={<BookPage />} />
          <Route path="/book/:bookId" element={<BookDetails />} />
          <Route path="/series" element={<SeriesPage />} />
          <Route path="/series/:seriesId" element={<SeriesDetails />} />
          <Route path="/person" element={<PersonPage />} />
          <Route path="/person/:personId" element={<PersonDetails />} />
          <Route path="/profile" element={<ProfilePage />} /> {/* Добавляем маршрут для профиля */}
          <Route path="/search" element={<SearchPage />} />
          <Route path="/" element={<h1>Home</h1>} />
        </Routes>
      </AuthProvider>
    </Router>
  );
};

export default App;