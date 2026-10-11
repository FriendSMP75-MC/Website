import { useEffect, useState } from 'react'
import { Activity, Code2, Copy } from 'lucide-react'
import { getServerStatus } from '../../lib/api'

const STATUS_CACHE_KEY = 'friendsmp75:server-status'
const STATUS_CACHE_TTL = 60 * 1000

const serverStats = [
    { label: 'Server IP', value: 'play.friendsmp75.com', icon: Code2, action: 'copy' },
    { label: 'Minecraft version', value: '1.21.4', icon: Code2 },
    { label: 'Live status', value: 'Pending / Unconnected', icon: Activity },
]

function formatStatus(status) {
    return status ? status[0].toUpperCase() + status.slice(1) : 'Unknown'
}

function readCachedStatus(maxAge = STATUS_CACHE_TTL) {
    try {
        const raw = window.localStorage.getItem(STATUS_CACHE_KEY)
        if (!raw) return null
        const cached = JSON.parse(raw)
        if (!cached || typeof cached.status !== 'string' || typeof cached.fetchedAt !== 'number') return null
        if (Date.now() - cached.fetchedAt > maxAge) return null
        return cached.status
    } catch {
        return null
    }
}

function writeCachedStatus(status) {
    try {
        window.localStorage.setItem(STATUS_CACHE_KEY, JSON.stringify({ status, fetchedAt: Date.now() }))
    } catch {
        // Storage may be unavailable (private mode); caching is best-effort.
    }
}

export function ServerStats() {
    const [serverStatus, setServerStatus] = useState(() => {
        const cached = readCachedStatus()
        return cached ? formatStatus(cached) : 'Checking'
    })
    const [copied, setCopied] = useState(false)

    useEffect(() => {
        if (readCachedStatus()) return undefined

        let active = true

        getServerStatus()
            .then(({ status }) => {
                if (!status) return
                writeCachedStatus(status)
                if (active) setServerStatus(formatStatus(status))
            })
            .catch(() => {
                if (!active) return
                const stale = readCachedStatus(Number.POSITIVE_INFINITY)
                setServerStatus(stale ? formatStatus(stale) : 'Unavailable')
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