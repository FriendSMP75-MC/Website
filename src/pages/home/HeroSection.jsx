import { ArrowRight, ChevronRight, MessageCircle, Play } from 'lucide-react'
import heroImage from '../../assets/hero.png'

const heroActions = [
    { label: 'Play now', icon: Play, className: 'button-primary' },
    { label: 'Join Discord', icon: MessageCircle, className: 'button-secondary' },
]

export function HeroSection() {
    return (
        <section className="hero-section page-section" aria-labelledby="hero-title">
            <div className="hero-copy">
                <p className="eyebrow">Welcome to the community</p>
                <h1 id="hero-title">FriendSMP75</h1>
                <p className="hero-description">
                    FriendSMP75 is a survival experience built for long-term builders, explorers, and community-first players.
                    Join a focused, low-drama environment where every session feels friendly, collaborative.
                </p>
                <div className="hero-actions">
                    {heroActions.map(({ label, icon: Icon, className }) => (
                        <a className={`home-button ${className}`} href="#server" key={label}>
                            <Icon size={15} aria-hidden="true" />
                            <span>{label}</span>
                            {className === 'button-primary' && <ArrowRight size={14} aria-hidden="true" />}
                        </a>
                    ))}
                </div>
            </div>
            
        </section>
    )
}