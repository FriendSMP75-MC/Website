import { useEffect, useState } from 'react'
import { AlertTriangle, ArrowLeft, LoaderCircle, ShieldAlert } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { checkOwner, checkStaffAccess } from '../../lib/api'
import NavBar from '../../components/Navbar'
import { supabase } from '../../lib/supabase'
import './dashboard.css'

export default function ServerAccess() {
    const navigate = useNavigate()
    const [session, setSession] = useState(null)
    const [authReady, setAuthReady] = useState(!supabase)
    const [checking, setChecking] = useState(true)
    const [allowed, setAllowed] = useState(false)

    useEffect(() => {
        if (!supabase) return undefined
        supabase.auth.getSession().then(({ data }) => { setSession(data.session); setAuthReady(true) })
        const { data: listener } = supabase.auth.onAuthStateChange((_event, nextSession) => setSession(nextSession))
        return () => listener.subscription.unsubscribe()
    }, [])

    useEffect(() => {
        if (!session) return undefined
        let active = true
        Promise.all([checkOwner(session), checkStaffAccess(session)])
            .then(([isOwner, isStaff]) => {
                if (!active) return
                setAllowed(isOwner || isStaff)
            })
            .catch(() => { if (active) setChecking(false) })
            .finally(() => { if (active) setChecking(false) })
        return () => { active = false }
    }, [session])

    return (
        <div className="dashboard-page server-access-page">
            <NavBar />
            <main className="dashboard-content">
                <button className="dashboard-back-button" type="button" onClick={() => navigate('/dashboard')}><ArrowLeft size={16} /> Back to dashboard</button>
                <header className="dashboard-blue-hero"><p className="eyebrow">Staff tool</p><h1>Server Access</h1><p>Server control is managed through the hosting provider.</p></header>
                {!authReady || checking ? <section className="dashboard-panel dashboard-loading"><LoaderCircle className="gallery-manager-spinner" size={22} />Checking staff access...</section> : !session || !allowed ? <section className="dashboard-panel announcement-denied"><ShieldAlert size={24} /><h2>{session ? 'Staff access required' : 'Sign in required'}</h2><p>{session ? 'This tool is available to staff members only.' : 'Please sign in with Discord to continue.'}</p></section> : (
                    <>
                        <section className="dashboard-panel dashboard-warning"><AlertTriangle size={26} /><h2>⚠ Warning</h2><p>The Server Access tool has been disabled. Please use Hosting provider website for access.</p></section>
                        <section className="dashboard-panel announcement-denied"><ShieldAlert size={24} /><h2>Access moved</h2><p>Please use Hosting provider website for access</p></section>
                    </>
                )}
            </main>
        </div>
    )
}
