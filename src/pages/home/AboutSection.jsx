import { HeartHandshake, ShieldCheck, UsersRound } from 'lucide-react'

const communityValues = [
    { label: 'Community-first culture', icon: UsersRound },
    { label: 'Curated gameplay', icon: ShieldCheck },
    { label: 'A world worth returning to', icon: HeartHandshake },
]

export function AboutSection() {
    return (
        <section className="about-section page-section" id="about" aria-labelledby="about-title">
            <div className="about-topline">
                <p className="eyebrow">About us</p>
                <div className="value-list" aria-label="Community values">
                    {communityValues.map(({ label, icon: Icon }) => (
                        <span className="value-item" key={label}>
                            <Icon size={13} aria-hidden="true" />
                            {label}
                        </span>
                    ))}
                </div>
            </div>
            <div className="about-body">
                <div className="about-icon" aria-hidden="true">
                    <HeartHandshake size={21} />
                </div>
                <h2 id="about-title">A community-first SMP where every build matters.</h2>
                <p>
                    FriendSMP75 is designed for players who value long-term survival, meaningful collaboration, and a shared world that grows over time.
                    We prioritize a welcoming environment, clean gameplay, and a community that feels like a home server.
                </p>
            </div>
        </section>
    )
}