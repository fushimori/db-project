import React, { useEffect, useState } from 'react';
import { getProfile } from '../../api/profile'; // Импортируем API-функцию
import './ProfilePage.css'; // Импортируем CSS для оформления
import { Link } from 'react-router-dom'; // Импортируем Link

const ProfilePage = () => {
  const [profile, setProfile] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchProfile = async () => {
      try {
        const data = await getProfile(); // Получаем данные профиля
        setProfile(data);
      } catch (error) {
        console.error('Error fetching profile:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchProfile();
  }, []);

  if (loading) {
    return <div>Loading...</div>;
  }

  if (!profile) {
    return <div>Error loading profile</div>;
  }

  return (
    <div className="profile-page">
      <div className="profile-header">
        <img
          src={`http://localhost:8000${profile.profile.photo_path}`}
          alt={profile.profile.username}
          className="profile-photo"
        />
        <h1>{profile.profile.username}</h1>
      </div>
      <div className="profile-section">
        <h2>Friends</h2>
        {profile.friends.length === 0 ? (
          <p>No friends yet.</p>
        ) : (
          <ul className="friends-list">
            {profile.friends.map((friend) => (
              <li key={friend.id} className="friend-item">
                <img
                  src={`http://localhost:8000${friend.photo_path}`}
                  alt={friend.username}
                  className="friend-photo"
                />
                <span>{friend.username}</span>
              </li>
            ))}
          </ul>
        )}
      </div>
      <div className="profile-section">
        <h2>Media List</h2>
        {profile.media_list.length === 0 ? (
          <p>No media items yet.</p>
        ) : (
          <ul className="media-list">
            {profile.media_list.map((media) => {
              let mediaType = media.type.toLowerCase(); // Приводим тип к нижнему регистру
              let mediaPath = '';

              // Определяем путь в зависимости от типа медиа
              switch (mediaType) {
                case 'anime':
                  mediaPath = `/anime/${media.id}`;
                  break;
                case 'manga':
                  mediaPath = `/manga/${media.id}`;
                  break;
                case 'movie':
                  mediaPath = `/movie/${media.id}`;
                  break;
                case 'book':
                  mediaPath = `/book/${media.id}`;
                  break;
                case 'series':
                  mediaPath = `/series/${media.id}`;
                  break;
                default:
                  mediaPath = `/media/${media.id}`; // По умолчанию
              }

              return (
                <li key={media.id} className="media-item">
                  <Link to={mediaPath} className="media-link">
                    <h3>{media.title}</h3>
                    <p>Type: {media.type}</p>
                    <p>Status: {media.status}</p>
                    <p className="score">{media.score ?? ''}</p> {/* Убираем ручной текст "Score: Not rated" */}
                  </Link>
                </li>
              );
            })}
          </ul>
        )}
      </div>
    </div>
  );
};

export default ProfilePage;