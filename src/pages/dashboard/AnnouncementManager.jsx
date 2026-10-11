import { useEffect, useRef, useState } from 'react'
import { ArrowLeft, Bold, Check, Italic, List, Megaphone, Send, ShieldAlert, Type } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import NavBar from '../../components/Navbar'
import { ConfirmDialog } from '../../components/ConfirmDialog'
import { createAnnouncement, checkOwner, checkStaffAccess } from '../../lib/api'
import { supabase } from '../../lib/supabase'
import './dashboard.css'

const GENERIC_ERROR = 'Something went wrong. Please try again.'

export default function AnnouncementManager() {
    const navigate = useNavigate()
    const editorRef = useRef(null)
    const [session, setSession] = useState(null)
    const [authReady, setAuthReady] = useState(!supabase)
    const [allowed, setAllowed] = useState(false)
    const [checking, setChecking] = useState(true)
    const [title, setTitle] = useState('')
    const [body, setBody] = useState('')
    const [publishing, setPublishing] = useState(false)
    const [message, setMessage] = useState('')
    const [error, setError] = useState('')
    const [confirmOpen, setConfirmOpen] = useState(false)

    useEffect(() => {
        if (!supabase) {
            return undefined
        }

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

    const applyFormat = (prefix, suffix = prefix, placeholder = 'text') => {
        const editor = editorRef.current
        if (!editor) return
        const start = editor.selectionStart
        const end = editor.selectionEnd
        const selected = body.slice(start, end) || placeholder
        const nextBody = `${body.slice(0, start)}${prefix}${selected}${suffix}${body.slice(end)}`
        setBody(nextBody)
        window.setTimeout(() => {
            editor.focus()
            editor.setSelectionRange(start + prefix.length, start + prefix.length + selected.length)
        })
    }

    const publish = async (event) => {
        event.preventDefault()
        if (!title.trim() || !body.trim()) {
            setError('Something went wrong. Please try again.')
            return
        }
        setConfirmOpen(true)
    }

    const confirmPublish = async () => {
        setConfirmOpen(false)
        setPublishing(true)
        setError('')
        setMessage('')
        try {
            const user = session.user
            const author = user.user_metadata?.full_name || user.user_metadata?.user_name || user.email || 'Staff member'
            await createAnnouncement(session, { title: title.trim(), body: body.trim(), author, authorUuid: user.id })
            setTitle('')
            setBody('')
            setMessage('Announcement published successfully.')
        } catch {
            setError(GENERIC_ERROR)
        } finally {
            setPublishing(false)
        }
    }

    return (
        <div className="dashboard-page announcement-page">
            <NavBar />
            <main className="announcement-content">
                <button className="dashboard-back-button" type="button" onClick={() => navigate('/dashboard')}><ArrowLeft size={16} /> Back to dashboard</button>
                <header className="announcement-hero">
                    <p className="eyebrow">Staff tool</p>
                    <h1>Announcement Manager</h1>
                    <p>Write and preview updates before publishing to players.</p>
                </header>

                {!authReady || checking ? <section className="dashboard-panel dashboard-loading">Checking staff access...</section> : !session ? (
                    <section className="dashboard-panel announcement-denied"><ShieldAlert size={24} /><h2>Sign in required</h2><p>Please sign in with Discord to continue.</p><button className="dashboard-primary-button" type="button" onClick={() => navigate('/dashboard')}>Open dashboard</button></section>
                ) : !allowed ? (
                    <section className="dashboard-panel announcement-denied"><ShieldAlert size={24} /><h2>Staff access required</h2><p>This tool is available to staff members only.</p></section>
                ) : (
                    <>
                        <form className="announcement-editor dashboard-panel" onSubmit={publish}>
                            <p className="announcement-hint"><Megaphone size={16} /> Fill in both fields to publish.</p>
                            <input className="announcement-title-input" value={title} onChange={(event) => setTitle(event.target.value)} placeholder="Announcement Title" aria-label="Announcement title" />
                            <div className="format-toolbar" aria-label="Formatting tools">
                                <button type="button" title="Bold" onClick={() => applyFormat('**')}><Bold size={16} /></button>
                                <button type="button" title="Italic" onClick={() => applyFormat('*')}><Italic size={16} /></button>
                                <button type="button" title="Heading" onClick={() => applyFormat('## ', '', 'Heading')}><Type size={16} /></button>
                                <button type="button" title="Bullet list" onClick={() => applyFormat('- ', '', 'List item')}><List size={16} /></button>
                            </div>
                            <textarea ref={editorRef} value={body} onChange={(event) => setBody(event.target.value)} placeholder="Announcement Body" aria-label="Announcement body" />
                            {error && <p className="dashboard-error" role="alert">{error}</p>}
                            {message && <p className="dashboard-success" role="status"><Check size={15} />{message}</p>}
                            <button className="dashboard-primary-button announcement-submit" type="submit" disabled={publishing}><Send size={15} />{publishing ? 'Publishing...' : 'Publish Announcement'}</button>
                        </form>
                        <section className="announcement-preview dashboard-panel" aria-live="polite">
                            <h2>Live Preview</h2>
                            <div className="announcement-preview-content">
                                <h3>{title || 'Announcement title preview'}</h3>
                                <p>{body || 'No announcement body yet'}</p>
                            </div>
                        </section>
                    </>
                )}
            </main>
            <ConfirmDialog
                open={confirmOpen}
                title="Publish announcement?"
                message="This update will be published for the FriendSMP75 community."
                confirmLabel="Publish"
                onConfirm={confirmPublish}
                onCancel={() => setConfirmOpen(false)}
            />
        </div>
    )
}
