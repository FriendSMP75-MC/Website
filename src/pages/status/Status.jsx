import NavBar from '../../components/Navbar'
import './status.css'

const statusUrl = 'https://friendsmp75.instatus.com'

export default function Status() {
    return (
        <div className="status-page">
            <NavBar />
            <main className="status-content">
                <iframe
                    className="status-iframe"
                    title="FriendSMP75 status page"
                    src={statusUrl}
                    frameBorder="0"
                />
            </main>
        </div>
    )
}
