import { useState } from 'react'
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

export default function NavBar(){
    const [menuOpen, setMenuOpen] = useState(false)
    const [loggedIn, setLoggedIn] = useState(false)

    const primaryLinks = [
        { label: 'Home', icon: Home },
        { label: 'About', icon: CircleHelp },
        { label: 'Status', icon: BarChart3 },
        { label: 'Gallery', icon: PanelTop },
        { label: 'Announcements', icon: Megaphone },
        { label: 'Support Us', icon: ShoppingBag },
        { label: 'Vote', icon: Vote },
    ]

    return (
        <nav className="navbar" aria-label="Main navigation">
            <a className="brand" href="/" aria-label="FriendSMP75 home">
                <img className="brand-logo" src={logo} alt="FriendSMP75 logo" />
                <span className="brand-name">FriendSMP75</span>
            </a>

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
                    {primaryLinks.map(({ label, icon: Icon }) => (
                        <a className={`nav-link${label === 'Home' ? ' nav-link-active' : ''}`} href="#" key={label}>
                            <Icon size={13} strokeWidth={2.2} aria-hidden="true" />
                            <span>{label}</span>
                        </a>
                    ))}
                </div>

                <div className="nav-actions">
                    <a className="nav-action nav-action-dashboard" href="#dashboard">
                        <UserRound size={14} aria-hidden="true" />
                        <span>Dashboard</span>
                    </a>
                    <button
                        className="nav-action nav-action-button"
                        type="button"
                        onClick={() => setLoggedIn(!loggedIn)}
                    >
                        {loggedIn ? <LogOut size={14} aria-hidden="true" /> : <LogIn size={14} aria-hidden="true" />}
                        <span>{loggedIn ? 'Logout' : 'Login'}</span>
                    </button>
                </div>
            </div>
        </nav>
    )
}