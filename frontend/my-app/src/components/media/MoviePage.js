import React from 'react';
import MediaPage from './MediaPage';
import { getMovie, searchMovie } from '../../api/media';
import { uploadMovieCsv, deleteMovie } from '../../api/insert_csv';

const MoviePage = () => {
  return (
    <MediaPage 
      mediaType="movie" 
      getMedia={getMovie} 
      searchMedia={searchMovie} 
      uploadCsv={uploadMovieCsv} 
      deleteMediaById={deleteMovie}
    />
  );
};

export default MoviePage;