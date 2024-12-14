import React from 'react';
import MediaPage from './MediaPage';
import { getManga, searchManga } from '../../api/media';
import { uploadMangaCsv, deleteManga } from '../../api/insert_csv';

const MangaPage = () => {
  return (
    <MediaPage 
      mediaType="manga" 
      getMedia={getManga} 
      searchMedia={searchManga} 
      uploadCsv={uploadMangaCsv} 
      deleteMediaById={deleteManga}
    />
  );
};

export default MangaPage;