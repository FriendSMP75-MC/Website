import { ArrowLeft, Construction } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import NavBar from '../../components/Navbar'
import './dashboard.css'

export default function MemberPlaceholder({ title, description }) {
    const navigate = useNavigate()

    return (
        <div>
            <NavBar />
            <main className="announcement-content">
                <button className="dashboard-back-button" type="button" onClick={() => navigate('/dashboard')}><ArrowLeft size={13} /> Back to dashboard</button>
                <section className="announcement-hero dashboard-panel">
                    <div className="dashboard-icon"><Construction size={21} /></div>
                    <h1>{title}</h1>
                    <p>{description}</p>
                </section>
                <section className="dashboard-panel dashboard-loading">This member app is coming soon. The dashboard card is wired — full functionality lands next.</section>
            </main>
        </div>
    )
}
