import './App.css'
import { useEffect, useState } from 'react'
import { Navigate, Route, Routes } from 'react-router-dom'
import About from './pages/about/About.jsx'
import Announcements from './pages/announcements/Announcements.jsx'
import Support from './pages/support/Support.jsx'
import Dashboard from './pages/dashboard/Dashboard.jsx'
import AnnouncementManager from './pages/dashboard/AnnouncementManager.jsx'
import GroupPhotoManager from './pages/dashboard/GroupPhotoManager.jsx'
import DmAnnouncer from './pages/dashboard/DmAnnouncer.jsx'
import ServerAccess from './pages/dashboard/ServerAccess.jsx'
import StaffApplications from './pages/dashboard/StaffApplications.jsx'
import StaffApplicationApply from './pages/dashboard/StaffApplicationApply.jsx'
import MemoryRequests from './pages/dashboard/MemoryRequests.jsx'
import MemoriesUpload from './pages/dashboard/MemoriesUpload.jsx'
import PunishmentHistory from './pages/dashboard/PunishmentHistory.jsx'
import Gallery from './pages/gallery/Gallery.jsx'
import Status from './pages/status/Status.jsx'
import Home from './pages/home/Home.jsx'
import Vote from './pages/vote/Vote.jsx'
import { supabase } from './lib/supabase.js'

function useDashboardSession() {
    const [session, setSession] = useState(null)
    const [authReady, setAuthReady] = useState(!supabase)

    useEffect(() => {
        if (!supabase) return undefined
        supabase.auth.getSession().then(({ data }) => {
            setSession(data.session)
            setAuthReady(true)
        })
        const { data: listener } = supabase.auth.onAuthStateChange((_event, nextSession) => setSession(nextSession))
        return () => listener.subscription.unsubscribe()
    }, [])

    return { session, authReady }
}

function DashboardRoute({ children }) {
    const { session, authReady } = useDashboardSession()

    if (!authReady) {
        return null
    }

    if (!session) {
        return <Navigate to="/dashboard" replace />
    }

    return children
}

export default function App (){
  return (
    <Routes>
      <Route path="/" element={<div className="route-page"><Home /></div>} />
      <Route path="/about" element={<div className="route-page"><About /></div>} />
      <Route path="/status" element={<div className="route-page"><Status /></div>} />
      <Route path="/gallery" element={<div className="route-page"><Gallery /></div>} />
      <Route path="/vote" element={<div className="route-page"><Vote /></div>} />
      <Route path="/announcements" element={<div className="route-page"><Announcements /></div>} />
      <Route path="/support" element={<div className="route-page"><Support /></div>} />
      <Route path="/dashboard" element={<div className="route-page"><Dashboard /></div>} />
      <Route path="/dashboard/announcements" element={<DashboardRoute><div className="route-page"><AnnouncementManager /></div></DashboardRoute>} />
      <Route path="/dashboard/gallery-upload" element={<DashboardRoute><div className="route-page"><GroupPhotoManager /></div></DashboardRoute>} />
      <Route path="/dashboard/dm-announcer" element={<DashboardRoute><div className="route-page"><DmAnnouncer /></div></DashboardRoute>} />
      <Route path="/dashboard/server-access" element={<DashboardRoute><div className="route-page"><ServerAccess /></div></DashboardRoute>} />
      <Route path="/dashboard/staff-applications" element={<DashboardRoute><div className="route-page"><StaffApplications /></div></DashboardRoute>} />
      <Route path="/dashboard/memory-requests" element={<DashboardRoute><div className="route-page"><MemoryRequests /></div></DashboardRoute>} />
      <Route path="/dashboard/memories-upload" element={<DashboardRoute><div className="route-page"><MemoriesUpload /></div></DashboardRoute>} />
      <Route path="/dashboard/my-application" element={<div className="route-page"><StaffApplicationApply /></div>} />
      <Route path="/dashboard/punishments" element={<div className="route-page"><PunishmentHistory /></div>} />
    </Routes>
  )
};