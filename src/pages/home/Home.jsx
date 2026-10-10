import NavBar from '../../components/Navbar';
import { Footer } from '../../components/Footer';
import './home.css';
import { CommunityCta } from './CommunityCta';
import { FeaturesSection } from './FeaturesSection';
import { HeroSection } from './HeroSection';
import { JoinStepsSection } from './JoinStepsSection';
import { ServerStats } from './ServerStats';
import { AboutSection } from './AboutSection';

export default function Home(){
    return (
        <div className="home-page">
            <NavBar/>
            <main className="home-content">
                <HeroSection />
                <ServerStats />
                <AboutSection />
                <FeaturesSection />
                <JoinStepsSection />
                <CommunityCta />
            </main>
            <Footer />
        </div>
    );
}