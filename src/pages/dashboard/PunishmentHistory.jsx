import { useEffect, useMemo, useState } from 'react'
import {
    ArrowLeft,
    Calendar,
    ChevronLeft,
    ChevronRight,
    Gavel,
    LoaderCircle,
    LogIn,
    Search,
    TriangleAlert,
    UserRound,
} from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import NavBar from '../../components/Navbar'
import { getPunishmentHistory } from '../../lib/api'
import { supabase } from '../../lib/supabase'
import './dashboard.css'
import './punishment-history.css'

const GENERIC_ERROR = 'Something went wrong. Please try again.'
const PAGE_SIZE = 5

// Mirrors the Flutter page: epoch milliseconds, ISO-8601, or DD/MM/YYYY strings.
function parseRecordDate(value) {
    if (value === null || value === undefined) return null
    if (typeof value === 'number') {
        const fromMillis = new Date(value)
        return Number.isNaN(fromMillis.getTime()) ? null : fromMillis
    }

    const text = String(value).trim()
    if (!text || text === 'N/A') return null

    const iso = new Date(text)
    if (!Number.isNaN(iso.getTime())) return iso

    const parts = text.split(/[/.-]/)
    if (parts.length === 3) {
        const [day, month, year] = parts.map((part) => Number.parseInt(part, 10))
        if (day && month && year) {
            const parsed = new Date(year, month - 1, day)
            return Number.isNaN(parsed.getTime()) ? null : parsed
        }
    }
    return null
}

function formatDate(value, formatted) {
    if (formatted && formatted !== 'N/A') return formatted
    const parsed = parseRecordDate(value)
    return parsed ? parsed.toLocaleDateString() : 'N/A'
}

function isRecordActive(record) {
    if (record.category === 'WARNING') return true
    return record.active === 1 || record.active === true || record.active === '1'
}

function recordCategory(record) {
    return record.category === 'WARNING' ? 'warning' : 'punishment'
}

function recordTypeLabel(record) {
    if (record.category === 'WARNING') return 'Warning'
    return String(record.type || 'Punishment')
        .toLowerCase()
        .replace(/_/g, ' ')
        .replace(/\b\w/g, (letter) => letter.toUpperCase())
}

