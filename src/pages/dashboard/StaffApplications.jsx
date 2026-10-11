import { useEffect, useState } from 'react'
import { ArrowLeft, Check, ChevronDown, FileText, LoaderCircle, ShieldAlert, ThumbsDown, ThumbsUp, ToggleLeft, X } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { ConfirmDialog } from '../../components/ConfirmDialog'
import { checkOwner, checkStaffAccess, finalizeStaffApplication, getStaffApplicationStatus, getSubmittedApplications, submitStaffVote, updateStaffApplicationStatus } from '../../lib/api'
import NavBar from '../../components/Navbar'
import { supabase } from '../../lib/supabase'
import './dashboard.css'

const GENERIC_ERROR = 'Something went wrong. Please try again.'

function getApplicationStatus(application) {
    return String(application.status || 'pending').toLowerCase()
}

function formatLabel(value) {
    return String(value || 'Question')
        .replace(/^question_[^_]+_/, '')
        .replace(/[_-]+/g, ' ')
        .replace(/\b\w/g, (letter) => letter.toUpperCase())
}

function formatAnswer(value) {
    if (value === null || value === undefined || value === '') return 'No answer provided'
    if (Array.isArray(value)) return value.join(', ')
    if (typeof value === 'object') return Object.values(value).join(', ')
    return String(value)
}

function parseAnswers(application) {
    if (Array.isArray(application.answers)) return application.answers
    if (typeof application.answers === 'string') {
        try {
            const parsed = JSON.parse(application.answers)
            return Array.isArray(parsed) ? parsed : []
        } catch {
            return []
        }
    }
    return Object.entries(application.answers || {}).map(([key, value]) => ({ key, label: key, value }))
}

function getHiddenAnswer(application, label) {
    return parseAnswers(application).find((answer) => (
        String(answer.type || '').toUpperCase() === 'HIDDEN_FIELDS'
        && String(answer.label || '').toLowerCase() === label
    ))?.value
}

function getVoteList(application, ...keys) {
    for (const key of keys) {
        const value = application[key]
        if (Array.isArray(value)) return value.map(String)
    }
    return []
}

function getYesVotes(application) {
    return getVoteList(application, 'voted_yes_uids', 'voted_yes', 'yes_votes', 'yesVoters')
}

function getNoVotes(application) {
    return getVoteList(application, 'voted_no_uids', 'voted_no', 'no_votes', 'noVoters')
}

function getReviewNote(application) {
    const note = application.staff_review ?? application.review_explanation ?? application.review_note ?? application.decision_note ?? application.owner_note
    return typeof note === 'string' && note.trim() ? note.trim() : ''
}

function formatReviewDate(value) {
    if (!value) return ''
    const date = new Date(value)
    if (Number.isNaN(date.getTime())) return String(value)
    return date.toLocaleString()
}

function getAnswerRows(application) {
    const answers = parseAnswers(application)

    return answers
        .filter((answer) => String(answer.type || '').toUpperCase() !== 'HIDDEN_FIELDS')
        .map((answer) => ({
            label: formatLabel(answer.label || answer.question || answer.key),
            value: formatAnswer(answer.value ?? answer.answer ?? answer.text),
        }))
}

function isLocalOwnerSession(session) {
    const supabaseOwnerId = String(session?.user?.id || '').trim().toLowerCase()
    const envOwnerId = String(import.meta.env.VITE_OWNER_UUID_ID || '19e0cc2d-4e3a-412f-85cf-b185c50a5b2e').trim().toLowerCase()
    return Boolean(supabaseOwnerId && envOwnerId && supabaseOwnerId === envOwnerId)
}

