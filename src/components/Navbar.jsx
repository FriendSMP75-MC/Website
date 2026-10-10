import { useEffect, useState } from 'react'
import {
    BarChart3,
    CircleHelp,
    Home,
    LogIn,
    LogOut,
    Menu,
    Megaphone,
    PanelTop,
    ShoppingBag,
    UserRound,
    Vote,
    X,
} from 'lucide-react'
import logo from "../assets/logo.jpg";
import { supabase } from '../lib/supabase'
import { Link, useLocation } from 'react-router-dom'

const iconEndpoint = import.meta.env.VITE_SERVER_ICON_ENDPOINT

export default function NavBar(){
    const location = useLocation()
    const [menuOpen, setMenuOpen] = useState(false)
    const [session, setSession] = useState(null)
    const [authOpen, setAuthOpen] = useState(false)
    const [email, setEmail] = useState('')
    const [password, setPassword] = useState('')
    const [authError, setAuthError] = useState('')
    const [authLoading, setAuthLoading] = useState(false)
    const [serverIcon, setServerIcon] = useState(logo)

    useEffect(() => {
        if (!iconEndpoint) return undefined

        const controller = new AbortController()
        let objectUrl

        fetch(iconEndpoint, { signal: controller.signal })
            .then(async (response) => {
                if (!response.ok) throw new Error('Unable to load server icon')
                const contentType = response.headers.get('content-type') || ''
                if (contentType.includes('application/json')) {
                    const payload = await response.json()
                    return payload.icon || payload.url || payload.image
                }
                const blob = await response.blob()
                objectUrl = URL.createObjectURL(blob)
                return objectUrl
            })
            .then((iconUrl) => {
                if (iconUrl) setServerIcon(iconUrl)
            })
            .catch(() => {})

        return () => {
            controller.abort()
            if (objectUrl) URL.revokeObjectURL(objectUrl)
        }
    }, [])

    useEffect(() => {
        if (!supabase) return undefined

        supabase.auth.getSession().then(({ data }) => setSession(data.session))
        const { data: listener } = supabase.auth.onAuthStateChange((_event, nextSession) => {
            setSession(nextSession)
        })

        return () => listener.subscription.unsubscribe()
    }, [])

    const handleAuthSubmit = async (event) => {
        event.preventDefault()
        if (!supabase) {
            setAuthError('Supabase is not configured. Add VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY.')
            return
        }

        setAuthLoading(true)
        setAuthError('')
        const { error } = await supabase.auth.signInWithPassword({ email, password })
        setAuthLoading(false)

        if (error) {
            setAuthError(error.message)
            return
        }

        setPassword('')
        setAuthOpen(false)
    }

    const handleLogout = async () => {
        await supabase?.auth.signOut()
    }

    const primaryLinks = [
        { label: 'Home', icon: Home, href: '/' },
        { label: 'About', icon: CircleHelp, href: '/about' },
        { label: 'Status', icon: BarChart3, href: '/status' },
        { label: 'Gallery', icon: PanelTop, href: '#' },
        { label: 'Announcements', icon: Megaphone, href: '#' },
        { label: 'Support Us', icon: ShoppingBag, href: '#' },
        { label: 'Vote', icon: Vote, href: '#' },
    ]

    return (
        <nav className="navbar" aria-label="Main navigation">
            <Link className="brand" to="/" aria-label="FriendSMP75 home">
                <img className="brand-logo" src={serverIcon} alt="FriendSMP75 logo" />
                <span className="brand-name">FriendSMP75</span>
            </Link>

            <button
                className={`menu-toggle${menuOpen ? ' menu-toggle-open' : ''}`}
                type="button"
                aria-label={menuOpen ? 'Close navigation menu' : 'Open navigation menu'}
                aria-expanded={menuOpen}
                onClick={() => setMenuOpen(!menuOpen)}
            >
                {menuOpen ? <X size={19} /> : <Menu size={19} />}
            </button>

            <div className={`nav-content${menuOpen ? ' nav-content-open' : ''}`}>
                <div className="nav-links">
                    {primaryLinks.map(({ label, icon: Icon, href }) => (
                        <Link className={`nav-link${location.pathname === href ? ' nav-link-active' : ''}`} to={href} key={label}>
                            <Icon size={13} strokeWidth={2.2} aria-hidden="true" />
                            <span>{label}</span>
                        </Link>
                    ))}
                </div>

                <div className="nav-actions">
                    {session && (
                        <a className="nav-action nav-action-dashboard" href="#dashboard">
                            <UserRound size={14} aria-hidden="true" />
                            <span>Dashboard</span>
                        </a>
                    )}
                    {session ? (
                        <button className="nav-action nav-action-button" type="button" onClick={handleLogout}>
                            <LogOut size={14} aria-hidden="true" />
                            <span>Logout</span>
                        </button>
                    ) : (
                        <button className="nav-action nav-action-button" type="button" onClick={() => setAuthOpen(!authOpen)}>
                            <LogIn size={14} aria-hidden="true" />
                            <span>Login</span>
                        </button>
                    )}
                </div>
            </div>

            {!session && authOpen && (
                <form className="auth-form" onSubmit={handleAuthSubmit}>
                    <label>
                        Email
                        <input type="email" value={email} onChange={(event) => setEmail(event.target.value)} required />
                    </label>
                    <label>
                        Password
                        <input type="password" value={password} onChange={(event) => setPassword(event.target.value)} required />
                    </label>
                    {authError && <p className="auth-error" role="alert">{authError}</p>}
                    <button className="auth-submit" type="submit" disabled={authLoading}>
                        {authLoading ? 'Signing in...' : 'Sign in'}
                    </button>
                </form>
            )}
        </nav>
    )
}