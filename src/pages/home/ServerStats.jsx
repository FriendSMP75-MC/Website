import { Activity, Code2, Copy, Users } from 'lucide-react'

const serverStats = [
    { label: 'Server IP', value: 'play.friendsmp75.com', icon: Code2, action: 'copy' },
    { label: 'Minecraft version', value: '1.21.4', icon: Code2 },
    { label: 'Live status', value: 'Pending / Unconnected', icon: Activity },
    { label: 'Player count', value: 'Awaiting content', icon: Users },
]

export function ServerStats() {
    return (
        <section className="stats-section page-section" id="server" aria-labelledby="stats-title">
            <div className="section-heading">
                <p className="eyebrow">The server at a glance</p>
                <h2 id="stats-title">Your world, ready when you are.</h2>
            </div>
            <div className="stats-grid">
                {serverStats.map(({ label, value, icon: Icon, action }) => (
                    <article className="stat-card" key={label}>
                        <div className="stat-label">
                            <Icon size={13} aria-hidden="true" />
                            <span>{label}</span>
                        </div>
                        <div className="stat-value-row">
                            <strong>{value}</strong>
                            {action === 'copy' && (
                                <button className="copy-button" type="button" aria-label={`Copy ${value}`}>
                                    <Copy size={13} aria-hidden="true" />
                                    <span>Copy</span>
                                </button>
                            )}
                        </div>
                    </article>
                ))}
            </div>
        </section>
    )
}