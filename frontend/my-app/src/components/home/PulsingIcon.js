import React, { useEffect, useState } from 'react';

const PulsingIcon = () => {
  const [icon, setIcon] = useState(null);

  // Загружаем SVG с бэкенда
  useEffect(() => {
    const fetchIcon = async () => {
      try {
        const response = await fetch('http://localhost:8000/static/icon.svg'); // Замените на правильный путь
        const svgText = await response.text();
        setIcon(svgText);
      } catch (error) {
        console.error("Error fetching icon:", error);
      }
    };

    fetchIcon();
  }, []);

  const handleClick = () => {
    window.location.href = 'https://github.com/fushimori/db-project'; // Ссылка на ваш репозиторий
  };

  return (
    <div onClick={handleClick} className="pulsing-icon">
      {/* Динамически загруженная иконка */}
      <div dangerouslySetInnerHTML={{ __html: icon }} />
    </div>
  );
};

export default PulsingIcon;
