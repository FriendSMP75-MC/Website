import { useEffect, useMemo, useState } from 'react'
import { ArrowLeft, CalendarDays, ChevronLeft, ChevronRight, Check, Filter, Image, LoaderCircle, ShieldAlert, X } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import NavBar from '../../components/Navbar'
import { ConfirmDialog } from '../../components/ConfirmDialog'
import { checkOwner, checkStaffAccess, deleteMemoryRequest, getStaffMemoryRequests, updateMemoryRequestStatus } from '../../lib/api'
import { supabase } from '../../lib/supabase'
import './dashboard.css'

const GENERIC_ERROR = 'Something went wrong. Please try again.'

function normalizeStatus(status) {
    return String(status || 'Pending').toLowerCase()
}

function getImageUrl(request) {
    return request.public_url || request.publicUrl || request.image_url || request.url || ''
}

function formatDate(value) {
    if (!value) return 'Date unavailable'
    const date = new Date(value)
    return Number.isNaN(date.getTime()) ? 'Date unavailable' : date.toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric' })
}

export default function MemoryRequests() {
    const navigate = useNavigate()
    const [session, setSession] = useState(null)
    const [authReady, setAuthReady] = useState(!supabase)
    const [allowed, setAllowed] = useState(false)
    const [loading, setLoading] = useState(true)
    const [requests, setRequests] = useState([])
    const [statusFilter, setStatusFilter] = useState('all')
    const [dateFilter, setDateFilter] = useState('newest')
    const [error, setError] = useState('')
    const [updatingId, setUpdatingId] = useState(null)
    const [page, setPage] = useState(1)
    const [pendingAction, setPendingAction] = useState(null)
    const pageSize = 6

    useEffect(() => {
        if (!supabase) return undefined
        supabase.auth.getSession().then(({ data }) => {
            setSession(data.session)
            setAuthReady(true)
        })
        const { data: listener } = supabase.auth.onAuthStateChange((_event, nextSession) => setSession(nextSession))
        return () => listener.subscription.unsubscribe()
    }, [])

    useEffect(() => {
        if (!session) return undefined
        let active = true
        Promise.all([checkOwner(session), checkStaffAccess(session)])
            .then(async ([isOwner, isStaff]) => {
                const hasAccess = isOwner || isStaff
                if (active) setAllowed(hasAccess)
                if (!hasAccess) return
                const items = await getStaffMemoryRequests(session)
                if (active) setRequests(Array.isArray(items) ? items : [])
            })
            .catch(() => {
                if (active) setError(GENERIC_ERROR)
            })
            .finally(() => {
                if (active) setLoading(false)
            })
        return () => { active = false }
    }, [session])

    const visibleRequests = useMemo(() => requests
        .filter((request) => statusFilter === 'all' || normalizeStatus(request.status) === statusFilter)
        .sort((first, second) => {
            const firstDate = new Date(first.created_at || first.date_taken || 0).getTime()
            const secondDate = new Date(second.created_at || second.date_taken || 0).getTime()
            return dateFilter === 'newest' ? secondDate - firstDate : firstDate - secondDate
        }), [requests, statusFilter, dateFilter])

    const counts = requests.reduce((result, request) => {
        const status = normalizeStatus(request.status)
        if (status in result) result[status] += 1
        return result
    }, { pending: 0, approved: 0, rejected: 0 })

    const pageCount = Math.max(1, Math.ceil(visibleRequests.length / pageSize))
    const pageRequests = visibleRequests.slice((page - 1) * pageSize, page * pageSize)

    const updateStatus = async (requestId, status) => {
        setPendingAction({ requestId, status, type: 'status' })
    }

    const requestDelete = (requestId) => setPendingAction({ requestId, type: 'delete' })

    const confirmStatusUpdate = async () => {
        if (!pendingAction) return
        const { requestId, status, type } = pendingAction
        setPendingAction(null)
        setUpdatingId(requestId)
        setError('')
        try {
            if (type === 'delete') {
                await deleteMemoryRequest(session, requestId)
                setRequests((current) => current.filter((request) => request.id !== requestId))
            } else {
                await updateMemoryRequestStatus(session, requestId, status)
                setRequests((current) => current.map((request) => request.id === requestId ? { ...request, status } : request))
            }
        } catch {
            setError(GENERIC_ERROR)
        } finally {
            setUpdatingId(null)
        }
    }

    return (
        <div className="dashboard-page memory-requests-page">
            <NavBar />
            <main className="memory-requests-content">
                <button className="dashboard-back-button" type="button" onClick={() => navigate('/dashboard')}><ArrowLeft size={16} /> Back to dashboard</button>
                <header className="memory-requests-hero">
                    <p className="eyebrow">Staff tool</p>
                    <h1>Gallery Request Review</h1>
                    <p>Review memory submissions, preview images, and update request status.</p>
                    <div className="request-counts">
                        <span className="request-count pending-count">Pending: {counts.pending}</span>
                        <span className="request-count approved-count">Approved: {counts.approved}</span>
                        <span className="request-count rejected-count">Rejected: {counts.rejected}</span>
                    </div>
                </header>

                {!authReady || loading ? <section className="dashboard-panel dashboard-loading"><LoaderCircle className="gallery-manager-spinner" size={22} />Loading memory requests...</section> : !session ? (
                    <section className="dashboard-panel announcement-denied"><ShieldAlert size={24} /><h2>Sign in required</h2><p>Please sign in with Discord to continue.</p><button className="dashboard-primary-button" type="button" onClick={() => navigate('/dashboard')}>Open dashboard</button></section>
                ) : !allowed ? (
                    <section className="dashboard-panel announcement-denied"><ShieldAlert size={24} /><h2>Staff access required</h2><p>This tool is available to staff members only.</p></section>
                ) : (
                    <>
                        <div className="memory-request-toolbar">
                            <label><Filter size={15} />Status<select value={statusFilter} onChange={(event) => { setStatusFilter(event.target.value); setPage(1) }}><option value="all">All</option><option value="pending">Pending</option><option value="approved">Approved</option><option value="rejected">Rejected</option></select></label>
                            <label><CalendarDays size={15} />Date<select value={dateFilter} onChange={(event) => { setDateFilter(event.target.value); setPage(1) }}><option value="newest">Newest</option><option value="oldest">Oldest</option></select></label>
                        </div>
                        {error && <p className="dashboard-error" role="alert">{error}</p>}
                        <section className="memory-request-list" aria-label="Memory requests">
                            {visibleRequests.length === 0 ? <div className="dashboard-panel dashboard-loading">No memory requests match these filters.</div> : pageRequests.map((request) => {
                                const status = normalizeStatus(request.status)
                                const imageUrl = getImageUrl(request)
                                return <article className="memory-request-card dashboard-panel" key={request.id}>
                                    <div className="memory-request-image">{imageUrl ? <img src={imageUrl} alt={request.title || 'Memory request'} loading="lazy" /> : <Image size={28} />}</div>
                                    <div className="memory-request-details">
                                        <div className="memory-request-topline"><span className={`request-status request-status-${status}`}>{request.status || 'Pending'}</span><small>Request #{request.id}</small></div>
                                        <h2>{request.title || 'Untitled memory'}</h2>
                                        <p className="memory-request-uploader">Uploaded by <strong>{request.display_name || 'Unknown member'}</strong></p>
                                        <p className="memory-request-meta"><span>UUID: {request.request_uuid || 'Unavailable'}</span><span>Taken: {formatDate(request.date_taken)}</span><span>Submitted: {formatDate(request.created_at)}</span></p>
                                        <div className="memory-request-actions">
                                            {status === 'pending' && <button className="memory-approve-button" type="button" disabled={updatingId === request.id} onClick={() => updateStatus(request.id, 'Approved')}><Check size={14} />Approve</button>}
                                            {status !== 'rejected' && <button className="memory-reject-button" type="button" disabled={updatingId === request.id} onClick={() => updateStatus(request.id, 'Rejected')}><X size={14} />Reject</button>}
                                            <button className="memory-delete-button" type="button" disabled={updatingId === request.id} onClick={() => requestDelete(request.id)}>Delete</button>
                                        </div>
                                    </div>
                                </article>
                            })}
                        </section>
                        {visibleRequests.length > 0 && <nav className="memory-pagination" aria-label="Memory request pages">
                            <button type="button" disabled={page === 1} onClick={() => setPage((current) => current - 1)} aria-label="Previous page"><ChevronLeft size={16} /></button>
                            <span>Page {page} of {pageCount}</span>
                            <button type="button" disabled={page >= pageCount} onClick={() => setPage((current) => current + 1)} aria-label="Next page"><ChevronRight size={16} /></button>
                        </nav>}
                    </>
                )}
            </main>
            <ConfirmDialog
                open={Boolean(pendingAction)}
                title={`${pendingAction?.status || 'Update'} memory request?`}
                confirmLabel={pendingAction?.type === 'delete' ? 'Delete request' : pendingAction?.status || 'Confirm'}
                message={pendingAction?.type === 'delete' ? 'This request and its uploaded image will be removed.' : `This request will be marked as ${pendingAction?.status?.toLowerCase() || 'updated'}.`}
                secondaryLabel={pendingAction?.type === 'status' ? 'Delete instead' : undefined}
                onSecondary={() => pendingAction && requestDelete(pendingAction.requestId)}
                destructive={pendingAction?.type === 'delete' || pendingAction?.status === 'Rejected'}
                onConfirm={confirmStatusUpdate}
                onCancel={() => setPendingAction(null)}
            />
        </div>
    )
}
