
// src/components/PersonPage.js
import React, { useEffect, useState, useCallback } from 'react';
import { useLocation, Link } from 'react-router-dom';
import { getPerson, searchPerson } from '../api/media';
import SearchBar from './SearchBar';


const PersonItem = ({ person }) => {  // Используйте деструктуризацию для props
  return (
    <div className="person">
      <Link to={`/person/${person.id}`}>
        <img src={`http://localhost:8000${person.photo_path}`} alt={person.name} />
        <h3>{person.name}</h3>
      </Link>
    </div>
  );
};


const PersonPage = () => {
  const [personList, setPersonList] = useState([]);
  const [filteredPersonList, setFilteredPersonList] = useState([]);
  const location = useLocation();

  // Функция получения query-параметра из URL
  const getQueryParam = useCallback(() => {
    const params = new URLSearchParams(location.search);
    return params.get('query') || '';
  }, [location.search]);

  // Загрузка данных о персонах и обработка query
  useEffect(() => {
    const fetchPersons = async () => {
      const query = getQueryParam();
      try {
        let data;
        if (query) {
          data = await searchPerson(query); // Поиск по запросу
        } else {
          data = await getPerson(); // Загрузка всех данных, если query отсутствует
        }
        setPersonList(data.person || data.results); // Обновляем список персон
        setFilteredPersonList(data.person || data.results); // Отображаем изначально все или отфильтрованные данные
      } catch (error) {
        console.error('Error fetching person data:', error);
      }
    };
    fetchPersons();
  }, [getQueryParam]);

  // Обработчик поиска по имени персоны
  const handleSearch = (query) => {
    setFilteredPersonList(
      personList.filter((person) =>
        person.name.toLowerCase().includes(query.toLowerCase())
      )
    );
  };

  return (
    <div>
      <h2>Persons</h2>
      <SearchBar currentCategory="person" onSearch={handleSearch} />
      <div className="person-list">
        {filteredPersonList.length > 0 ? (
          filteredPersonList.map((person) => (
            <div key={person.id}>
              <PersonItem person={person} />
            </div>
          ))
        ) : (
          <p>No persons available</p>
        )}
      </div>
    </div>
  );
};

export default PersonPage;
