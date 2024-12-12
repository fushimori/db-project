// src/components/PersonPage.js
import React, { useEffect, useState } from 'react';
import { getPerson } from '../api/media'; // Функция получения данных из API
import { Link } from 'react-router-dom';

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

  useEffect(() => {
    console.log('Fetching person data...');
    const fetchPerson = async () => {
      try {
        const data = await getPerson();
        console.log('Person data received:', data);  // Выводим данные для отладки
        if (data && data.person) {  // Убедитесь, что данные содержат ключ person
          setPersonList(data.person);  // Обновляем состояние
        } else {
          console.error("No person data found.");
        }
      } catch (error) {
        console.error("Error fetching person data:", error);
      }
    };
    fetchPerson();
  }, []);  // Пустой массив зависимостей для загрузки данных при монтировании компонента
  
  return (
    <div>
      <h2>Persons</h2>
      <div className="person-list">
        {personList.length > 0 ? (
          personList.map((person) => (
            <div key={person.id}> {/* Убедитесь, что ключ уникален */}
              <PersonItem person={person} />
            </div>
          ))
        ) : (
          <p>No persons available</p>  // Сообщение, если данных нет
        )}
      </div>
    </div>
  );
};

export default PersonPage;
