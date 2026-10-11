import { useEffect, useMemo, useState } from 'react'
import {
    ArrowLeft,
    CalendarDays,
    Check,
    ChevronDown,
    CircleAlert,
    CloudUpload,
    Info,
    ListChecks,
    LoaderCircle,
    Send,
    ShieldAlert,
    UserRound,
} from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import NavBar from '../../components/Navbar'
import { ConfirmDialog } from '../../components/ConfirmDialog'
import { getMemberMemoryRequests, submitMemoryRequest } from '../../lib/api'
import { supabase } from '../../lib/supabase'
import './dashboard.css'
import './memories-request.css'

const GENERIC_ERROR = 'Something went wrong. Please try again.'

const uploadSteps = [
    { title: 'Pick a good image', detail: 'Choose one clear community moment — builds, events, or group screenshots work best.' },
    { title: 'Add the date taken', detail: 'Select the day the memory image was captured so staff can place it correctly.' },
    { title: 'Give it a title', detail: 'Write a short, clear memory title that will display after acceptance.' },
    { title: 'Preview and submit', detail: 'Check the live preview below, then send the request for staff review.' },
]

function getDisplayName(session) {
    const user = session?.user
    if (!user) return 'Member'
    return user.user_metadata?.full_name
        || user.user_metadata?.user_name
        || user.user_metadata?.preferred_username
        || user.email
        || 'Member'
}

function getImageUrl(request) {
    return request.public_url || request.publicUrl || request.image_url || request.url || ''
}

function formatStatus(value) {
    return String(value || 'Pending').toLowerCase().replace(/[^a-z0-9]+/g, '-')
}

function formatDate(value) {
    if (!value) return 'Date unavailable'
    const date = new Date(value)
    return Number.isNaN(date.getTime())
        ? String(value)
        : date.toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric' })
}

