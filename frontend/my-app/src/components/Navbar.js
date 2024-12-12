// src/components/Navbar.js
import React from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

const Navbar = () => {
  const { isLoggedIn, logout } = useAuth();

  return (
    <nav>
      <Link to="/">Home</Link>
      {isLoggedIn ? (
        <>
          <Link to="/anime">Anime</Link>
          <Link to="/manga">Manga</Link>
          <Link to="/movie">Movies</Link>
          <Link to="/book">Books</Link>
          <Link to="/series">Series</Link>
          <Link to="/person">Persons</Link>
          <Link to="/profile">Profile</Link>
          <button onClick={logout}>Logout</button>
        </>
      ) : (
        <>
          <Link to="/anime">Anime</Link>
          <Link to="/manga">Manga</Link>
          <Link to="/movie">Movies</Link>
          <Link to="/book">Books</Link>
          <Link to="/series">Series</Link>
          <Link to="/person">Persons</Link>
          <Link to="/login">Login</Link>
          <Link to="/register">Register</Link>
        </>
      )}
    </nav>
  );
};

export default Navbar;