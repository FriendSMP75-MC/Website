import { CalendarDays, Globe2, Hammer, MessageCircle, Shield, UsersRound } from 'lucide-react'

const features = [
    { title: 'Survival Gameplay', description: 'Explore, mine, build, and survive in a world designed for long-term progression and meaningful risk.', icon: Shield },
    { title: 'Building & Creation', description: 'Build ambitious bases, collaborate on large-scale projects, and shape the server landscape with your community.', icon: Hammer },
    { title: 'Community Activities', description: 'Join group builds, trade resources, participate in events, and grow a community that feels personal and engaged.', icon: UsersRound },
    { title: 'Events & Challenges', description: 'Participate in seasonal events, community challenges, and curated activities that keep the experience fresh and rewarding.', icon: CalendarDays },
    { title: 'Shared World', description: 'Explore a persistent world where every build, every discovery, and every session contributes to a shared history.', icon: Globe2 },
    { title: 'Official Discord', description: 'Connect with the community, share builds, coordinate events, and stay up to date with server activity and updates.', icon: MessageCircle },
]

export function FeaturesSection() {
    return (
        <section className="features-section" aria-labelledby="about-features-title">
            <p className="eyebrow">Features</p>
            <h2 id="about-features-title">Explore the heart of the server.</h2>
            <div className="feature-grid">
                {features.map(({ title, description, icon: Icon }) => (
                    <article className="feature-card" key={title}>
                        <div className="feature-icon"><Icon size={15} aria-hidden="true" /></div>
                        <h3>{title}</h3>
                        <p>{description}</p>
                    </article>
                ))}
            </div>
        </section>
    )
}
