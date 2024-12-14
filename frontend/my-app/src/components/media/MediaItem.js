// src/components/MediaItem.js
import React from 'react';
import { Link } from 'react-router-dom';

const statusStyles = {
  watching: { color: 'blue' },
  completed: { color: 'green' },
  planned: { color: 'purple' },
  on_hold: { color: 'orange' },
  dropped: { color: 'red' }
};

const MediaItem = ({ media, status }) => {
  return (
    <div className="media-item">
      <Link to={`/${media.type}/${media.id}`}>
        <img src={`http://localhost:8000${media.photo_path}`} alt={media.title} />
        <h3 style={status ? statusStyles[status] : { color: 'black' }}>{media.title}</h3>
      </Link>
    </div>
  );
};

export default MediaItem;
