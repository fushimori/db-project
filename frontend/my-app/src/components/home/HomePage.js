// src/components/HomePage.js
import React, { useState } from 'react';
import { useAuth } from '../../context/AuthContext';
import { backupDatabase, restoreDatabase } from '../../api/backup';
import PulsingIcon from './PulsingIcon'; // Импортируем компонент PulsingIcon
import './HomePage.css'; // Импортируем CSS-файл

const HomePage = () => {
  const { role } = useAuth();
  const [isBackupInProgress, setIsBackupInProgress] = useState(false);
  const [isRestoreInProgress, setIsRestoreInProgress] = useState(false);

  const handleBackup = async () => {
    setIsBackupInProgress(true);
    try {
      await backupDatabase();
      alert('Database backup completed successfully');
    } catch (error) {
      console.error('Error during backup:', error);
      alert('Error during backup');
    } finally {
      setIsBackupInProgress(false);
    }
  };

  const handleRestore = async () => {
    setIsRestoreInProgress(true);
    try {
      await restoreDatabase();
      alert('Database restore completed successfully');
    } catch (error) {
      console.error('Error during restore:', error);
      alert('Error during restore');
    } finally {
      setIsRestoreInProgress(false);
    }
  };

  return (
    <div className="home-page">
      {/* Контейнер для иконки и текста */}
      <div className="icon-container">
        <h2>DB Project</h2>
        <PulsingIcon /> {/* Пульсирующая иконка рядом с текстом */}
      </div>
      
      {/* Отображение кнопок только для администраторов */}
      {role === 'admin' && (
        <div className="admin-actions">
          <button onClick={handleBackup} disabled={isBackupInProgress}>
            {isBackupInProgress ? 'Backing up...' : 'Backup Database'}
          </button>
          <button onClick={handleRestore} disabled={isRestoreInProgress}>
            {isRestoreInProgress ? 'Restoring...' : 'Restore Database'}
          </button>
        </div>
      )}
    </div>
  );
};

export default HomePage;