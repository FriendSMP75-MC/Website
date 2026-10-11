import {
    Coins,
    HeartHandshake,
    Info,
    MessageCircle,
    ThumbsUp,
    Video,
    Vote as VoteIcon,
} from 'lucide-react'
import { Link } from 'react-router-dom'
import NavBar from '../../components/Navbar'
import { Footer } from '../../components/Footer'
import { DISCORD_INVITE_URL, YOUTUBE_URL } from '../../lib/links'
import './support.css'

const supportOptions = [
    {
        title: 'Vote for the server',
        description: 'A free vote boosts our listing visibility and helps new players find FriendSMP75.',
        icon: VoteIcon,
        to: '/vote',
    },
    {
        title: 'Join the Discord',
        description: 'Being part of the community — chatting, building, and taking part in events — is real support.',
        icon: MessageCircle,
        href: DISCORD_INVITE_URL,
    },
    {
        title: 'Watch our YouTube',
        description: 'Subscribe and watch server content to help the channel grow alongside the community.',
        icon: Video,
        href: YOUTUBE_URL,
    },
    {
        title: 'Spread the word',
        description: 'Tell friends about us. Word of mouth is how the best communities grow.',
        icon: ThumbsUp,
    },
]

function SupportCard({ title, description, icon: Icon, to, href }) {
    const content = (
        <>
            <div className="support-card-icon"><Icon size={17} aria-hidden="true" /></div>
            <h3>{title}</h3>
            <p>{description}</p>
        </>
    )

    if (to) {
        return (
            <Link className="support-card support-card-link" to={to}>
                {content}
            </Link>
        )
    }

    if (href) {
        return (
            <a className="support-card support-card-link" href={href} target="_blank" rel="noopener noreferrer">
                {content}
            </a>
        )
    }

    return <article className="support-card">{content}</article>
}

export default function Support() {
    return (
        <div className="support-page">
            <NavBar />
            <main className="support-content">
                <header className="support-intro">
                    <p className="eyebrow">Support us</p>
                    <h1>Support FriendSMP75</h1>
                    <p>The server is free to play, and every way of helping us out is appreciated.</p>
                </header>

                <aside className="support-notice" role="note">
                    <Info size={18} aria-hidden="true" />
                    <div>
                        <strong>Ads on this page — decision in progress</strong>
                        <p>
                            We are still deciding whether or not to add ads to this page. Nothing is set in stone
                            yet, and if we do add ads, we will keep them minimal and clearly communicated here first.
                        </p>
                    </div>
                </aside>

                <section className="support-group" aria-labelledby="ways-title">
                    <p className="eyebrow">Free ways to help</p>
                    <h2 id="ways-title">How you can support us.</h2>
                    <p className="support-group-description">
                        You never have to spend money to support the server. These options are free and make a real
                        difference.
                    </p>
                    <div className="support-card-grid">
                        {supportOptions.map((option) => <SupportCard key={option.title} {...option} />)}
                    </div>
                </section>

                <section className="support-cost-card" aria-labelledby="cost-title">
                    <div className="support-cost-icon"><Coins size={20} aria-hidden="true" /></div>
                    <p className="eyebrow">Always free</p>
                    <h2 id="cost-title">Playing on FriendSMP75 will always be free.</h2>
                    <p>
                        We cover the server costs ourselves for now. If we ever introduce optional donations or
                        sponsorships in the future, they will never give anyone an unfair advantage in game, and we
                        will announce it here and on Discord first.
                    </p>
                    <p className="support-cost-thanks">
                        <HeartHandshake size={14} aria-hidden="true" />
                        <span>Thank you for being part of the community — it means the world to us.</span>
                    </p>
                </section>
            </main>
            <Footer />
        </div>
    )
}