export default function StaffApplications() {
    const navigate = useNavigate()
    const [session, setSession] = useState(null)
    const [authReady, setAuthReady] = useState(!supabase)
    const [checking, setChecking] = useState(true)
    const [allowed, setAllowed] = useState(false)
    const [isOwner, setIsOwner] = useState(false)
    const [isOpen, setIsOpen] = useState(false)
    const [applications, setApplications] = useState([])
    const [selected, setSelected] = useState(null)
    const [explanation, setExplanation] = useState('')
    const [pendingDecision, setPendingDecision] = useState('')
    const [pendingStatusChange, setPendingStatusChange] = useState(null)
    const [error, setError] = useState('')
    const [notice, setNotice] = useState('')
    const [saving, setSaving] = useState(false)
    const [busyApplicationId, setBusyApplicationId] = useState('')
    const [expandedApplications, setExpandedApplications] = useState({})

    const isExpanded = (applicationUid) => Boolean(expandedApplications[String(applicationUid)])

    const toggleExpanded = (applicationUid) => {
        setExpandedApplications((current) => ({
            ...current,
            [String(applicationUid)]: !current[String(applicationUid)],
        }))
    }

    const expandAll = () => {
        setExpandedApplications((current) => {
            const next = { ...current }
            applications.forEach((application) => {
                next[String(application.user_id || application.id)] = true
            })
            return next
        })
    }

    const collapseAll = () => setExpandedApplications({})

    useEffect(() => {
        if (!supabase) return undefined
        supabase.auth.getSession().then(({ data }) => { setSession(data.session); setAuthReady(true) })
        const { data: listener } = supabase.auth.onAuthStateChange((_event, nextSession) => setSession(nextSession))
        return () => listener.subscription.unsubscribe()
    }, [])

    useEffect(() => {
        if (!session) return undefined
        let active = true
        const localOwner = isLocalOwnerSession(session)
        // Immediate Supabase-UUID match so owner UI never waits on / fails with the backend check.
        if (localOwner) {
            queueMicrotask(() => {
                if (!active) return
                setIsOwner(true)
                setAllowed(true)
            })
        }
        Promise.allSettled([checkOwner(session), checkStaffAccess(session)])
            .then(async ([ownerResult, staffResult]) => {
                if (!active) return
                let ownerValue = ownerResult.status === 'fulfilled' ? ownerResult.value : false
                if (!ownerValue && localOwner) ownerValue = true
                setIsOwner(ownerValue)
                let isStaff = staffResult.status === 'fulfilled' ? staffResult.value : false
                if (!isStaff && ownerValue) isStaff = true
                const hasAccess = ownerValue || isStaff
                setAllowed(hasAccess)
                if (!hasAccess) return
                try {
                    const [statusPayload, applicationPayload] = await Promise.all([getStaffApplicationStatus(), getSubmittedApplications(session)])
                    if (!active) return
                    const statusRecord = Array.isArray(statusPayload) ? statusPayload[0] : statusPayload?.data?.[0] || statusPayload
                    setIsOpen(Boolean(statusRecord?.is_open))
                    setApplications(Array.isArray(applicationPayload) ? applicationPayload : applicationPayload?.data || [])
                } catch {
                    if (active) setError(GENERIC_ERROR)
                }
            })
            .catch(() => { if (active) setError(GENERIC_ERROR) })
            .finally(() => { if (active) setChecking(false) })
        return () => { active = false }
    }, [session])

    const requestStatusChange = () => {
        if (!isOwner) {
            setError('Only the owner can open or close staff applications.')
            return
        }
        setError('')
        setPendingStatusChange(!isOpen)
    }

    const confirmStatusChange = async () => {
        if (pendingStatusChange === null) return
        if (!isOwner) {
            setError('Only the owner can open or close staff applications.')
            setPendingStatusChange(null)
            return
        }
        setSaving(true)
        setError('')
        try {
            await updateStaffApplicationStatus(session, pendingStatusChange)
            setIsOpen(pendingStatusChange)
            setPendingStatusChange(null)
        } catch {
            setError(GENERIC_ERROR)
        } finally {
            setSaving(false)
        }
    }

    const refreshApplications = async () => {
        const applicationPayload = await getSubmittedApplications(session)
        const rows = Array.isArray(applicationPayload) ? applicationPayload : applicationPayload?.data || []
        setApplications(rows)
        return rows
    }

    const vote = async (application, voteType) => {
        const applicationUid = application.user_id || application.id
        if (!applicationUid) {
            setError('Unable to vote: missing applicant UID.')
            return
        }
        setBusyApplicationId(String(applicationUid))
        setError('')
        setNotice('')
        try {
            const result = await submitStaffVote(session, applicationUid, voteType)
            const rows = await refreshApplications()
            const updated = rows.find((row) => String(row.user_id || row.id) === String(applicationUid))
            const yesCount = updated ? getYesVotes(updated).length : (result?.yes_votes ?? result?.data?.yes_votes ?? getYesVotes(application).length)
            const noCount = updated ? getNoVotes(updated).length : (result?.no_votes ?? result?.data?.no_votes ?? getNoVotes(application).length)
            setNotice(`Your ${voteType === 'YES' ? 'yes' : 'no'} vote was recorded. Current tally: ${yesCount} yes / ${noCount} no.`)
        } catch {
            setError('Unable to record your vote. Check staff permissions / RLS and try again.')
        } finally {
            setBusyApplicationId('')
        }
    }

    const requestDecision = (application, decision) => {
        if (!isOwner) {
            setError('Only the owner can accept or reject staff applications.')
            return
        }
        setSelected(application)
        setPendingDecision(decision)
        setError('')
        setNotice('')
    }

    const finalize = async () => {
        if (!isOwner) {
            setError('Only the owner can accept or reject staff applications.')
            setPendingDecision('')
            return
        }
        if (!selected || !explanation.trim()) {
            if (pendingDecision === 'deny') {
                setSelected(selected)
                setError('A reason is required to reject. Type the denial reason in the review note first.')
            } else {
                setError('Add a review note before finalizing.')
                setPendingDecision('')
            }
            return
        }
        const applicationUid = selected.user_id || selected.id
        if (!applicationUid) {
            setError('Unable to finalize: missing applicant UID.')
            return
        }
        setBusyApplicationId(String(applicationUid))
        setPendingDecision('')
        setSaving(true)
        setError('')
        setNotice('')
        try {
            const finalStatus = selectedDecision()
            await finalizeStaffApplication(session, applicationUid, finalStatus, explanation.trim())
            await refreshApplications()
            setNotice(`Application ${finalStatus.toLowerCase()}.`)
            setSelected(null)
            setExplanation('')
        } catch {
            setError(GENERIC_ERROR)
        } finally {
            setSaving(false)
            setBusyApplicationId('')
        }
    }

    const selectedDecision = () => pendingDecision === 'approve' ? 'APPROVED' : 'DENIED'

    const selectedDecisionLabel = () => pendingDecision === 'approve' ? 'Accept' : 'Reject'

    return (
        <div className="dashboard-page staff-applications-page">
            <NavBar />
            <main className="applications-content">
                <button className="dashboard-back-button" type="button" onClick={() => navigate('/dashboard')}><ArrowLeft size={16} /> Back to dashboard</button>
                <header className="dashboard-blue-hero"><p className="eyebrow">Staff tool</p><h1>Staff Application Admin</h1><p>Manage and review community submissions.</p></header>
                {!authReady || checking ? <section className="dashboard-panel dashboard-loading"><LoaderCircle className="gallery-manager-spinner" size={22} />Checking staff access...</section> : !session || !allowed ? <section className="dashboard-panel announcement-denied"><ShieldAlert size={24} /><h2>{session ? 'Staff access required' : 'Sign in required'}</h2><p>{session ? 'This tool is available to staff members only.' : 'Please sign in with Discord to continue.'}</p></section> : (
                    <>
                        <section className="application-status-panel dashboard-panel"><ToggleLeft size={18} /><strong>Applications Status: {isOpen ? 'Open' : 'Closed'}</strong>{isOwner ? <button type="button" onClick={requestStatusChange} disabled={saving}>{isOpen ? 'Close applications' : 'Open applications'}</button> : <span className="application-status-locked">Only the owner can open or close applications.</span>}</section>
                        {error && <p className="dashboard-error" role="alert">{error}</p>}
                        {notice && <p className="dashboard-success" role="status">{notice}</p>}
                        {isOwner && <p className="dashboard-success" role="status">Owner mode: Accept / Reject controls are enabled.</p>}
                        <div className="applications-section-heading">
                            <h2 className="applications-section-title">Submitted Applications</h2>
                            {applications.length > 0 && (
                                <div className="applications-expand-controls">
                                    <button type="button" onClick={expandAll}>Expand all</button>
                                    <button type="button" onClick={collapseAll}>Collapse all</button>
                                </div>
                            )}
                        </div>
                        <section className="application-list">
                            {applications.length === 0 ? <div className="dashboard-panel dashboard-loading">No applications submitted yet.</div> : applications.map((application) => {
                                const status = getApplicationStatus(application)
                                const answerRows = getAnswerRows(application)
                                const applicationUid = application.user_id || application.id
                                const yesVotes = getYesVotes(application)
                                const noVotes = getNoVotes(application)
                                const isBusy = busyApplicationId && String(busyApplicationId) === String(applicationUid)
                                const reviewNote = getReviewNote(application)
                                const reviewedAt = formatReviewDate(application.reviewed_at || application.reviewedAt)
                                const expanded = isExpanded(applicationUid)
                                return <article className="application-card dashboard-panel" key={application.user_id || application.id}>
                                    <div className="application-card-heading"><FileText size={18} /><h3>{application.username || application.display_name || getHiddenAnswer(application, 'username') || 'Unknown applicant'}</h3><span className={`request-status request-status-${status}`}>{application.status || 'Pending'}</span></div>
                                    <p className="application-uid">Applicant UID: {application.user_id || 'Unavailable'}</p>
                                    <p className="application-vote-tally" role="status">Yes votes: {yesVotes.length} • No votes: {noVotes.length}</p>
                                    {status !== 'pending' && (
                                        <div className={`application-reason application-reason-${status}`} role="note">
                                            <strong>{status === 'denied' ? 'Denial reason' : status === 'approved' ? 'Approval note' : 'Decision note'}</strong>
                                            <p>{reviewNote || 'No reason was recorded for this decision.'}</p>
                                            {reviewedAt && <small>Decided: {reviewedAt}</small>}
                                        </div>
                                    )}
                                    <div className="application-responses">
                                        <button
                                            type="button"
                                            className={`application-responses-toggle${expanded ? ' application-responses-toggle-open' : ''}`}
                                            onClick={() => toggleExpanded(applicationUid)}
                                            aria-expanded={expanded}
                                            aria-controls={`application-responses-${applicationUid}`}
                                        >
                                            <span>{expanded ? 'Hide responses' : `View responses (${answerRows.length})`}</span>
                                            <ChevronDown size={16} aria-hidden="true" />
                                        </button>
                                        {expanded && (
                                            <div className="application-answers" id={`application-responses-${applicationUid}`}>
                                                {answerRows.length === 0 ? <p className="application-empty-answer">No application answers provided.</p> : answerRows.map((answer, index) => <div className="application-answer" key={`${answer.label}-${index}`}><span>{answer.label}</span><strong>{answer.value}</strong></div>)}
                                            </div>
                                        )}
                                    </div>
                                    {status === 'pending' && isOwner && <label className="application-review-note">Review note (required to reject, shown as the reason)<textarea value={selected?.user_id === application.user_id ? explanation : ''} onChange={(event) => { setSelected(application); setExplanation(event.target.value) }} placeholder="e.g. Rejected: answers look AI-generated, no real moderation experience..." /></label>}
                                    {status !== 'pending' && !reviewNote && isOwner && <label className="application-review-note">Add / update decision note<textarea value={selected?.user_id === application.user_id ? explanation : ''} onChange={(event) => { setSelected(application); setExplanation(event.target.value) }} placeholder="Type the reason, then Accept or Reject again to save it..." /></label>}
                                    <div className="application-actions"><button type="button" onClick={() => vote(application, 'YES')} disabled={Boolean(isBusy)}><ThumbsUp size={14} />{isBusy ? 'Saving...' : `Vote yes (${yesVotes.length})`}</button><button type="button" onClick={() => vote(application, 'NO')} disabled={Boolean(isBusy)}><ThumbsDown size={14} />{isBusy ? 'Saving...' : `Vote no (${noVotes.length})`}</button>{status === 'pending' && isOwner && <><button className="application-approve" type="button" onClick={() => requestDecision(application, 'approve')} disabled={Boolean(isBusy)}><Check size={14} />Accept</button><button className="application-deny" type="button" onClick={() => requestDecision(application, 'deny')} disabled={Boolean(isBusy)}><X size={14} />Reject</button></>}{status === 'pending' && !isOwner && <span className="application-status-locked">Only the owner can accept or reject applications.</span>}{status !== 'pending' && isOwner && <span className={`application-decision-note application-decision-${status}`}>Decision: {application.status || status}<button className="application-approve" type="button" onClick={() => requestDecision(application, 'approve')} disabled={Boolean(isBusy)}><Check size={14} />Accept</button><button className="application-deny" type="button" onClick={() => requestDecision(application, 'deny')} disabled={Boolean(isBusy)}><X size={14} />Reject</button></span>}</div>
                                </article>
                            })}
                        </section>
                    </>
                )}
            </main>
            <ConfirmDialog open={Boolean(pendingDecision)} title={`${selectedDecisionLabel()} application?`} message="This decision will update the submitted staff application." confirmLabel={selectedDecisionLabel()} onConfirm={finalize} onCancel={() => setPendingDecision('')} />
            <ConfirmDialog open={pendingStatusChange !== null} title={pendingStatusChange ? 'Open staff applications?' : 'Close staff applications?'} message={pendingStatusChange ? 'This will allow new staff applications to be submitted.' : 'This will stop new staff applications from being submitted.'} confirmLabel={pendingStatusChange ? 'Open applications' : 'Close applications'} destructive={!pendingStatusChange} onConfirm={confirmStatusChange} onCancel={() => setPendingStatusChange(null)} />
        </div>
    )
}
