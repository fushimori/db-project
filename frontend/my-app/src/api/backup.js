import axios from 'axios';

const API_URL = 'http://localhost:8000';  // Маршрут для админов

// Функция для создания бэкапа базы данных
export const backupDatabase = async () => {
  const token = localStorage.getItem('token');
  
  try {
    const response = await axios.post(`${API_URL}/admin/backup`, {}, {
      headers: {
        'Authorization': `Bearer ${token}`,
      },
    });
    return response.data;
  } catch (error) {
    console.error('Error during backup:', error);
    throw error;
  }
};

// Функция для восстановления базы данных
export const restoreDatabase = async () => {
  const token = localStorage.getItem('token');
  
  try {
    const response = await axios.post(`${API_URL}/admin/restore`, {}, {
      headers: {
        'Authorization': `Bearer ${token}`,
      },
    });
    return response.data;
  } catch (error) {
    console.error('Error during restore:', error);
    throw error;
  }
};
