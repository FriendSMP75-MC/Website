import NavBar from '../../components/Navbar';
import { Footer } from '../../components/Footer';
import './home.css';
import { HeroSection } from './HeroSection';
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
            </main>
            <Footer />
        </div>
    );
}