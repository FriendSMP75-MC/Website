import {
    BookOpenText,
    BriefcaseBusiness,
    ShieldCheck,
} from 'lucide-react'
import { useNavigate } from 'react-router-dom'

const memberApps = [
    { title: 'Memories upload request', description: 'Request staff to review and add your community memory to the public gallery.', action: 'Request', path: '/dashboard/memories-upload', icon: BookOpenText, className: 'member-app-teal' },
    { title: 'Staff applications', description: 'View and submit applications for staff opportunities and review updates.', action: 'Open', path: '/dashboard/my-application', icon: BriefcaseBusiness, className: 'member-app-purple' },
    { title: 'Punishment List', description: "Check your punishment history or others player's punishment history", action: 'Check it', path: '/dashboard/punishments', icon: ShieldCheck, className: 'member-app-red' },
]

export function MemberApps() {
    const navigate = useNavigate()

    return (
        <section className="staff-apps" aria-labelledby="member-apps-title">
            <div className="staff-apps-heading">
                <h2 id="member-apps-title">Member Dashboard</h2>
                <p>Submit your memories for staff review and keep community highlights growing.</p>
            </div>
            <div className="staff-app-grid member-app-grid">
                {memberApps.map(({ title, description, action, path, icon: Icon, className }) => (
                    <article
                        className={`staff-app member-app ${className} staff-app-clickable`}
                        key={title}
                        role="button"
                        tabIndex="0"
                        onClick={() => navigate(path)}
                        onKeyDown={(event) => {
                            if (event.key === 'Enter' || event.key === ' ') navigate(path)
                        }}
                    >
                        <div className="staff-app-title"><span className="staff-app-icon"><Icon size={18} /></span><h3>{title}</h3></div>
                        <p>{description}</p>
                        <button type="button" className="staff-app-action" onClick={(event) => { event.stopPropagation(); navigate(path) }}>{action}<span aria-hidden="true">→</span></button>
                    </article>
                ))}
            </div>
        </section>
    )
}
