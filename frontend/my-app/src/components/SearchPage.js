// import React, { useEffect, useState } from 'react';
// // import { searchMedia } from '../api/media';
// import MediaItem from './MediaItem';

// const SearchPage = () => {
//   const [searchQuery, setSearchQuery] = useState('');
//   const [category, setCategory] = useState('anime');
//   const [results, setResults] = useState([]);

//   useEffect(() => {
//     const fetchSearchResults = async () => {
//       try {
//         const data = await searchMedia(searchQuery, category);
//         setResults(data.results);
//       } catch (error) {
//         console.error("Error searching media:", error);
//       }
//     };

//     // Отправляем запрос только если searchQuery не пустой
//     if (searchQuery) {
//       fetchSearchResults();
//     } else {
//       setResults([]); // Очищаем результаты, если запрос пустой
//     }
//   }, [searchQuery, category]);

//   return (
//     <div>
//       <h2>Search</h2>
//       <input
//         type="text"
//         placeholder="Search..."
//         value={searchQuery}
//         onChange={(e) => setSearchQuery(e.target.value)}
//       />
//       <select value={category} onChange={(e) => setCategory(e.target.value)}>
//         <option value="anime">Anime</option>
//         <option value="manga">Manga</option>
//         <option value="movie">Movie</option>
//         <option value="book">Book</option>
//         <option value="series">Series</option>
//         <option value="person">Person</option>
//       </select>
//       <div className="search-results">
//         {results.length > 0 ? (
//           results.map((result) => (
//             <div key={result.id}>
//               <MediaItem media={result} status={result.status} />
//             </div>
//           ))
//         ) : (
//           <p>No results found</p>
//         )}
//       </div>
//     </div>
//   );
// };

// export default SearchPage;