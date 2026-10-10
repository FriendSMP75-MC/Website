import './App.css'
import { Route, Routes } from 'react-router-dom'
import About from './pages/About.jsx'
import Status from './pages/Status.jsx'
import Home from './pages/home/Home.jsx'

export default function App (){
  return (
    <Routes>
      <Route path="/" element={<div className="route-page"><Home /></div>} />
      <Route path="/about" element={<div className="route-page"><About /></div>} />
      <Route path="/status" element={<div className="route-page"><Status /></div>} />
    </Routes>
  )
};