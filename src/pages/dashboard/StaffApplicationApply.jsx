import { useEffect, useMemo, useState } from 'react'
import {
    ArrowLeft,
    ClipboardCheck,
    LoaderCircle,
    Lock,
    Megaphone,
    MessageCircle,
    Shield,
    ShieldAlert,
} from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import NavBar from '../../components/Navbar'
import {
    checkStaffAccess,
    checkStaffApplication,
    getAnnouncements,
    getStaffApplicationStatus,
} from '../../lib/api'
import { supabase } from '../../lib/supabase'
import './dashboard.css'
import './staff-application.css'

const GENERIC_ERROR = 'Something went wrong. Please try again.'
const DISCORD_URL = 'https://discord.gg/K8ucVvjfge'
const TALLY_BASE_URL = 'https://tally.so/embed/KYkZ5K?alignLeft=1&hideTitle=1&dynamicHeight=1'

function getDisplayName(user) {
    if (!user) return 'Community Member'
    return user.user_metadata?.custom_claims?.global_name
        || user.user_metadata?.full_name
        || user.user_metadata?.user_name
        || user.user_metadata?.preferred_username
        || user.email
        || 'Community Member'
}

function buildTallyUrl(user) {
    const url = new URL(TALLY_BASE_URL)
    if (user?.id) {
        url.searchParams.set('user_uid', user.id)
        const username = getDisplayName(user)
        if (username && username !== 'Community Member') url.searchParams.set('username', username)
    }
    return url.toString()
}

function formatStatus(value) {
    const status = String(value || 'pending').trim()
    return status.charAt(0).toUpperCase() + status.slice(1).toLowerCase()
}

function statusTone(value) {
    const status = String(value || 'pending').toLowerCase()
    if (status === 'approved') return 'approved'
    if (status === 'rejected' || status === 'denied') return 'rejected'
    return 'pending'
}

function formatDate(value) {
    if (!value) return ''
    const date = new Date(value)
    return Number.isNaN(date.getTime())
        ? String(value)
        : date.toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric' })
}

