import { MessageCircle, UsersRound } from 'lucide-react'

export function CommunityCta() {
    return (
        <section className="community-cta page-section" aria-labelledby="about-community-title">
            <div>
                <p className="eyebrow">Join the community</p>
                <h2 id="about-community-title">Connect with the community before your first session.</h2>
                <div className="cta-tags">
                    <span><MessageCircle size={12} aria-hidden="true" />Official Discord</span>
                    <span><UsersRound size={12} aria-hidden="true" />Community-first culture</span>
                </div>
            </div>
            <p className="community-cta-copy">Discord is the best place to meet players, share builds, ask questions, and stay updated on events, updates, and server activity.</p>
        </section>
    )
}
