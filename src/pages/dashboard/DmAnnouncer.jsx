import { useEffect, useMemo, useState } from 'react'
import { ArrowLeft, Check, LoaderCircle, Send, ShieldAlert, UserRound } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { ConfirmDialog } from '../../components/ConfirmDialog'
import NavBar from '../../components/Navbar'
import { checkOwner, checkStaffAccess, sendDiscordAnnouncement } from '../../lib/api'
import { supabase } from '../../lib/supabase'
import './dashboard.css'

const GENERIC_ERROR = 'Something went wrong. Please try again.'

function parseDiscordIds(value) {
    return [...new Set(value.split(/[\s,\n]+/).map((id) => id.trim()).filter(Boolean))]
}

export default function DmAnnouncer() {
    const navigate = useNavigate()
    const [session, setSession] = useState(null)
    const [authReady, setAuthReady] = useState(!supabase)
    const [checking, setChecking] = useState(true)
    const [allowed, setAllowed] = useState(false)
    const [idsText, setIdsText] = useState('')
    const [message, setMessage] = useState('')
    const [behalfOfStaff, setBehalfOfStaff] = useState(true)
    const [confirmOpen, setConfirmOpen] = useState(false)
    const [sending, setSending] = useState(false)
    const [success, setSuccess] = useState('')
    const [error, setError] = useState('')

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
            .then(([isOwner, isStaff]) => {
                if (active) setAllowed(isOwner || isStaff)
            })
            .catch(() => {
                if (active) setError(GENERIC_ERROR)
            })
            .finally(() => {
                if (active) setChecking(false)
            })
        return () => { active = false }
    }, [session])

    const recipientIds = useMemo(() => parseDiscordIds(idsText), [idsText])
    const senderDiscordId = session?.user.identities?.find((identity) => identity.provider === 'discord')?.identity_data?.provider_id
    const senderName = session?.user.user_metadata?.full_name || session?.user.user_metadata?.user_name || 'Staff member'

    const requestSend = (event) => {
        event.preventDefault()
        if (!recipientIds.length || !message.trim()) {
            setError('Enter at least one Discord ID and a message.')
            return
        }
        setConfirmOpen(true)
    }

    const sendMessage = async () => {
        setConfirmOpen(false)
        setSending(true)
        setError('')
        setSuccess('')
        try {
            await Promise.all(recipientIds.map((recipientId) => sendDiscordAnnouncement(session, {
                recipient_discord_id: recipientId,
                message: message.trim(),
                sender_uuid: session.user.id,
                sender_name: senderName,
                sender_discord_id: senderDiscordId,
                sent_at: new Date().toISOString(),
                server_name: 'FriendSMP75',
                behalfOfStaff,
            })))
            setSuccess(`Message sent to ${recipientIds.length} Discord user${recipientIds.length === 1 ? '' : 's'}.`)
            setIdsText('')
            setMessage('')
        } catch {
            setError(GENERIC_ERROR)
        } finally {
            setSending(false)
        }
    }

    return (
        <div className="dashboard-page dm-announcer-page">
            <NavBar />
            <main className="dm-announcer-content">
                <button className="dashboard-back-button" type="button" onClick={() => navigate('/dashboard')}><ArrowLeft size={16} /> Back to dashboard</button>
                <header className="announcement-hero dm-announcer-hero">
                    <p className="eyebrow">Staff tool</p>
                    <h1>DM Announcer</h1>
                    <p>Send one announcement to multiple users by Discord ID.</p>
                </header>

                {!authReady || checking ? <section className="dashboard-panel dashboard-loading"><LoaderCircle className="gallery-manager-spinner" size={22} />Checking staff access...</section> : !session ? (
                    <section className="dashboard-panel announcement-denied"><ShieldAlert size={24} /><h2>Sign in required</h2><p>Please sign in with Discord to continue.</p></section>
                ) : !allowed ? (
                    <section className="dashboard-panel announcement-denied"><ShieldAlert size={24} /><h2>Staff access required</h2><p>This tool is available to staff members only.</p></section>
                ) : (
                    <form className="dm-announcer-form dashboard-panel" onSubmit={requestSend}>
                        <p className="dm-hint">Use commas, spaces, or new lines between IDs.</p>
                        <p className="dm-hint">Each DM includes sender name, UUID, sender Discord ID, sent time (UTC), and server: FriendSMP75.</p>
                        <textarea value={idsText} onChange={(event) => setIdsText(event.target.value)} placeholder="Discord IDs" aria-label="Discord IDs" />
                        <div className="dm-recipient-row">
                            <span><UserRound size={14} />{recipientIds.length} recipient{recipientIds.length === 1 ? '' : 's'}</span>
                            <span className="dm-id-note">Discord IDs are used directly</span>
                        </div>
                        {recipientIds.length > 0 && <div className="dm-recipient-list">{recipientIds.map((id) => <span key={id}>{id}</span>)}</div>}
                        <textarea value={message} onChange={(event) => setMessage(event.target.value)} placeholder="Message" aria-label="Message" />
                        <div className="dm-form-footer">
                            <button className="dashboard-primary-button" type="submit" disabled={sending}><Send size={15} /> Send to Multiple</button>
                            <label className="dm-staff-checkbox"><input type="checkbox" checked={behalfOfStaff} onChange={(event) => setBehalfOfStaff(event.target.checked)} /> Send on behalf of staff team?</label>
                        </div>
                        {error && <p className="dashboard-error" role="alert">{error}</p>}
                        {success && <p className="dashboard-success" role="status"><Check size={15} />{success}</p>}
                    </form>
                )}
            </main>
            <ConfirmDialog open={confirmOpen} title="Send this announcement?" message={`This message will be sent to ${recipientIds.length} Discord user${recipientIds.length === 1 ? '' : 's'}.`} confirmLabel="Send messages" onConfirm={sendMessage} onCancel={() => setConfirmOpen(false)} />
        </div>
    )
}