function announcementExcerpt(body) {
    return String(body || '')
        .replace(/[#*_>`~|-]+/g, ' ')
        .replace(/\s+/g, ' ')
        .trim()
}

export default function StaffApplicationApply() {
    const navigate = useNavigate()
    const [session, setSession] = useState(null)
    const [authReady, setAuthReady] = useState(!supabase)
    const [loading, setLoading] = useState(true)
    const [isOpen, setIsOpen] = useState(false)
    const [isStaff, setIsStaff] = useState(false)
    const [application, setApplication] = useState(null)
    const [announcements, setAnnouncements] = useState([])
    const [signInError, setSignInError] = useState('')

    useEffect(() => {
        if (!supabase) return undefined
        supabase.auth.getSession().then(({ data }) => {
            setSession(data.session)
            setAuthReady(true)
        })
        const { data: listener } = supabase.auth.onAuthStateChange((_event, nextSession) => setSession(nextSession))
        return () => listener.subscription.unsubscribe()
    }, [])

    // Resolve applications open/closed, staff membership and the member's own
    // application in one pass. All state updates run after awaits so the effect
    // body itself never sets state synchronously.
    useEffect(() => {
        if (!authReady) return undefined
        let active = true

        const load = async () => {
            let open
            let staff = false
            let submitted = null

            try {
                const payload = await getStaffApplicationStatus()
                const rows = Array.isArray(payload) ? payload : [payload]
                const statusRecord = rows.find((row) => row && typeof row === 'object' && 'is_open' in row) || {}
                open = Boolean(statusRecord.is_open)
            } catch {
                open = false
            }

            if (session) {
                try {
                    staff = Boolean(await checkStaffAccess(session))
                } catch {
                    staff = false
                }

                if (!staff) {
                    try {
                        const rows = await checkStaffApplication(session)
                        const ownRow = Array.isArray(rows)
                            ? rows.find((row) => String(row?.user_id || '') === String(session.user.id))
                            : null
                        if (ownRow) submitted = { status: ownRow.status || 'pending' }
                    } catch {
                        submitted = null
                    }
                }
            }

            if (!active) return
            setIsOpen(open)
            setIsStaff(staff)
            setApplication(submitted)
            setLoading(false)
        }

        load()

        return () => { active = false }
    }, [authReady, session])

    useEffect(() => {
        let active = true

        getAnnouncements()
            .then((rows) => {
                if (!active || !Array.isArray(rows)) return
                const latest = rows
                    .filter((row) => row && (row.announcement_title || row.announcement_body))
                    .sort((first, second) => {
                        const firstTime = new Date(first.created_at || 0).getTime() || 0
                        const secondTime = new Date(second.created_at || 0).getTime() || 0
                        return secondTime - firstTime || Number(second.id || 0) - Number(first.id || 0)
                    })
                    .slice(0, 3)
                setAnnouncements(latest)
            })
            .catch(() => {})

        return () => { active = false }
    }, [])

    const displayName = getDisplayName(session?.user)
    const tallyUrl = useMemo(() => buildTallyUrl(session?.user), [session])
    const tone = application ? statusTone(application.status) : 'pending'

    const signInWithDiscord = async () => {
        if (!supabase) {
            setSignInError(GENERIC_ERROR)
            return
        }
        setSignInError('')
        const { error: oauthError } = await supabase.auth.signInWithOAuth({
            provider: 'discord',
            options: { redirectTo: `${window.location.origin}/dashboard/my-application` },
        })
        if (oauthError) setSignInError(GENERIC_ERROR)
    }

    const scrollToAnnouncements = () => {
        document.getElementById('staff-apply-announcements')?.scrollIntoView({ behavior: 'smooth', block: 'start' })
    }

    return (
        <div className="dashboard-page staff-apply-page">
            <NavBar />
            <main className="staff-apply-content">
                <button className="dashboard-back-button" type="button" onClick={() => navigate('/dashboard')}><ArrowLeft size={16} /> Back to dashboard</button>

                <header className="announcement-hero staff-apply-hero">
                    <div className="staff-apply-hero-top">
                        <div>
                            <p className="eyebrow">Member tool</p>
                            <h1>Staff Application</h1>
                        </div>
                        {authReady && !loading && (
                            <span className={`staff-apply-open-badge${isOpen ? ' staff-apply-open-badge-open' : ''}`}>{isOpen ? 'Open' : 'Closed'}</span>
                        )}
                    </div>
                    <p>Apply to join the FriendSMP75 staff team. Read rules in Discord and follow announcements for updates.</p>
                </header>

                {!authReady || loading ? (
                    <section className="dashboard-panel dashboard-loading">
                        <LoaderCircle className="gallery-manager-spinner" size={22} />
                        Checking application status...
                    </section>
                ) : !session ? (
                    <section className="dashboard-panel announcement-denied staff-apply-panel">
                        <ShieldAlert size={24} />
                        <h2>You must be logged in to apply</h2>
                        <p>Please sign in with Discord to continue.</p>
                        {signInError && <p className="staff-apply-error">{signInError}</p>}
                        <div className="staff-apply-actions">
                            <button className="dashboard-primary-button" type="button" onClick={signInWithDiscord}><MessageCircle size={15} /> Sign in with Discord</button>
                            <a className="dashboard-secondary-button" href={DISCORD_URL} target="_blank" rel="noreferrer">Open Discord</a>
                        </div>
                    </section>
                ) : isStaff ? (
                    <section className="dashboard-panel staff-apply-panel">
                        <div className="staff-apply-heading">
                            <span className="dashboard-icon staff-apply-icon-staff"><Shield size={20} /></span>
                            <h2>Staff Member</h2>
                            <span className="request-status request-status-approved">Approved</span>
                        </div>
                        <div className="staff-apply-divider" />
                        <p className="staff-apply-greeting">Hey {displayName},</p>
                        <p>You are already an approved member of the FriendSMP75 staff team. Your application was accepted and you are part of the team!</p>
                        <div className="staff-apply-status-row">
                            <span>Application Status:</span>
                            <span className="request-status request-status-approved">Approved</span>
                        </div>
                        <div className="staff-apply-actions">
                            <a className="dashboard-secondary-button" href={DISCORD_URL} target="_blank" rel="noreferrer"><MessageCircle size={15} /> Open Discord</a>
                        </div>
                    </section>
                ) : application ? (
                    <section className="dashboard-panel staff-apply-panel">
                        <div className="staff-apply-heading">
                            <span className="dashboard-icon"><ClipboardCheck size={20} /></span>
                            <h2>Application Received</h2>
                            <span className={`request-status request-status-${tone}`}>{formatStatus(application.status)}</span>
                        </div>
                        <div className="staff-apply-divider" />
                        <p className="staff-apply-greeting">Hey {displayName},</p>
                        <p>You have already submitted an application for the FriendSMP75 staff team. Our administration group is carefully reviewing your answers!</p>
                        <div className="staff-apply-status-row">
                            <span>Review Status:</span>
                            <span className={`request-status request-status-${tone}`}>{formatStatus(application.status)}</span>
                        </div>
                        <div className="staff-apply-actions">
                            <button className="dashboard-primary-button" type="button" onClick={scrollToAnnouncements}><Megaphone size={15} /> View Announcements</button>
                            <a className="dashboard-secondary-button" href={DISCORD_URL} target="_blank" rel="noreferrer"><MessageCircle size={15} /> Check Announcements on Discord</a>
                        </div>
                    </section>
                ) : !isOpen ? (
                    <section className="dashboard-panel staff-apply-panel">
                        <div className="staff-apply-heading">
                            <span className="dashboard-icon staff-apply-icon-locked"><Lock size={20} /></span>
                            <h2>Applications are currently closed</h2>
                        </div>
                        <p>Staff applications are closed right now. Please watch for updates in our Discord or announcements.</p>
                        <div className="staff-apply-actions">
                            <a className="dashboard-primary-button" href={DISCORD_URL} target="_blank" rel="noreferrer"><MessageCircle size={15} /> Open Discord</a>
                            <button className="dashboard-secondary-button" type="button" onClick={scrollToAnnouncements}><Megaphone size={15} /> View Announcements</button>
                        </div>
                    </section>
                ) : (
                    <section className="dashboard-panel staff-apply-frame" aria-label="Staff application form">
                        <iframe
                            title="FriendSMP75 staff application form"
                            src={tallyUrl}
                            sandbox="allow-scripts allow-same-origin allow-forms"
                            loading="lazy"
                        />
                        <p>The form is hosted by Tally. If it does not load, refresh the page or ask for help on <a href={DISCORD_URL} target="_blank" rel="noreferrer">Discord</a>.</p>
                    </section>
                )}

                <section className="dashboard-panel staff-apply-announcements" id="staff-apply-announcements" aria-labelledby="staff-apply-announcements-title">
                    <div className="staff-apply-announcements-heading">
                        <span className="dashboard-icon"><Megaphone size={18} /></span>
                        <div>
                            <h2 id="staff-apply-announcements-title">Latest announcements</h2>
                            <p>Updates from the team — the same announcements are posted in our Discord.</p>
                        </div>
                        <a className="dashboard-secondary-button" href={DISCORD_URL} target="_blank" rel="noreferrer">Open Discord</a>
                    </div>
                    {announcements.length === 0 ? (
                        <p className="staff-apply-announcements-empty">No announcements right now. Check Discord for the latest updates.</p>
                    ) : (
                        <ul className="staff-apply-announcements-list">
                            {announcements.map((item) => (
                                <li key={item.id || item.announcement_title}>
                                    <div className="staff-apply-announcements-meta">
                                        <strong>{item.announcement_title || 'Announcement'}</strong>
                                        <span>{item.author || 'Staff'}{item.created_at ? ` · ${formatDate(item.created_at)}` : ''}</span>
                                    </div>
                                    <p>{announcementExcerpt(item.announcement_body)}</p>
                                </li>
                            ))}
                        </ul>
                    )}
                </section>
            </main>
        </div>
    )
}