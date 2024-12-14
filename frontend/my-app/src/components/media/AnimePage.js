// src/components/AnimePage.js
import React from 'react';
import MediaPage from './MediaPage';
import { getAnime, searchAnime } from '../../api/media';
import { uploadAnimeCsv, deleteAnime } from '../../api/insert_csv';

const AnimePage = () => {
  return (
    <MediaPage 
      mediaType="anime" 
      getMedia={getAnime} 
      searchMedia={searchAnime} 
      uploadCsv={uploadAnimeCsv} 
      deleteMediaById={deleteAnime}
    />
  );
};

export default AnimePage;
