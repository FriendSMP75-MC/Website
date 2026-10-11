import { useEffect, useMemo, useState } from 'react'
import {
    CalendarDays,
    LoaderCircle,
    Megaphone,
    RotateCcw,
    Search,
    UserRound,
    X,
    ArrowLeft,
    Clock3,
} from 'lucide-react'

import NavBar from '../../components/Navbar'
import { Footer } from '../../components/Footer'
import { getAnnouncements } from '../../lib/api'
import './announcements.css'

const PREVIEW_LENGTH = 260

function formatDate(value) {
    if (!value) return 'Date unavailable'
    const date = new Date(value)
    return Number.isNaN(date.getTime())
        ? 'Date unavailable'
        : date.toLocaleDateString(undefined, {
              year: 'numeric',
              month: 'short',
              day: 'numeric',
          })
}

function normalizeAnnouncement(raw, index) {
    return {
        id: raw?.id ?? index,
        title: String(raw?.announcement_title || 'Untitled announcement'),
        body: String(raw?.announcement_body || ''),
        author: String(raw?.author || 'Staff member'),
        date: raw?.created_at || null,
    }
}

function stripMarkdown(text) {
    return String(text || '')
        .replace(/&nbsp;/g, ' ')
        .replace(/^#{1,6}\s+/gm, '')
        .replace(/^[-*]\s+/gm, '')
        .replace(/^---+$/gm, '')
        .replace(/\*\*([^*]+)\*\*/g, '$1')
        .replace(/\*([^*]+)\*/g, '$1')
        .replace(/\s+/g, ' ')
        .trim()
}

function renderInline(text, keyPrefix) {
    return text
        .split(/(\*\*[^*]+\*\*|\*[^*]+\*)/)
        .map((token, index) => {
            if (token.startsWith('**') && token.endsWith('**') && token.length > 4) {
                return <strong key={`${keyPrefix}-b-${index}`}>{token.slice(2, -2)}</strong>
            }
            if (token.startsWith('*') && token.endsWith('*') && token.length > 2) {
                return <em key={`${keyPrefix}-i-${index}`}>{token.slice(1, -1)}</em>
            }
            return token
        })
}

function renderBody(body, keyPrefix) {
    const blocks = []
    let listItems = []

    const flushList = () => {
        if (!listItems.length) return
        const items = listItems
        listItems = []
        blocks.push(
            <ul key={`${keyPrefix}-ul-${blocks.length}`}>
                {items.map((item, index) => (
                    <li key={`${keyPrefix}-li-${blocks.length}-${index}`}>
                        {renderInline(item, `${keyPrefix}-li-${blocks.length}-${index}`)}
                    </li>
                ))}
            </ul>,
        )
    }

    String(body || '')
        .replace(/&nbsp;/g, ' ')
        .split('\n')
        .forEach((rawLine, index) => {
            const line = rawLine.trim()
            if (/^#{1,6}\s+/.test(line)) {
                flushList()
                const level = line.match(/^#+/)[0].length
                const headingText = line.replace(/^#{1,6}\s+/, '')
                const Tag = level <= 2 ? 'h2' : 'h3'
                blocks.push(
                    <Tag key={`${keyPrefix}-h-${index}`}>
                        {renderInline(headingText, `${keyPrefix}-h-${index}`)}
                    </Tag>,
                )
            } else if (/^---+$/.test(line)) {
                flushList()
                blocks.push(<hr key={`${keyPrefix}-hr-${index}`} />)
            } else if (/^[-*]\s+/.test(line)) {
                listItems.push(line.replace(/^[-*]\s+/, ''))
            } else if (!line) {
                flushList()
            } else {
                flushList()
                blocks.push(
                    <p key={`${keyPrefix}-p-${index}`}>
                        {renderInline(line, `${keyPrefix}-p-${index}`)}
                    </p>,
                )
            }
        })

    flushList()
    return blocks
}

function AnnouncementCard({ announcement, onReadMore }) {
    const plainBody = useMemo(() => stripMarkdown(announcement.body), [announcement.body])
    const isLong = plainBody.length > PREVIEW_LENGTH
    const preview = isLong ? `${plainBody.slice(0, PREVIEW_LENGTH).trimEnd()}…` : plainBody

    return (
        <article className="announcement-card">
            <div className="announcement-main">
                <h2>{announcement.title}</h2>
                <p className="announcement-meta">
                    <span className="announcement-author">
                        <UserRound size={13} aria-hidden="true" />
                        Posted by {announcement.author}
                    </span>
                    <span className="announcement-date">
                        <CalendarDays size={13} aria-hidden="true" />
                        {formatDate(announcement.date)}
                    </span>
                </p>
                <p className="announcement-preview">{preview}</p>
                {isLong && (
                    <button
                        className="announcement-read-more"
                        type="button"
                        onClick={() => onReadMore(announcement.id)}
                    >
                        Read more <span aria-hidden="true">→</span>
                    </button>
                )}
            </div>
        </article>
    )
}

function AnnouncementDetail({ announcement, onBack }) {
    return (
       <section
    key={`announcement-detail-${announcement.id}`}
    className="announcement-detail page-transition"
>
            <button type="button" className="announcement-back-button" onClick={onBack}>
                <ArrowLeft size={16} aria-hidden="true" />
                Back to announcements
            </button>

            <article className="announcement-detail-card">
                <div className="announcement-detail-heading">
                    <p className="announcement-detail-eyebrow">
                        <Megaphone size={14} aria-hidden="true" />
                        FRIENDSMP75 ANNOUNCEMENT
                    </p>
                    <h1>{announcement.title}</h1>
                    <p className="announcement-meta announcement-detail-meta">
                        <span className="announcement-author">
                            <UserRound size={13} aria-hidden="true" />
                            Posted by {announcement.author}
                        </span>
                        <span className="announcement-date">
                            <CalendarDays size={13} aria-hidden="true" />
                            {formatDate(announcement.date)}
                        </span>
                    </p>
                </div>
                <div className="announcement-body">
                    {renderBody(announcement.body, `detail-${announcement.id}`)}
                </div>
                
            </article>
            <button type="button" className="announcement-back-bottom" onClick={onBack}>
                <ArrowLeft size={15} aria-hidden="true" /> Back to all announcements
            </button>
        </section>
    )
}

export default function Announcements() {
    const [announcements, setAnnouncements] = useState([])
    const [loading, setLoading] = useState(true)
    const [error, setError] = useState('')
    const [reloadKey, setReloadKey] = useState(0)
    const [query, setQuery] = useState('')
    const [authorFilter, setAuthorFilter] = useState('all')
    const [sortOrder, setSortOrder] = useState('newest')
    const [announcementId, setAnnouncementId] = useState(
        () => new URLSearchParams(window.location.search).get('announcement'),
    )

    useEffect(() => {
        const syncAnnouncement = () => {
            setAnnouncementId(new URLSearchParams(window.location.search).get('announcement'))
        }
        window.addEventListener('popstate', syncAnnouncement)
        return () => window.removeEventListener('popstate', syncAnnouncement)
    }, [])

    const openAnnouncement = (id) => {
        const url = new URL(window.location.href)
        url.searchParams.set('announcement', String(id))
        window.history.pushState({}, '', `${url.pathname}${url.search}${url.hash}`)
        setAnnouncementId(String(id))
        window.scrollTo({ top: 0, behavior: 'smooth' })
    }

    const backToAnnouncements = () => {
        const url = new URL(window.location.href)
        url.searchParams.delete('announcement')
        window.history.pushState({}, '', `${url.pathname}${url.search}${url.hash}`)
        setAnnouncementId(null)
        window.scrollTo({ top: 0, behavior: 'smooth' })
    }

    const retryLoad = () => {
        setError('')
        setLoading(true)
        setReloadKey((key) => key + 1)
    }

    useEffect(() => {
        let active = true
        getAnnouncements()
            .then((payload) => {
                const items = Array.isArray(payload)
                    ? payload
                    : Array.isArray(payload?.data)
                      ? payload.data
                      : Array.isArray(payload?.announcements)
                        ? payload.announcements
                        : []
                const normalized = items
                    .map(normalizeAnnouncement)
                    .sort((first, second) => new Date(second.date || 0) - new Date(first.date || 0))
                if (active) setAnnouncements(normalized)
            })
            .catch(() => {
                if (active) setError('Announcements are temporarily unavailable.')
            })
            .finally(() => {
                if (active) setLoading(false)
            })
        return () => {
            active = false
        }
    }, [reloadKey])

    const authors = useMemo(
        () => [...new Set(announcements.map((announcement) => announcement.author))].sort(),
        [announcements],
    )

    const filtered = useMemo(() => {
        const needle = query.trim().toLowerCase()
        const matching = announcements.filter((announcement) => {
            if (authorFilter !== 'all' && announcement.author !== authorFilter) return false
            if (!needle) return true
            return (
                announcement.title.toLowerCase().includes(needle) ||
                announcement.body.toLowerCase().includes(needle) ||
                announcement.author.toLowerCase().includes(needle)
            )
        })
        return [...matching].sort((first, second) => {
            const difference = new Date(first.date || 0) - new Date(second.date || 0)
            return sortOrder === 'newest' ? -difference : difference
        })
    }, [announcements, query, authorFilter, sortOrder])

    const selectedAnnouncement = announcementId
        ? announcements.find((announcement) => String(announcement.id) === announcementId)
        : null
    const hasActiveFilters = Boolean(query.trim()) || authorFilter !== 'all'

    const clearFilters = () => {
        setQuery('')
        setAuthorFilter('all')
        setSortOrder('newest')
    }

    return (
        <div className="announcements-page">
            <NavBar />
            <main className="announcements-content">
                {announcementId && selectedAnnouncement ? (
                    <AnnouncementDetail
                        announcement={selectedAnnouncement}
                        onBack={backToAnnouncements}
                    />
                ) : (
                    <div key="announcements-list-page" className="announcements-list-page page-transition">
                        <header className="announcements-intro">
                            <p className="eyebrow">Announcements</p>
                            <h1>Server Announcements</h1>
                            <p>Official news, events, and maintenance updates from the FriendSMP75 team.</p>
                        </header>

                        {loading ? (
                            <section className="announcements-state" role="status">
                                <LoaderCircle className="spin" size={22} aria-hidden="true" />
                                <p>Loading announcements...</p>
                            </section>
                        ) : error ? (
                            <section className="announcements-state" role="alert">
                                <Megaphone size={22} aria-hidden="true" />
                                <p>{error}</p>
                                <button className="announcements-retry" type="button" onClick={retryLoad}>
                                    <RotateCcw size={14} aria-hidden="true" /> Try again
                                </button>
                            </section>
                        ) : announcements.length === 0 ? (
                            <section className="announcements-state">
                                <Megaphone size={22} aria-hidden="true" />
                                <p>No announcements yet — check back soon.</p>
                            </section>
                        ) : (
                            <>
                                <div className="announcements-toolbar">
                                    <div className="announcements-search">
                                        <Search size={15} aria-hidden="true" />
                                        <input
                                            type="search"
                                            value={query}
                                            onChange={(event) => setQuery(event.target.value)}
                                            placeholder="Search by title, content, or author..."
                                            aria-label="Search announcements"
                                        />
                                        {query && (
                                            <button type="button" onClick={() => setQuery('')} aria-label="Clear search">
                                                <X size={14} />
                                            </button>
                                        )}
                                    </div>
                                    <div className="announcements-filters">
                                        <select value={authorFilter} onChange={(event) => setAuthorFilter(event.target.value)} aria-label="Filter by author">
                                            <option value="all">All authors</option>
                                            {authors.map((author) => <option key={author} value={author}>{author}</option>)}
                                        </select>
                                        <select value={sortOrder} onChange={(event) => setSortOrder(event.target.value)} aria-label="Sort announcements">
                                            <option value="newest">Newest first</option>
                                            <option value="oldest">Oldest first</option>
                                        </select>
                                    </div>
                                </div>

                                {filtered.length === 0 ? (
                                    <section className="announcements-state">
                                        <Search size={22} aria-hidden="true" />
                                        <p>No announcements match your search.</p>
                                        <button className="announcements-retry" type="button" onClick={clearFilters}>
                                            <X size={14} aria-hidden="true" /> Clear filters
                                        </button>
                                    </section>
                                ) : (
                                    <>
                                        <p className="announcements-count" role="status">
                                            Showing {filtered.length} of {announcements.length} announcement{announcements.length === 1 ? '' : 's'}
                                            {hasActiveFilters && <button type="button" onClick={clearFilters}>Clear filters</button>}
                                        </p>
                                        <section className="announcements-list" aria-label="Announcement list">
                                            {filtered.map((announcement, index) => (
                                                <div key={announcement.id} style={{ '--card-index': index }}>
                                                    <AnnouncementCard announcement={announcement} onReadMore={openAnnouncement} />
                                                </div>
                                            ))}
                                        </section>
                                    </>
                                )}
                            </>
                        )}
                    </div>
                )}
                {announcementId && !loading && !selectedAnnouncement && (
                    <section className="announcements-state page-transition" role="status">
                        <Megaphone size={22} aria-hidden="true" />
                        <p>Announcement not found.</p>
                        <button className="announcement-back-button" type="button" onClick={backToAnnouncements}>
                            <ArrowLeft size={15} aria-hidden="true" /> Back to announcements
                        </button>
                    </section>
                )}
            </main>
            <Footer />
        </div>
    )
}
