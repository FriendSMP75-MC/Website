import { useEffect, useState } from 'react'
import { Check, Copy, LogIn, LogOut, Plus, ShieldCheck, Trash2, UserRound } from 'lucide-react'
import NavBar from '../../components/Navbar'
import { signOutImmediately, supabase } from '../../lib/supabase'
import { addStaffUuid, checkOwner, checkStaffAccess, deleteStaffUuid, getStaffUuids } from '../../lib/api'
import { StaffApps } from './StaffApps'
import { MemberApps } from './MemberApps'
import './dashboard.css'

const GENERIC_ERROR = 'Something went wrong. Please try again.'

function getStaffName(record) {
    return record.staff_display_name || record.nickname || record.name || 'Staff member'
}

function getStaffUuid(record) {
    return record.staff_uid || record.uuid || record.id
}

export default function Dashboard() {
    const [session, setSession] = useState(null)
    const [owner, setOwner] = useState(false)
    const [staffAccess, setStaffAccess] = useState(false)
    const [staff, setStaff] = useState([])
    const [loading, setLoading] = useState(true)
    const [error, setError] = useState('')
    const [uuid, setUuid] = useState('')
    const [nickname, setNickname] = useState('')
    const [saving, setSaving] = useState(false)
    const [dashboardView, setDashboardView] = useState('staff')
    const [copiedId, setCopiedId] = useState('')

    const discordId = session?.user.identities?.find((identity) => identity.provider === 'discord')?.identity_data?.provider_id

    const copyId = async (value, label) => {
        try {
            await navigator.clipboard.writeText(value)
            setCopiedId(label)
            window.setTimeout(() => setCopiedId(''), 1600)
        } catch {
            setError(GENERIC_ERROR)
        }
    }

    useEffect(() => {
        if (!supabase) return undefined

        supabase.auth.getSession().then(({ data }) => setSession(data.session))
        const { data: listener } = supabase.auth.onAuthStateChange((_event, nextSession) => setSession(nextSession))
        return () => listener.subscription.unsubscribe()
    }, [])

    useEffect(() => {
        if (!session) return undefined

        let active = true
        checkOwner(session)
            .then(async (isOwner) => {
                if (!active) return
                setOwner(isOwner)
                if (isOwner) {
                    setStaffAccess(true)
                    const staffRecords = await getStaffUuids(session)
                    if (active) setStaff(Array.isArray(staffRecords) ? staffRecords : [])
                    return
                }

                const isStaff = await checkStaffAccess(session)
                if (!active) return
                setStaffAccess(isStaff)
                if (!isStaff) setDashboardView('member')
            })
            .catch(() => {
                if (!active) return
                setOwner(false)
                setStaffAccess(false)
                setDashboardView('member')
                setError(GENERIC_ERROR)
            })
            .finally(() => {
                if (active) setLoading(false)
            })

        return () => { active = false }
    }, [session])

    const signInWithDiscord = async () => {
        if (!supabase) {
            setError(GENERIC_ERROR)
            return
        }
        const { error: signInError } = await supabase.auth.signInWithOAuth({
            provider: 'discord',
            options: { redirectTo: `${window.location.origin}/dashboard` },
        })
        if (signInError) setError(GENERIC_ERROR)
    }

    const handleAddStaff = async (event) => {
        event.preventDefault()
        if (!uuid.trim() || !nickname.trim()) return

        setSaving(true)
        setError('')
        try {
            await addStaffUuid(session, uuid.trim(), nickname.trim())
            setStaff(await getStaffUuids(session))
            setUuid('')
            setNickname('')
        } catch {
            setError(GENERIC_ERROR)
        } finally {
            setSaving(false)
        }
    }

    const handleDeleteStaff = async (staffUuid) => {
        try {
            await deleteStaffUuid(session, staffUuid)
            setStaff((current) => current.filter((record) => getStaffUuid(record) !== staffUuid))
        } catch {
            setError(GENERIC_ERROR)
        }
    }

    return (
        <div className="dashboard-page">
            <NavBar />
            <main className="dashboard-content">
                <header className="dashboard-intro">
                    <p className="eyebrow">Staff / Member area</p>
                    <h1>Dashboard</h1>
                    <p>Manage your FriendSMP75 account and community tools.</p>
                </header>

                {!session ? (
                    <section className="dashboard-login dashboard-panel">
                        <div className="dashboard-icon"><LogIn size={22} /></div>
                        <h2>Sign in with Discord</h2>
                        <p>Use your Discord account to access the FriendSMP75 dashboard.</p>
                        {error && <p className="dashboard-error" role="alert">{error}</p>}
                        <button className="dashboard-primary-button" type="button" onClick={signInWithDiscord}>
                            <LogIn size={16} /> Continue with Discord
                        </button>
                    </section>
                ) : (
                    <>
                        <section className="dashboard-welcome dashboard-panel">
                            <div>
                                <p className="eyebrow">Signed in</p>
                                <h2>Welcome{session.user.user_metadata?.full_name ? `, ${session.user.user_metadata.full_name}` : ''}.</h2>
                                <p>
                                    {loading
                                        ? 'Checking your dashboard access...'
                                        : owner
                                            ? 'Owner access is enabled for this account.'
                                            : staffAccess
                                                ? 'Your staff and member tools are ready.'
                                                : 'Your member tools are ready.'}
                                </p>
                            </div>
                            <button className="dashboard-secondary-button" type="button" onClick={() => signOutImmediately()}><LogOut size={15} /> Sign out</button>
                        </section>

                        <section className="dashboard-identity dashboard-panel" aria-label="Account identifiers">
                            <div className="dashboard-identity-value">
                                <span className="dashboard-identity-label">Supabase UID</span>
                                <code>{session.user.id}</code>
                            </div>
                            <button className="dashboard-copy-button" type="button" onClick={() => copyId(session.user.id, 'uid')}>
                                {copiedId === 'uid' ? <Check size={14} /> : <Copy size={14} />}
                                {copiedId === 'uid' ? 'Copied' : 'Copy UID'}
                            </button>
                            {discordId && <div className="dashboard-identity-secondary">
                                <span className="dashboard-identity-label">Discord ID</span>
                                <code>{discordId}</code>
                                <button className="dashboard-copy-button" type="button" onClick={() => copyId(discordId, 'discord')}>
                                    {copiedId === 'discord' ? <Check size={14} /> : <Copy size={14} />}
                                    {copiedId === 'discord' ? 'Copied' : 'Copy ID'}
                                </button>
                            </div>}
                        </section>

                        {error && <p className="dashboard-error" role="alert">{error}</p>}
                        {(owner || staffAccess) && <div className="dashboard-tabs" role="tablist" aria-label="Dashboard views">
                            <button className={dashboardView === 'staff' ? 'dashboard-tab dashboard-tab-active' : 'dashboard-tab'} type="button" role="tab" aria-selected={dashboardView === 'staff'} onClick={() => setDashboardView('staff')}>Staff Dashboard</button>
                            <button className={dashboardView === 'member' ? 'dashboard-tab dashboard-tab-active' : 'dashboard-tab'} type="button" role="tab" aria-selected={dashboardView === 'member'} onClick={() => setDashboardView('member')}>Member Dashboard</button>
                        </div>}
                        {loading ? <div className="dashboard-panel dashboard-loading">Checking dashboard permissions...</div> : dashboardView === 'staff' && (owner || staffAccess) ? (
                            <>
                            {owner && <section className="owner-panel dashboard-panel" aria-labelledby="owner-title">
                                <div className="dashboard-section-heading">
                                    <div className="dashboard-icon"><ShieldCheck size={21} /></div>
                                    <div><h2 id="owner-title">Owner Controls</h2><p>Add or remove staff UUID access records.</p></div>
                                </div>
                                <form className="staff-form" onSubmit={handleAddStaff}>
                                    <input value={uuid} onChange={(event) => setUuid(event.target.value)} placeholder="Enter UUID" aria-label="Staff UUID" />
                                    <input value={nickname} onChange={(event) => setNickname(event.target.value)} placeholder="Nickname" aria-label="Staff nickname" />
                                    <button className="dashboard-primary-button" type="submit" disabled={saving}><Plus size={16} /> {saving ? 'Adding...' : 'Add'}</button>
                                </form>
                                <h3>Staff UUIDs</h3>
                                <div className="staff-list">
                                    {staff.map((record) => {
                                        const staffUuid = getStaffUuid(record)
                                        return <div className="staff-record" key={staffUuid}><UserRound size={17} /><span><strong>{getStaffName(record)}</strong><small>{staffUuid}</small></span><button type="button" aria-label={`Remove ${getStaffName(record)}`} onClick={() => handleDeleteStaff(staffUuid)}><Trash2 size={15} /></button></div>
                                    })}
                                </div>
                            </section>}
                            <StaffApps />
                            </>
                        ) : dashboardView === 'staff' ? (
                            <section className="dashboard-panel staff-panel">
                                <div className="dashboard-icon"><ShieldCheck size={21} /></div>
                                <h2>Staff access required</h2>
                                <p>This account can only access the Member Dashboard.</p>
                                <button className="dashboard-primary-button" type="button" onClick={() => setDashboardView('member')}>Open Member Dashboard</button>
                            </section>
                        ) : (
                            <MemberApps />
                        )}
                    </>
                )}
            </main>
        </div>
    )
}
