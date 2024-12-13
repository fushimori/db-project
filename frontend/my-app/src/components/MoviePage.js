// src/components/MoviePage.js
import React, { useEffect, useState, useCallback } from 'react';
import { useLocation } from 'react-router-dom';
import { getMovie, searchMovie } from '../api/media';
import MediaItem from './MediaItem';
import SearchBar from './SearchBar';

const MoviePage = () => {
  const [movieList, setMovieList] = useState([]);
  const [filteredMovieList, setFilteredMovieList] = useState([]);
  const location = useLocation();

  const getQueryParam = useCallback(() => {
    const params = new URLSearchParams(location.search);
    return params.get('query') || '';
  }, [location.search]);

  useEffect(() => {
    const fetchMovies = async () => {
      const query = getQueryParam();
      try {
        let data;
        if (query) {
          data = await searchMovie(query);
        } else {
          data = await getMovie();
        }
        setMovieList(data.movie || data.results);
        setFilteredMovieList(data.movie || data.results);
      } catch (error) {
        console.error("Error fetching movie data:", error);
      }
    };
    fetchMovies();
  }, [getQueryParam]);

  const handleSearch = (query) => {
    setFilteredMovieList(movieList.filter(movie => movie.title.toLowerCase().includes(query.toLowerCase())));
  };

  return (
    <div>
      <h2>Movies</h2>
      <SearchBar currentCategory="movie" onSearch={handleSearch} />
      <div className="media-list">
        {filteredMovieList.length > 0 ? (
          filteredMovieList.map((movie) => (
            <div key={movie.id}>
              <MediaItem media={movie} />
            </div>
          ))
        ) : (
          <p>No movies available</p>
        )}
      </div>
    </div>
  );
};

export default MoviePage;
