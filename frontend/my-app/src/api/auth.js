// src/api/auth.js
import axios from 'axios';

const API_URL = 'http://localhost:8000';

export const registerUser = async (username, email, password) => {
  try {
    const response = await axios.post(`${API_URL}/users/register`, { username, email, password });
    return response.data;
  } catch (error) {
    console.error('Registration error:', error);
    throw error;
  }
};

export const loginUser = async (username, password) => {
    try {
        const response = await axios.post('http://localhost:8000/users/token', 
        new URLSearchParams({
            username: username,
            password: password
        }), {
            headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
            }
        }
        );
        return response.data;
    } catch (error) {
        console.error('Login error:', error);
        throw error;
    }
};
  
  
