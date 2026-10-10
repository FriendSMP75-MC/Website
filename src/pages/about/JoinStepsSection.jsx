import { Download, MessageCircle, Server } from 'lucide-react'

const steps = [
    { number: '1', title: 'Download Minecraft', description: 'Make sure you have Minecraft installed and ready to launch with the correct edition and version.', icon: Download },
    { number: '2', title: 'Copy the server IP', description: 'Copy the official server IP from the homepage or Discord and add it to your Minecraft server list.', icon: Server },
    { number: '3', title: 'Join the community', description: 'Connect to the server, read the rules, and introduce yourself in Discord so the community can welcome you.', icon: MessageCircle },
]

export function JoinStepsSection() {
    return (
        <section className="join-section" aria-labelledby="about-join-title">
            <p className="eyebrow">How to join</p>
            <h2 id="about-join-title">Connect to FriendSMP75 in three simple steps.</h2>
            <div className="steps-grid">
                {steps.map(({ number, title, description, icon: Icon }) => (
                    <article className="step-card" key={number}>
                        <span className="step-number">{number}</span>
                        <h3><Icon size={15} aria-hidden="true" />{title}</h3>
                        <p>{description}</p>
                    </article>
                ))}
            </div>
        </section>
    )
}
