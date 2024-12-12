import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { getPersonDetails } from '../api/media'; // Импортируем API-функцию

const PersonDetails = () => {
  const { personId } = useParams(); // Получаем personId из URL
  const [personDetails, setPersonDetails] = useState(null);

  useEffect(() => {
    const fetchPersonDetails = async () => {
      try {
        const data = await getPersonDetails(personId); // Используем API-функцию
        setPersonDetails(data.person_details); // Обновляем состояние
      } catch (error) {
        console.error("Error fetching person details:", error);
      }
    };

    fetchPersonDetails();
  }, [personId]);

  if (!personDetails) {
    return <div>Loading...</div>;
  }

  return (
    <div className="person-details">
      <img src={`http://localhost:8000${personDetails.photo_path}`} alt={personDetails.name} />
      <h1>{personDetails.name}</h1>
      {personDetails.nationality && <p>Nationality: {personDetails.nationality}</p>}
      {personDetails.birth_date && <p>Birth date: {personDetails.birth_date}</p>}
      {personDetails.main_role && <p>Main role: {personDetails.main_role}</p>}
    </div>
  );
};

export default PersonDetails;