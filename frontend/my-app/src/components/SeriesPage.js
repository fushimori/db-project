// src/components/SeriesPage.js
import React, { useEffect, useState, useCallback } from 'react';
import { useLocation } from 'react-router-dom';
import { getSeries, searchSeries } from '../api/media';
import MediaItem from './MediaItem';
import SearchBar from './SearchBar';

const SeriesPage = () => {
  const [seriesList, setSeriesList] = useState([]);
  const [filteredSeriesList, setFilteredSeriesList] = useState([]);
  const location = useLocation();

  const getQueryParam = useCallback(() => {
    const params = new URLSearchParams(location.search);
    return params.get('query') || '';
  }, [location.search]);

  useEffect(() => {
    const fetchSeries = async () => {
      const query = getQueryParam();
      try {
        let data;
        if (query) {
          data = await searchSeries(query);
        } else {
          data = await getSeries();
        }
        setSeriesList(data.series || data.results);
        setFilteredSeriesList(data.series || data.results);
      } catch (error) {
        console.error("Error fetching series data:", error);
      }
    };
    fetchSeries();
  }, [getQueryParam]);

  const handleSearch = (query) => {
    setFilteredSeriesList(seriesList.filter(series => series.title.toLowerCase().includes(query.toLowerCase())));
  };

  return (
    <div>
      <h2>Series</h2>
      <SearchBar currentCategory="series" onSearch={handleSearch} />
      <div className="media-list">
        {filteredSeriesList.length > 0 ? (
          filteredSeriesList.map((series) => (
            <div key={series.id}>
              <MediaItem media={series} />
            </div>
          ))
        ) : (
          <p>No series available</p>
        )}
      </div>
    </div>
  );
};

export default SeriesPage;