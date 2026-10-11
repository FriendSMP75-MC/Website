import { useEffect, useState } from 'react'
import { ArrowLeft, CalendarDays, Check, CloudUpload, ImagePlus, LoaderCircle, ShieldAlert } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import NavBar from '../../components/Navbar'
import { ConfirmDialog } from '../../components/ConfirmDialog'
import { checkOwner, checkStaffAccess, uploadGalleryImage } from '../../lib/api'
import { supabase } from '../../lib/supabase'
import './dashboard.css'

const GENERIC_ERROR = 'Something went wrong. Please try again.'

export default function GroupPhotoManager() {
    const navigate = useNavigate()
    const [session, setSession] = useState(null)
    const [authReady, setAuthReady] = useState(!supabase)
    const [checking, setChecking] = useState(true)
    const [allowed, setAllowed] = useState(false)
    const [file, setFile] = useState(null)
    const [previewUrl, setPreviewUrl] = useState('')
    const [takenDate, setTakenDate] = useState('')
    const [filename, setFilename] = useState('')
    const [uploading, setUploading] = useState(false)
    const [message, setMessage] = useState('')
    const [error, setError] = useState('')
    const [confirmOpen, setConfirmOpen] = useState(false)

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

    useEffect(() => () => {
        if (previewUrl) URL.revokeObjectURL(previewUrl)
    }, [previewUrl])

    const handleFileChange = (event) => {
        const nextFile = event.target.files?.[0]
        if (!nextFile) return
        if (previewUrl) URL.revokeObjectURL(previewUrl)
        setFile(nextFile)
        setFilename(nextFile.name)
        setPreviewUrl(URL.createObjectURL(nextFile))
        setMessage('')
        setError('')
    }

    const handleUpload = async (event) => {
        event.preventDefault()
        if (!takenDate) {
            setError('Please choose the date when the image was taken.')
            return
        }
        if (!filename.trim()) {
            setError('Please enter a filename for the image.')
            return
        }
        if (!file) {
            setError('Please select an image before uploading.')
            return
        }
        setConfirmOpen(true)
    }

    const confirmUpload = async () => {
        setConfirmOpen(false)
        setUploading(true)
        setError('')
        setMessage('')
        try {
            const user = session.user
            const author = user.user_metadata?.full_name || user.user_metadata?.user_name || user.email || 'Staff member'
            await uploadGalleryImage(session, {
                file,
                author,
                authorUuid: user.id,
                takenDate,
            })
            setMessage('Image added to the gallery successfully.')
            setFile(null)
            setFilename('')
            setTakenDate('')
            setPreviewUrl('')
        } catch {
            setError(GENERIC_ERROR)
        } finally {
            setUploading(false)
        }
    }

    return (
        <div className="dashboard-page gallery-manager-page">
            <NavBar />
            <main className="gallery-manager-content">
                <button className="dashboard-back-button" type="button" onClick={() => navigate('/dashboard')}><ArrowLeft size={16} /> Back to dashboard</button>
                <header className="announcement-hero gallery-manager-hero">
                    <p className="eyebrow">Staff tool</p>
                    <h1>Gallery Upload Manager</h1>
                    <p>Upload high-quality community photos with complete metadata.</p>
                </header>

                {!authReady || checking ? <section className="dashboard-panel dashboard-loading"><LoaderCircle className="gallery-manager-spinner" size={22} />Checking staff access...</section> : !session ? (
                    <section className="dashboard-panel announcement-denied"><ShieldAlert size={24} /><h2>Sign in required</h2><p>Please sign in with Discord to continue.</p><button className="dashboard-primary-button" type="button" onClick={() => navigate('/dashboard')}>Open dashboard</button></section>
                ) : !allowed ? (
                    <section className="dashboard-panel announcement-denied"><ShieldAlert size={24} /><h2>Staff access required</h2><p>This tool is available to staff members only.</p></section>
                ) : (
                    <>
                        <form className="gallery-upload-form dashboard-panel" onSubmit={handleUpload}>
                            <label className="gallery-field"><span><CalendarDays size={15} />Date when image was taken</span><input required type="date" value={takenDate} onChange={(event) => setTakenDate(event.target.value)} /></label>
                            <label className="gallery-field"><span><ImagePlus size={15} />Filename</span><input required value={filename} onChange={(event) => setFilename(event.target.value)} placeholder="Image filename" /></label>
                            <label className="gallery-file-button dashboard-primary-button">
                                <CloudUpload size={15} /> Select Image
                                <input required type="file" accept="image/*" onChange={handleFileChange} />
                            </label>
                            {error && <p className="dashboard-error" role="alert">{error}</p>}
                            {message && <p className="dashboard-success" role="status"><Check size={15} />{message}</p>}
                        </form>
                        <section className="gallery-preview dashboard-panel">
                            <h2>Preview</h2>
                            <div className="gallery-preview-box">
                                {previewUrl ? <img src={previewUrl} alt="Selected group photo preview" /> : <span>Select image to view preview</span>}
                            </div>
                        </section>
                        <button className="dashboard-primary-button gallery-upload-submit" type="button" onClick={handleUpload} disabled={uploading}><CloudUpload size={15} />{uploading ? 'Uploading...' : 'Add Image To Gallery'}</button>
                    </>
                )}
            </main>
            <ConfirmDialog
                open={confirmOpen}
                title="Add image to gallery?"
                message="This image will be added to the public FriendSMP75 group photo gallery."
                confirmLabel="Add image"
                onConfirm={confirmUpload}
                onCancel={() => setConfirmOpen(false)}
            />
        </div>
    )
}
