import { useEffect, useState } from 'react'
import { Activity, Code2, Copy, Users } from 'lucide-react'
import { getServerStatus } from '../../lib/api'

const serverStats = [
    { label: 'Server IP', value: 'play.friendsmp75.com', icon: Code2, action: 'copy' },
    { label: 'Minecraft version', value: '1.21.4', icon: Code2 },
    { label: 'Live status', value: 'Pending / Unconnected', icon: Activity },
    { label: 'Player count', value: 'Awaiting content', icon: Users },
]

export function ServerStats() {
    const [serverStatus, setServerStatus] = useState('Checking')
    const [copied, setCopied] = useState(false)

    useEffect(() => {
        let active = true

        getServerStatus()
            .then(({ status }) => {
                if (active) setServerStatus(status ? status[0].toUpperCase() + status.slice(1) : 'Unknown')
            })
            .catch(() => {
                if (active) setServerStatus('Unavailable')
            })

        return () => {
            active = false
        }
    }, [])

    const copyServerIp = async () => {
        try {
            await navigator.clipboard.writeText('play.friendsmp75.com')
            setCopied(true)
            window.setTimeout(() => setCopied(false), 1600)
        } catch {
            setCopied(false)
        }
    }

    const values = {
        'Server IP': 'friendsmp75.xubi.org',
        'Minecraft version': '1.8 to latest',
        'Live status': serverStatus,
        'Player count': 'Awaiting content',
    }

    return (
        <section className="stats-section page-section" id="server" aria-labelledby="stats-title">
            <div className="section-heading">
                <p className="eyebrow">The server at a glance</p>
                <h2 id="stats-title">Your world, ready when you are.</h2>
            </div>
            <div className="stats-grid">
                    {serverStats.map(({ label, icon: Icon, action }) => (
                    <article className="stat-card" key={label}>
                        <div className="stat-label">
                            <Icon size={13} aria-hidden="true" />
                            <span>{label}</span>
                        </div>
                        <div className="stat-value-row">
                            <strong>{values[label]}</strong>
                            {action === 'copy' && (
                                <button className="copy-button" type="button" onClick={copyServerIp} aria-label="Copy server IP">
                                    <Copy size={13} aria-hidden="true" />
                                    <span>{copied ? 'Copied' : 'Copy'}</span>
                                </button>
                            )}
                        </div>
                    </article>
                ))}
            </div>
        </section>
    )
}