import { useEffect } from 'react'
import {
Globe2,
HeartHandshake,
Mail,
MessageCircle,
ShieldCheck,
UsersRound,
Video,
} from 'lucide-react'
import NavBar from '../../components/Navbar'
import { Footer } from '../../components/Footer'
import { DISCORD_INVITE_URL, EMAIL_URL, YOUTUBE_URL } from '../../lib/links'
import './about.css'
const values = [
{
title: 'Community-Led',
description: 'Your voice shapes updates. Every player counts, and we listen to feedback as the server grows and evolves.',
icon: UsersRound,
},
{
title: 'Safe & Respectful',
description: 'Moderated for positive play. We maintain a safe, peaceful environment where everyone is treated with kindness and respect.',
icon: ShieldCheck,
},
{
title: 'Peaceful Survival',
description: 'Build and progress together. We prefer supportive gameplay where players collaborate and grow as a community.',
icon: Globe2,
},
]
const connectOptions = [
{
title: 'YouTube',
description: 'Catch up with FriendSMP75 videos.',
icon: Video,
href: YOUTUBE_URL,
},
{
title: 'Discord',
description: 'Connect with the community.',
icon: MessageCircle,
href: DISCORD_INVITE_URL,
},
{
title: 'Email',
description: 'Get in touch with us.',
icon: Mail,
href: EMAIL_URL,
},
]
function AboutCard({ title, description, icon: Icon, href }) {
return (
<article className="about-card">
<div className="about-card-icon">
<Icon size={17} aria-hidden="true" />
</div>
        <h3>{title}</h3>
        <p>{description}</p>

        {href && (
            <a className="about-card-link" href={href}>
                Open {title}
            </a>
        )}
    </article>
)
}
export default function About() {
useEffect(() => {
const page = document.querySelector('.about-page')
    if (!page) return

    let secondFrame

    const firstFrame = requestAnimationFrame(() => {
        secondFrame = requestAnimationFrame(() => {
            page.classList.add('about-page--loaded')
        })
    })

    return () => {
        cancelAnimationFrame(firstFrame)

        if (secondFrame) {
            cancelAnimationFrame(secondFrame)
        }

        page.classList.remove('about-page--loaded')
    }
}, [])

return (
    <div className="about-page">
        <NavBar />

        <main className="about-content">
            <header className="about-intro">
                <p className="eyebrow">About us</p>
                <h1>About FriendSMP75</h1>
                <p>
                    A friendly survival server focused on trust, creativity,
                    and long-term community memories.
                </p>
            </header>

            <section className="mission-card" aria-labelledby="mission-title">
                <div className="mission-icon">
                    <HeartHandshake size={20} aria-hidden="true" />
                </div>

                <p className="eyebrow">Our mission</p>

                <h2 id="mission-title">
                    A Minecraft community built on trust and respect.
                </h2>

                <p>
                    FriendSMP75 is a friendly Minecraft community built on
                    trust and respect. Our goal is to offer a safe, peaceful
                    environment where you can relax and enjoy the game
                    without worry.
                </p>

                <p>
                    We are a community-led server, which means every player
                    counts. We listen to feedback and make sure everyone has
                    a voice in how the server grows.
                </p>

                <p>
                    While PvP exists in Minecraft, we are not a PvP-oriented
                    community. We prefer supportive gameplay where players
                    build together instead of fighting each other.
                </p>
            </section>

            <section className="about-group" aria-labelledby="values-title">
                <p className="eyebrow">Community values</p>
                <h2 id="values-title">What makes us different.</h2>

                <div className="about-card-grid">
                    {values.map((value) => (
                        <AboutCard key={value.title} {...value} />
                    ))}
                </div>
            </section>

            <section className="about-group" aria-labelledby="connect-title">
                <p className="eyebrow">Connect</p>
                <h2 id="connect-title">Find us online.</h2>

                <p className="about-group-description">
                    Join the community on Discord, watch our content on
                    YouTube, or reach out via email.
                </p>

                <div className="about-card-grid">
                    {connectOptions.map((option) => (
                        <AboutCard key={option.title} {...option} />
                    ))}
                </div>
            </section>
        </main>

        <Footer />
    </div>
)
}