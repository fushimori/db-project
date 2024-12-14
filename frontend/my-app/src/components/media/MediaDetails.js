import './MediaDetails.css'; 
import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { getMediaDetails, addToUserList, removeFromUserList } from '../../api/media'; 
import { useAuth } from '../../context/AuthContext'; 

const MediaDetails = ({ mediaType }) => {
  const { mediaId } = useParams(); 
  const { isLoggedIn } = useAuth(); 
  const [mediaDetails, setMediaDetails] = useState(null);
  const [status, setStatus] = useState(null);
  const [statusList] = useState([
    'watching', 'completed', 'planned', 'on_hold', 'dropped'
  ]);
  const [userHasStatus, setUserHasStatus] = useState(false);

  useEffect(() => {
    const fetchMediaDetails = async () => {
      try {
        const data = await getMediaDetails(mediaType, mediaId);
        setMediaDetails(data.results);

        if (data.results.user_status) {
          setStatus(data.results.user_status);
          setUserHasStatus(true);
        } else {
          setStatus(null);
          setUserHasStatus(false);
        }
      } catch (error) {
        console.error(`Error fetching ${mediaType} details:`, error);
      }
    };

    fetchMediaDetails();
  }, [mediaId, mediaType]);

  const handleStatusChange = async (selectedStatus) => {
    if (!userHasStatus) {
      await addToUserList(mediaId, selectedStatus, mediaType);
      setStatus(selectedStatus);
      setUserHasStatus(true);
    }
  };

  const handleRemoveStatus = async () => {
    if (userHasStatus) {
      await removeFromUserList(mediaId, mediaType);
      setStatus(null);
      setUserHasStatus(false);
    }
  };

  if (!mediaDetails) {
    return <div>Loading...</div>;
  }

  return (
    <div className={`${mediaType}-details`}>
      <div className="media-content">
        <img src={`http://localhost:8000${mediaDetails.photo_path}`} alt={mediaDetails.title} />
        <div className="media-info">
          <h1>{mediaDetails.title}</h1>
          <p>{mediaDetails.description}</p>
          <p>Release Date: {mediaDetails.release_date}</p>
          {mediaDetails.end_date && <p>End Date: {mediaDetails.end_date}</p>}
          <p>Type: {mediaDetails.type}</p>
          {mediaDetails.chapter_count && <p>Chapter Count: {mediaDetails.chapter_count}</p>}
          {mediaDetails.episode_count && <p>Episode Count: {mediaDetails.episode_count}</p>}
          <p>Average Rating: {mediaDetails.avg_rating}</p>

          {/* Статус и кнопка удаления */}
          {isLoggedIn && (
            <div>
              <label htmlFor="status-select">Change Status:</label>
              <select
                id="status-select"
                value={status || ""}
                onChange={(e) => handleStatusChange(e.target.value)}
                disabled={userHasStatus} // Отключаем select, если уже есть статус
              >
                <option value="">Select Status</option>
                {statusList.map((statusOption) => (
                  <option key={statusOption} value={statusOption}>
                    {statusOption.charAt(0).toUpperCase() + statusOption.slice(1)}
                  </option>
                ))}
              </select>
              {userHasStatus && (
                <button onClick={handleRemoveStatus}>Remove from List</button>
              )}
            </div>
          )}

          {mediaDetails.user_rating && <p>Your Rating: {mediaDetails.user_rating}</p>}

          {mediaDetails.user_review && (
            <div>
              <h3>Your Review:</h3>
              <p>{mediaDetails.user_review}</p>
            </div>
          )}
        </div>
      </div>

      {/* Каст медиа */}
      {mediaDetails.cast && (
        <div className="media-cast">
          <h2>Cast</h2>
          <ul>
            {mediaDetails.cast.map((castMember, index) => (
              <li key={index}>
                {castMember.person_name} as {castMember.character_name || 'Unknown Character'} ({castMember.person_role})
              </li>
            ))}
          </ul>
        </div>
      )}

      {/* Жанры медиа */}
      {mediaDetails.genres && (
        <div className="media-genres">
          <h2>Genres</h2>
          <ul>
            {mediaDetails.genres.map((genre, index) => (
              <li key={index}>{genre}</li>
            ))}
          </ul>
        </div>
      )}

      {/* Связанные медиа */}
      {mediaDetails.related_media && (
        <div className="related-media">
          <h2>Related Media</h2>
          <ul>
            {mediaDetails.related_media.map((related, index) => (
              <li key={index}>
                {related.related_title} ({related.relationship_type})
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
};

export default MediaDetails;