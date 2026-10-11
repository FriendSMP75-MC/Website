import { useEffect, useState } from 'react'
import { ArrowLeft, CheckCircle2, LoaderCircle, Play, RotateCcw, ShieldAlert, Square } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { ConfirmDialog } from '../../components/ConfirmDialog'
import { checkOwner, checkStaffAccess, getServerAccessStatus, serverPowerAction } from '../../lib/api'
import NavBar from '../../components/Navbar'
import { supabase } from '../../lib/supabase'
import './dashboard.css'

const GENERIC_ERROR = 'Something went wrong. Please try again.'

export default function ServerAccess() {
    const navigate = useNavigate()
    const [session, setSession] = useState(null)
    const [authReady, setAuthReady] = useState(!supabase)
    const [checking, setChecking] = useState(true)
    const [allowed, setAllowed] = useState(false)
    const [status, setStatus] = useState('unknown')
    const [pendingAction, setPendingAction] = useState('')
    const [running, setRunning] = useState(false)
    const [error, setError] = useState('')

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
            .then(async ([isOwner, isStaff]) => {
                if (!active) return
                setAllowed(isOwner || isStaff)
                if (isOwner || isStaff) {
                    const result = await getServerAccessStatus()
                    if (active) setStatus(result?.status || 'unknown')
                }
            })
            .catch(() => { if (active) setError(GENERIC_ERROR) })
            .finally(() => { if (active) setChecking(false) })
        return () => { active = false }
    }, [session])

    const runAction = async () => {
        setRunning(true)
        setPendingAction('')
        setError('')
        try {
            const result = await serverPowerAction(session, pendingAction)
            setStatus(result?.status || (pendingAction === 'stop' ? 'stopped' : 'starting'))
        } catch {
            setError(GENERIC_ERROR)
        } finally {
            setRunning(false)
        }
    }

    const actionLabels = { start: 'Start', restart: 'Restart', stop: 'Stop' }

    return (
        <div className="dashboard-page server-access-page">
            <NavBar />
            <main className="dashboard-content">
                <button className="dashboard-back-button" type="button" onClick={() => navigate('/dashboard')}><ArrowLeft size={16} /> Back to dashboard</button>
                <header className="dashboard-blue-hero"><p className="eyebrow">Staff tool</p><h1>Server Control Center</h1><p>Manage the FriendSMP75 server power state.</p></header>
                {!authReady || checking ? <section className="dashboard-panel dashboard-loading"><LoaderCircle className="gallery-manager-spinner" size={22} />Checking staff access...</section> : !session || !allowed ? <section className="dashboard-panel announcement-denied"><ShieldAlert size={24} /><h2>{session ? 'Staff access required' : 'Sign in required'}</h2><p>{session ? 'This tool is available to staff members only.' : 'Please sign in with Discord to continue.'}</p></section> : (
                    <>
                        <section className="server-status-panel dashboard-panel"><span>Current Server Status</span><strong className={`server-status-${status}`}><CheckCircle2 size={19} />{status}</strong></section>
                        <h2 className="server-actions-title">Power Actions</h2>
                        {error && <p className="dashboard-error" role="alert">{error}</p>}
                        <div className="server-actions">
                            <button className="server-action-start" type="button" onClick={() => setPendingAction('start')}><Play size={15} />Start</button>
                            <button className="server-action-restart" type="button" onClick={() => setPendingAction('restart')}><RotateCcw size={15} />Restart</button>
                            <button className="server-action-stop" type="button" onClick={() => setPendingAction('stop')}><Square size={15} />Stop</button>
                        </div>
                    </>
                )}
            </main>
            <ConfirmDialog open={Boolean(pendingAction)} title={`${actionLabels[pendingAction] || 'Run'} server action?`} message={`The server will receive the ${pendingAction} command.`} confirmLabel={actionLabels[pendingAction] || 'Confirm'} onConfirm={runAction} onCancel={() => setPendingAction('')} />
            {running && <div className="server-action-loading"><LoaderCircle size={17} />Processing...</div>}
        </div>
    )
}