export default function MemoriesUpload() {
    const navigate = useNavigate()
    const [session, setSession] = useState(null)
    const [authReady, setAuthReady] = useState(!supabase)
    const [dateTaken, setDateTaken] = useState('')
    const [title, setTitle] = useState('')
    const [file, setFile] = useState(null)
    const [previewUrl, setPreviewUrl] = useState('')
    const [historyOpen, setHistoryOpen] = useState(false)
    const [history, setHistory] = useState([])
    const [historyLoaded, setHistoryLoaded] = useState(false)
    const [historyLoading, setHistoryLoading] = useState(false)
    const [confirmOpen, setConfirmOpen] = useState(false)
    const [submitting, setSubmitting] = useState(false)
    const [error, setError] = useState('')
    const [message, setMessage] = useState('')

    useEffect(() => {
        if (!supabase) return undefined
        supabase.auth.getSession().then(({ data }) => {
            setSession(data.session)
            setAuthReady(true)
        })
        const { data: listener } = supabase.auth.onAuthStateChange((_event, nextSession) => setSession(nextSession))
        return () => listener.subscription.unsubscribe()
    }, [])

    useEffect(() => () => {
        if (previewUrl) URL.revokeObjectURL(previewUrl)
    }, [previewUrl])

    const displayName = useMemo(() => getDisplayName(session), [session])
    const canSubmit = Boolean(file && title.trim() && dateTaken) && !submitting

    const loadHistory = async () => {
        if (!session) return
        setHistoryLoading(true)
        try {
            const items = await getMemberMemoryRequests(session)
            setHistory(Array.isArray(items) ? items : [])
            setHistoryLoaded(true)
        } catch {
            setError(GENERIC_ERROR)
        } finally {
            setHistoryLoading(false)
        }
    }

    const toggleHistory = () => {
        const nextOpen = !historyOpen
        setHistoryOpen(nextOpen)
        if (nextOpen && !historyLoaded && !historyLoading && session) loadHistory()
    }

    const handleFileChange = (event) => {
        const nextFile = event.target.files?.[0]
        if (!nextFile) return
        if (previewUrl) URL.revokeObjectURL(previewUrl)
        setFile(nextFile)
        setPreviewUrl(URL.createObjectURL(nextFile))
        setError('')
        setMessage('')
    }

    const handleSubmit = (event) => {
        event.preventDefault()
        if (!session) {
            setError('Please sign in with Discord to submit a memory request.')
            return
        }
        if (!dateTaken) {
            setError('Please choose the date when the memory image was taken.')
            return
        }
        if (!title.trim()) {
            setError('Please enter a memory title.')
            return
        }
        if (!file) {
            setError('Please select an image before submitting.')
            return
        }
        setConfirmOpen(true)
    }

    const confirmSubmit = async () => {
        setConfirmOpen(false)
        setSubmitting(true)
        setError('')
        setMessage('')
        try {
            await submitMemoryRequest(session, { file, title: title.trim(), dateTaken })
            setMessage('Memory request sent! Staff will review it soon.')
            setTitle('')
            setDateTaken('')
            setFile(null)
            if (previewUrl) URL.revokeObjectURL(previewUrl)
            setPreviewUrl('')
            setHistory([])
            setHistoryLoaded(false)
        } catch {
            setError(GENERIC_ERROR)
        } finally {
            setSubmitting(false)
        }
    }


    return (
        <div className="dashboard-page memories-request-page">
            <NavBar />
            <main className="memories-request-content">
                <button className="dashboard-back-button" type="button" onClick={() => navigate('/dashboard')}><ArrowLeft size={16} /> Back to dashboard</button>

                <header className="announcement-hero memories-request-hero">
                    <p className="eyebrow">Member tool</p>
                    <h1>Memories upload request</h1>
                    <p>Request staff to review and add your community memory to the public gallery.</p>
                </header>

                {!authReady ? (
                    <section className="dashboard-panel dashboard-loading"><LoaderCircle className="gallery-manager-spinner" size={22} />Checking sign-in status...</section>
                ) : !session ? (
                    <section className="dashboard-panel announcement-denied"><ShieldAlert size={24} /><h2>Sign in required</h2><p>Please sign in with Discord to submit a memory request.</p><button className="dashboard-primary-button" type="button" onClick={() => navigate('/dashboard')}><UserRound size={15} /> Open dashboard</button></section>
                ) : (
                    <>
                        <section className="memories-guide dashboard-panel" aria-labelledby="memories-guide-title">
                            <div className="memories-guide-heading">
                                <span className="dashboard-icon"><ListChecks size={20} /></span>
                                <div>
                                    <h2 id="memories-guide-title">How to upload</h2>
                                    <p>Follow these steps so staff can review and publish your memory faster.</p>
                                </div>
                            </div>
                            <ol className="memories-guide-list">
                                {uploadSteps.map((step, index) => (
                                    <li key={step.title}>
                                        <span className="memories-guide-number">{index + 1}</span>
                                        <div><strong>{step.title}</strong><p>{step.detail}</p></div>
                                    </li>
                                ))}

                        <section className="memories-request-main">
                            <form className="dashboard-panel memories-request-form" onSubmit={handleSubmit}>
                                <h2>Manage memory request</h2>
                                <p className="announcement-hint"><Info size={15} /> Provide one good image to display after acceptance.</p>

                                <label className="gallery-field"><span><CalendarDays size={15} />Date when image was taken</span><input type="date" value={dateTaken} max={new Date().toISOString().slice(0, 10)} onChange={(event) => { setDateTaken(event.target.value); setError('') }} /></label>
                                <label className="gallery-field"><span><Info size={15} />Memory title</span><input type="text" value={title} maxLength={80} onChange={(event) => { setTitle(event.target.value); setError('') }} placeholder="Enter memory title" /></label>

                                <label className="gallery-file-button dashboard-primary-button">
                                    <CloudUpload size={15} /> {file ? 'Change image' : 'Select image'}
                                    <input type="file" accept="image/*" onChange={handleFileChange} />
                                </label>
                                {file && <p className="memories-file-name">{file.name}</p>}
                                {!dateTaken && <p className="memories-date-hint"><CircleAlert size={13} /> Choose the date first — staff needs it to place your memory.</p>}

                                {error && <p className="dashboard-error" role="alert">{error}</p>}
                                {message && <p className="dashboard-success" role="status"><Check size={15} />{message}</p>}

                                <button className="dashboard-primary-button memories-request-submit" type="submit" disabled={!canSubmit}><Send size={15} />{submitting ? 'Submitting...' : 'Submit memory request'}</button>
                            </form>

                            <section className="gallery-preview dashboard-panel" aria-labelledby="memories-preview-title">
                                <h2 id="memories-preview-title">Preview</h2>
                                <p className="announcement-hint"><Info size={15} /> This preview shows how it will look after acceptance.</p>
                                <div className="gallery-preview-box">
                                    {previewUrl ? (
                                        <figure className="memories-preview-figure">
                                            <img src={previewUrl} alt="Selected memory preview" />
                                            <figcaption>
                                                <strong>{title.trim() || 'Untitled memory'}</strong>
                                                <span>{dateTaken ? formatDate(dateTaken) : 'No date selected'} — by {displayName}</span>
                                            </figcaption>
                                        </figure>
                                    ) : <span>Select image to view preview</span>}
                                </div>
                            </section>
                        </section>

                            </ol>
                        </section>


                        <section className="dashboard-panel memories-history" aria-labelledby="memories-history-title">
                            <button type="button" className={`memories-history-toggle${historyOpen ? ' memories-history-toggle-open' : ''}`} onClick={() => toggleHistory()} aria-expanded={historyOpen}>
                                <span><CloudUpload size={16} /><strong id="memories-history-title">My submitted requests</strong></span>
                                <ChevronDown size={17} aria-hidden="true" />
                            </button>
                            {historyOpen && (
                                historyLoading ? (
                                    <p className="dashboard-loading"><LoaderCircle className="gallery-manager-spinner" size={18} />Loading your requests...</p>
                                ) : history.length === 0 ? (
                                    <p className="dashboard-loading">No memory requests submitted yet.</p>
                                ) : (
                                    <ul className="memories-history-list">
                                        {history.map((request) => {
                                            const status = formatStatus(request.status)
                                            const imageUrl = getImageUrl(request)
                                            return (
                                                <li key={request.id || request.request_uid || request.created_at} className="memories-history-item">
                                                    {imageUrl
                                                        ? <img className="memories-history-thumb" src={imageUrl} alt={request.title || 'Uploaded memory'} loading="lazy" />
                                                        : <span className="memories-history-thumb memories-history-thumb-empty" aria-hidden="true" />}
                                                    <div><strong>{request.title || 'Untitled memory'}</strong><small>{formatDate(request.date_taken || request.created_at)}</small></div>
                                                    <span className={`request-status request-status-${status}`}>{request.status || 'Pending'}</span>
                                                </li>
                                            )
                                        })}
                                    </ul>
                                )
                            )}
                        </section>
                    </>
                )}
            </main>
            <ConfirmDialog
                open={confirmOpen}
                title="Submit memory request?"
                message={`"${title.trim()}" will be sent to staff for review.`}
                confirmLabel="Submit request"
                onConfirm={confirmSubmit}
                onCancel={() => setConfirmOpen(false)}
            />
        </div>
    )
}

