import NavBar from '../components/Navbar'
import { Footer } from '../components/Footer'
import './status.css'

const statusUrl = 'https://friendsmp75.instatus.com'

export default function Status() {
    return (
        <div className="status-page">
            <NavBar />
            <main className="status-content">
                <header className="status-intro">
                    <p className="eyebrow">Status / Info-board</p>
                    <h1>Status of FriendSMP75</h1>
                    <p>Check the status of the server, upcoming maintenance, issues and outages.</p>
                </header>

                <section className="status-embed-card" aria-labelledby="status-embed-title">
                    <h2 id="status-embed-title">Live service status</h2>
                    <iframe
                        title="FriendSMP75 live service status"
                        src={`${statusUrl}/embed-status/fc41389b/light-lg`}
                        width="245"
                        height="61"
                        frameBorder="0"
                        scrolling="no"
                    />
                    <a className="status-link" href={statusUrl} target="_blank" rel="noreferrer">
                        Open the full status page
                    </a>
                </section>
            </main>
            <Footer />
        </div>
    )
}
