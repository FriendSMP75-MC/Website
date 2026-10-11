import {
    CircleCheck,
    ExternalLink,
    Globe,
    Info,
    ListChecks,
    Rocket,
    TrendingUp,
} from 'lucide-react'
import NavBar from '../../components/Navbar'
import { Footer } from '../../components/Footer'
import './vote.css'

const voteSites = [
    {
        name: 'Xyrios',
        host: 'xyrios.com',
        url: 'https://xyrios.com/minecraft/servers/355',
        icon: CircleCheck,
    },
    {
        name: 'PlanetMinecraft',
        host: 'www.planetminecraft.com',
        url: 'https://www.planetminecraft.com/server/friendsmp75/vote/',
        icon: Rocket,
    },
    {
        name: 'Minecraft List',
        host: 'minecraftlist.org',
        url: 'https://minecraftlist.org/vote/34029',
        icon: ListChecks,
    },
    {
        name: 'MC Rank',
        host: 'mcrank.com',
        url: 'https://mcrank.com/server/friendsmp75',
        icon: TrendingUp,
    },
    {
        name: 'Minecraft IP List',
        host: 'www.minecraftiplist.com',
        url: 'https://www.minecraftiplist.com/server/FriendSMP75-39197',
        icon: Globe,
    },
]

function VoteCard({ name, host, url, icon: Icon }) {
    return (
        <a className="vote-card" href={url} target="_blank" rel="noopener noreferrer">
            <span className="vote-card-icon" aria-hidden="true">
                <Icon size={17} />
            </span>
            <div className="vote-card-body">
                <h3>{name}</h3>
                <p>
                    You will be redirected to <strong>{host}</strong>
                </p>
            </div>
            <ExternalLink className="vote-card-open" size={16} aria-hidden="true" />
        </a>
    )
}

export default function Vote() {
    return (
        <div className="vote-page">
            <NavBar />
            <main className="vote-content">
                <header className="vote-intro">
                    <p className="eyebrow">Support us</p>
                    <h1>Vote For FriendSMP75</h1>
                    <p>Every vote helps more players discover the server and keeps the community growing.</p>
                </header>

                <aside className="vote-notice" role="note">
                    <Info size={18} aria-hidden="true" />
                    <div>
                        <strong>Please note</strong>
                        <p>
                            Voting helps the server by boosting its visibility and bringing in new players, but you
                            will not receive any rewards in game for voting.
                        </p>
                    </div>
                </aside>

                <section className="vote-group" aria-labelledby="vote-sites-title">
                    <p className="eyebrow">Voting sites</p>
                    <h2 id="vote-sites-title">Where you can vote.</h2>
                    <p className="vote-group-description">
                        Each card opens the voting page in a new tab and shows the website you will be redirected to.
                    </p>
                    <div className="vote-grid">
                        {voteSites.map((site) => (
                            <VoteCard key={site.name} {...site} />
                        ))}
                    </div>
                </section>
            </main>
            <Footer />
        </div>
    )
}
