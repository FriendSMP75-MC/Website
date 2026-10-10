import { Mail, MessageCircle, Video } from 'lucide-react'
import logo from '../assets/logo.jpg'

const navigationLinks = ['Home', 'About', 'Status', 'Gallery']
const communityLinks = ['Discord', 'YouTube', 'Announcements', 'Support Us']
const connectLinks = [
    { label: 'YouTube', icon: Video },
    { label: 'Discord', icon: MessageCircle },
    { label: 'Email', icon: Mail },
]

function FooterLink({ children, icon: Icon }) {
    return (
        <a className="footer-link" href="#">
            {Icon && <Icon size={13} aria-hidden="true" />}
            <span>{children}</span>
        </a>
    )
}

export function Footer() {
    return (
        <footer className="site-footer" aria-label="Site footer">
            <div className="footer-main">
                <div className="footer-brand-column">
                    <a className="footer-brand" href="/" aria-label="FriendSMP75 home">
                        <img src={logo} alt="" />
                        <strong>FriendSMP75</strong>
                    </a>
                    <p className="footer-description">
                        A peaceful, community-first Minecraft server where collaboration matters more than competition.
                    </p>
                    <p className="footer-note">We are not affiliated with Minecraft or Mojang AB.</p>
                </div>

                <div className="footer-link-group">
                    <p className="footer-heading">Navigate</p>
                    {navigationLinks.map((label) => <FooterLink key={label}>{label}</FooterLink>)}
                </div>

                <div className="footer-link-group">
                    <p className="footer-heading">Community</p>
                    {communityLinks.map((label) => <FooterLink key={label}>{label}</FooterLink>)}
                </div>

                <div className="footer-link-group">
                    <p className="footer-heading">Connect</p>
                    {connectLinks.map(({ label, icon }) => (
                        <FooterLink key={label} icon={icon}>{label}</FooterLink>
                    ))}
                </div>
            </div>

            <div className="footer-bottom">
                <span>FriendSMP75</span>
                <span>Not affiliated with Minecraft or Mojang AB.</span>
            </div>
        </footer>
    )
}
