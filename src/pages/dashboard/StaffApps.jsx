import {
    FileCheck2,
    ImagePlus,
    Megaphone,
    MessageSquare,
    ServerCog,
} from 'lucide-react'
import { useState } from 'react'
import { useNavigate } from 'react-router-dom'

const staffApps = [
    { title: 'Announcement', description: 'Create and publish server updates for players.', action: 'Manage', path: '/dashboard/announcements', icon: Megaphone, className: 'staff-app-purple' },
    { title: 'Gallery', description: 'Upload new gallery photos for public display.', action: 'Upload', path: '/dashboard/gallery-upload', icon: ImagePlus, className: 'staff-app-blue' },
    { title: 'Approve Gallery Request', description: "Review and approve members' memory submissions.", action: 'Review', path: '/dashboard/memory-requests', icon: FileCheck2, className: 'staff-app-green' },
    { title: 'DM Announcer', description: 'Open the DM announcer app to send one message to multiple Discord users.', action: 'Open Announcer', path: '/dashboard/dm-announcer', icon: MessageSquare, className: 'staff-app-cyan' },
    { title: 'Staff Application', description: 'Open / close / review staff applications.', action: 'Open applications', path: '/dashboard/staff-applications', icon: ServerCog, className: 'staff-app-orange' },
]

export function StaffApps() {
    const navigate = useNavigate()
    const [notice, setNotice] = useState('')

    const handleAppAction = (path, title) => {
        if (path) {
            navigate(path)
            return
        }
        setNotice(`${title} is not connected yet.`)
    }

    return (
        <section className="staff-apps" aria-labelledby="staff-apps-title">
            <div className="staff-apps-heading">
                <h2 id="staff-apps-title">Staff Dashboard</h2>
                <p>Manage announcements, gallery content, memory requests, and server controls.</p>
            </div>
            <div className="staff-app-grid">
                {staffApps.map(({ title, description, action, path, icon: Icon, className }) => (
                    <article
                        className={`staff-app ${className}${path ? ' staff-app-clickable' : ''}`}
                        key={title}
                        role="button"
                        tabIndex="0"
                        onClick={() => handleAppAction(path, title)}
                        onKeyDown={(event) => {
                            if (event.key === 'Enter' || event.key === ' ') handleAppAction(path, title)
                        }}
                    >
                        <div className="staff-app-title"><span className="staff-app-icon"><Icon size={18} /></span><h3>{title}</h3></div>
                        <p>{description}</p>
                        <button type="button" className="staff-app-action" onClick={(event) => { event.stopPropagation(); handleAppAction(path, title) }}>{action}<span aria-hidden="true">→</span></button>
                    </article>
                ))}
            </div>
            {notice && <p className="staff-app-notice" role="status">{notice}</p>}
        </section>
    )
}
