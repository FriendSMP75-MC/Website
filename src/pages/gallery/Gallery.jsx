import { useEffect, useState } from 'react'
import { CalendarDays, Image, LoaderCircle, UserRound } from 'lucide-react'
import NavBar from '../../components/Navbar'
import { Footer } from '../../components/Footer'
import { getGalleryPhotos, getMemoryPhotos } from '../../lib/api'
import './gallery.css'

function formatDate(value) {
    if (!value) return 'Date unavailable'
    const date = new Date(value)
    return Number.isNaN(date.getTime())
        ? 'Date unavailable'
        : date.toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric' })
}

function PhotoCard({ photo }) {
    return (
        <article className="gallery-card">
            <div className="gallery-image-wrap">
                <img src={photo.url} alt={photo.title || 'FriendSMP75 group memory'} loading="lazy" />
            </div>
            <div className="gallery-card-meta">
                <span><UserRound size={12} aria-hidden="true" />{photo.upload_name || photo.display_name || photo.author || 'Community member'}</span>
                <span><CalendarDays size={12} aria-hidden="true" />{formatDate(photo.image_taken_date || photo.date_taken || photo.created_at)}</span>
            </div>
        </article>
    )
}

export default function Gallery() {
    const [items, setItems] = useState([])
    const [activeTab, setActiveTab] = useState('photos')
    const [loading, setLoading] = useState(true)
    const [error, setError] = useState('')

    const handleTabChange = (tab) => {
        setActiveTab(tab)
        setLoading(true)
        setError('')
        setItems([])
    }

    useEffect(() => {
        let active = true
        const getItems = activeTab === 'photos' ? getGalleryPhotos : getMemoryPhotos

        getItems()
            .then((items) => {
                if (active) setItems(items)
            })
            .catch(() => {
                if (active) setError('Gallery photos are temporarily unavailable.')
            })
            .finally(() => {
                if (active) setLoading(false)
            })

        return () => { active = false }
    }, [activeTab])

    return (
        <div className="gallery-page">
            <NavBar />
            <main className="gallery-content">
                <header className="gallery-intro">
                    <p className="eyebrow">Gallery</p>
                    <h1>Gallery</h1>
                    <p>Explore the group photos and approved community memories.</p>
                </header>

                <div className="gallery-tabs" role="tablist" aria-label="Gallery categories">
                    <button className={activeTab === 'photos' ? 'gallery-tab gallery-tab-active' : 'gallery-tab'} type="button" role="tab" aria-selected={activeTab === 'photos'} onClick={() => handleTabChange('photos')}>
                        <Image size={14} aria-hidden="true" />Group Photos
                    </button>
                    <button className={activeTab === 'memories' ? 'gallery-tab gallery-tab-active' : 'gallery-tab'} type="button" role="tab" aria-selected={activeTab === 'memories'} onClick={() => handleTabChange('memories')}>
                        Memories
                    </button>
                </div>

                {activeTab === 'photos' && (
                    <section className="gallery-grid" aria-label="Group photos">
                        {loading && <div className="gallery-state"><LoaderCircle className="gallery-spinner" size={22} />Loading group photos...</div>}
                        {!loading && error && <div className="gallery-state">{error}</div>}
                        {!loading && !error && items.length === 0 && <div className="gallery-state">No group photos have been shared yet.</div>}
                        {!loading && !error && items.map((photo) => <PhotoCard key={photo.id || photo.url} photo={photo} />)}
                    </section>
                )}

                {activeTab === 'memories' && (
                    loading ? (
                        <div className="gallery-state gallery-empty-panel"><LoaderCircle className="gallery-spinner" size={22} />Loading memories...</div>
                    ) : error ? (
                        <div className="gallery-state gallery-empty-panel"><span>{error}</span></div>
                    ) : items.length === 0 ? (
                        <div className="gallery-state gallery-empty-panel">
                            <Image size={24} aria-hidden="true" />
                            <strong>No memories have been approved yet.</strong>
                            <span>Approved community memories will appear here.</span>
                        </div>
                    ) : (
                        <section className="gallery-grid" aria-label="Approved memories">
                            {items.map((photo) => <PhotoCard key={photo.id || photo.url} photo={photo} />)}
                        </section>
                    )
                )}
            </main>
            <Footer />
        </div>
    )
}
