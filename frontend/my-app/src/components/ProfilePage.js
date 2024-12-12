import React, { useEffect, useState } from 'react';
import { getProfile } from '../api/profile'; // Импортируем API-функцию

const ProfilePage = () => {
  const [profileData, setProfileData] = useState(null);

  useEffect(() => {
    const fetchProfile = async () => {
      try {
        const data = await getProfile();
        setProfileData(data.profile);
      } catch (error) {
        console.error("Error fetching profile data:", error);
      }
    };

    fetchProfile();
  }, []);

  if (!profileData) {
    return <div>Loading...</div>;
  }

  return (
    <div className="profile-page">
      <h1>Profile</h1>
      <div className="profile-info">
        <img src={`http://localhost:8000${profileData.photo_path}`} alt={profileData.username} />
        <h2>{profileData.username}</h2>
      </div>
    </div>
  );
};

export default ProfilePage;