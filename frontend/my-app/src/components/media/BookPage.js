import React from 'react';
import MediaPage from './MediaPage';
import { getBook, searchBook } from '../../api/media';
import { uploadBookCsv, deleteBook } from '../../api/insert_csv';

const BookPage = () => {
  return (
    <MediaPage 
      mediaType="book" 
      getMedia={getBook} 
      searchMedia={searchBook} 
      uploadCsv={uploadBookCsv} 
      deleteMediaById={deleteBook}
    />
  );
};

export default BookPage;