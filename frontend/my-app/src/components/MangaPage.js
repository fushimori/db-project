// src/components/MangaPage.js
import React, { useEffect, useState, useCallback } from 'react';
import { useLocation } from 'react-router-dom';
import { getManga, searchManga } from '../api/media';
import MediaItem from './MediaItem';
import SearchBar from './SearchBar';

const MangaPage = () => {
  const [mangaList, setMangaList] = useState([]);
  const [filteredMangaList, setFilteredMangaList] = useState([]);
  const location = useLocation();

  const getQueryParam = useCallback(() => {
    const params = new URLSearchParams(location.search);
    return params.get('query') || '';
  }, [location.search]);

  useEffect(() => {
    const fetchManga = async () => {
      const query = getQueryParam();
      try {
        let data;
        if (query) {
          data = await searchManga(query);
        } else {
          data = await getManga();
        }
        setMangaList(data.manga || data.results);
        setFilteredMangaList(data.manga || data.results);
      } catch (error) {
        console.error("Error fetching manga data:", error);
      }
    };
    fetchManga();
  }, [getQueryParam]);

  const handleSearch = (query) => {
    setFilteredMangaList(mangaList.filter(manga => manga.title.toLowerCase().includes(query.toLowerCase())));
  };

  return (
    <div>
      <h2>Manga</h2>
      <SearchBar currentCategory="manga" onSearch={handleSearch} />
      <div className="media-list">
        {filteredMangaList.length > 0 ? (
          filteredMangaList.map((manga) => (
            <div key={manga.id}>
              <MediaItem media={manga} />
            </div>
          ))
        ) : (
          <p>No manga available</p>
        )}
      </div>
    </div>
  );
};

export default MangaPage;