export default function PunishmentHistory() {
    const navigate = useNavigate()
    const [session, setSession] = useState(null)
    const [authReady, setAuthReady] = useState(!supabase)

    const [username, setUsername] = useState('')
    const [loading, setLoading] = useState(false)
    const [hasSearched, setHasSearched] = useState(false)
    const [error, setError] = useState('')
    const [signInError, setSignInError] = useState('')
    const [result, setResult] = useState(null)

    const [categoryFilter, setCategoryFilter] = useState('ALL')
    const [statusFilter, setStatusFilter] = useState('ALL')
    const [currentPage, setCurrentPage] = useState(1)

    useEffect(() => {
        if (!supabase) return undefined
        supabase.auth.getSession().then(({ data }) => {
            setSession(data.session)
            setAuthReady(true)
        })
        const { data: listener } = supabase.auth.onAuthStateChange((_event, nextSession) => setSession(nextSession))
        return () => listener.subscription.unsubscribe()
    }, [])

    const signInWithDiscord = async () => {
        if (!supabase) {
            setSignInError(GENERIC_ERROR)
            return
        }
        const { error: oauthError } = await supabase.auth.signInWithOAuth({
            provider: 'discord',
            options: { redirectTo: `${window.location.origin}/dashboard/punishments` },
        })
        if (oauthError) setSignInError(oauthError.message || GENERIC_ERROR)
    }

    const handleSearch = async (event) => {
        event.preventDefault()
        const query = username.trim()
        if (!query || !session) return

        setLoading(true)
        setError('')
        try {
            const payload = await getPunishmentHistory(session, query)
            setResult(payload)
            setHasSearched(true)
            setCategoryFilter('ALL')
            setStatusFilter('ALL')
            setCurrentPage(1)
        } catch (searchError) {
            setResult(null)
            setHasSearched(true)
            setError(searchError?.message || GENERIC_ERROR)
        } finally {
            setLoading(false)
        }
    }

    const records = useMemo(() => {
        if (!Array.isArray(result?.records)) return []
        return result.records.filter((record) => {
            const category = recordCategory(record)
            const active = isRecordActive(record)
            if (categoryFilter !== 'ALL' && category !== categoryFilter.toLowerCase()) return false
            if (statusFilter === 'ACTIVE' && !active) return false
            if (statusFilter === 'EXPIRED' && active) return false
            return true
        })
    }, [result, categoryFilter, statusFilter])

    const totalPages = Math.max(1, Math.ceil(records.length / PAGE_SIZE))
    const safePage = Math.min(currentPage, totalPages)
    const pageRecords = records.slice((safePage - 1) * PAGE_SIZE, safePage * PAGE_SIZE)

    const totalWarnings = result?.total_warnings ?? 0
    const totalPunishments = result?.total_punishments ?? 0


    return (
        <div>
            <NavBar />
            <main className="announcement-content">
                <button className="dashboard-back-button" type="button" onClick={() => navigate('/dashboard')}>
                    <ArrowLeft size={13} /> Back to dashboard
                </button>

                <section className="announcement-hero dashboard-panel punishment-hero">
                    <h1>Punishment List</h1>
                    <p>Check your punishment history or another player&apos;s punishment history.</p>
                </section>

                {authReady && !session ? (
                    <section className="dashboard-panel punishment-login">
                        <div className="dashboard-icon"><LogIn size={21} /></div>
                        <h2>Login to continue</h2>
                        <p>Sign in with Discord to look up punishment records for any player on the server.</p>
                        <button className="dashboard-primary-button" type="button" onClick={signInWithDiscord}>
                            <LogIn size={15} /> Login to Continue
                        </button>
                        {signInError && <p className="dashboard-error" role="alert">{signInError}</p>}
                    </section>
                ) : (
                    <>
                        <form className="punishment-search dashboard-panel" onSubmit={handleSearch} role="search">
                            <label className="punishment-search-field">
                                <UserRound size={17} aria-hidden="true" />
                                <input
                                    type="text"
                                    value={username}
                                    onChange={(event) => setUsername(event.target.value)}
                                    placeholder="Type in the player's username..."
                                    aria-label="Player username"
                                    autoComplete="off"
                                />
                            </label>
                            <button className="dashboard-primary-button" type="submit" disabled={loading || !username.trim()}>
                                {loading ? <LoaderCircle size={15} className="punishment-spin" /> : <Search size={15} />}
                                {loading ? 'Searching...' : 'Search'}
                            </button>
                        </form>

                        {error && <p className="dashboard-error" role="alert">{error}</p>}

                        {!hasSearched ? (
                            <section className="dashboard-panel punishment-empty">
                                <Search size={26} />
                                <p>Type in the player&apos;s username to see their punishments</p>
                            </section>
                        ) : (result?.records || []).length === 0 ? (
                            <section className="dashboard-panel punishment-empty">
                                <TriangleAlert size={26} />
                                <p>No punishments found for <strong>{result?.username || username.trim()}</strong></p>
                            </section>
                        ) : (
                            <>

                                <section className="dashboard-panel punishment-player">
                                    <div className="punishment-player-identity">
                                        <div className="dashboard-icon"><UserRound size={20} /></div>
                                        <div>
                                            <h2>{result.username}</h2>
                                        </div>
                                    </div>
                                    <div className="punishment-stats">
                                        <span className="punishment-stat punishment-stat-warnings"><TriangleAlert size={15} /> {totalWarnings} Warning{totalWarnings === 1 ? '' : 's'}</span>
                                        <span className="punishment-stat punishment-stat-punishments"><Gavel size={15} /> {totalPunishments} Punishment{totalPunishments === 1 ? '' : 's'}</span>
                                    </div>
                                </section>

                                <section className="dashboard-panel punishment-list-panel" aria-label="Punishment records">
                                    <div className="punishment-filters">
                                        <div className="punishment-filter-group" role="group" aria-label="Filter by category">
                                            <span className="punishment-filter-label" aria-hidden="true">Show</span>
                                            {['ALL', 'WARNING', 'PUNISHMENT'].map((option) => (
                                                <button
                                                    key={option}
                                                    className={categoryFilter === option ? 'punishment-chip punishment-chip-active' : 'punishment-chip'}
                                                    type="button"
                                                    onClick={() => { setCategoryFilter(option); setCurrentPage(1) }}
                                                >
                                                    {option === 'ALL' ? 'All' : option === 'WARNING' ? 'Warnings' : 'Punishments'}
                                                </button>
                                            ))}
                                        </div>
                                        <div className="punishment-filter-group" role="group" aria-label="Filter by status">
                                            <span className="punishment-filter-label" aria-hidden="true">Status</span>
                                            {['ALL', 'ACTIVE', 'EXPIRED'].map((option) => (
                                                <button
                                                    key={option}
                                                    className={statusFilter === option ? 'punishment-chip punishment-chip-active' : 'punishment-chip'}
                                                    type="button"
                                                    onClick={() => { setStatusFilter(option); setCurrentPage(1) }}
                                                >
                                                    {option === 'ALL' ? 'All' : option.charAt(0) + option.slice(1).toLowerCase()}
                                                </button>
                                            ))}
                                        </div>
                                    </div>


                                    {records.length === 0 ? (
                                        <div className="punishment-empty punishment-empty-inline">
                                            <TriangleAlert size={22} />
                                            <p>No records match the selected filters.</p>
                                        </div>
                                    ) : (
                                        <ul className="punishment-records">
                                            {pageRecords.map((record) => {
                                                const category = recordCategory(record)
                                                const active = isRecordActive(record)
                                                return (
                                                    <li className={`punishment-record punishment-record-${category}`} key={`${record.category}-${record.id}`}>
                                                        <span className="punishment-record-icon" aria-hidden="true">
                                                            {category === 'warning' ? <TriangleAlert size={18} /> : <Gavel size={18} />}
                                                        </span>
                                                        <div className="punishment-record-body">
                                                            <div className="punishment-record-heading">
                                                                <strong>{recordTypeLabel(record)}</strong>
                                                                <span className={active ? 'request-status request-status-approved' : 'request-status request-status-rejected'}>
                                                                    {active ? 'Active' : 'Expired'}
                                                                </span>
                                                            </div>
                                                            <p className="punishment-record-reason">{record.reason || 'No reason provided.'}</p>
                                                            <span className="punishment-record-date">
                                                                <Calendar size={12} /> {formatDate(record.timestamp, record.formatted_date)}
                                                            </span>
                                                        </div>
                                                    </li>
                                                )
                                            })}
                                        </ul>
                                    )}

                                    {records.length > PAGE_SIZE && (
                                        <nav className="punishment-pagination" aria-label="Punishment records pages">
                                            <button
                                                className="dashboard-secondary-button"
                                                type="button"
                                                disabled={safePage <= 1}
                                                onClick={() => setCurrentPage(safePage - 1)}
                                            >
                                                <ChevronLeft size={14} /> Previous
                                            </button>
                                            <span>Page {safePage} of {totalPages}</span>
                                            <button
                                                className="dashboard-secondary-button"
                                                type="button"
                                                disabled={safePage >= totalPages}
                                                onClick={() => setCurrentPage(safePage + 1)}
                                            >
                                                Next <ChevronRight size={14} />
                                            </button>
                                        </nav>
                                    )}
                                </section>
                            </>
                        )}
                    </>
                )}
            </main>
        </div>
    )
}
