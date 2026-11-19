import { Loader } from "@/components/Loader";
import { Motion } from "@/components/Motion";
import { Header } from "@/components/Header";
import { Hero } from "@/components/Hero";
import { Features } from "@/components/Features";
import { ScoreExplainer } from "@/components/ScoreExplainer";
import { Buddy } from "@/components/Buddy";
import { GetApp } from "@/components/GetApp";
import { Faq } from "@/components/Faq";
import { Footer } from "@/components/Footer";

export default function Home() {
  return (
    <>
      <Loader />
      <Motion />
      <Header />
      <main>
        <Hero />
        <Features />
        <ScoreExplainer />
        <Buddy />
        <Faq />
        <GetApp />
      </main>
      <Footer />
    </>
  );
}
