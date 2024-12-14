import React from 'react';
import MediaPage from './MediaPage';
import { getSeries, searchSeries } from '../../api/media';
import { uploadSeriesCsv, deleteSeries } from '../../api/insert_csv';

const SeriesPage = () => {
  return (
    <MediaPage 
      mediaType="series" 
      getMedia={getSeries} 
      searchMedia={searchSeries} 
      uploadCsv={uploadSeriesCsv} 
      deleteMediaById={deleteSeries}
    />
  );
};

export default SeriesPage;