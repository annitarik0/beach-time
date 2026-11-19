import type { Metadata } from "next";
import { Header } from "@/components/Header";
import { Footer } from "@/components/Footer";
import styles from "../brand/brand.module.css";

export const metadata: Metadata = {
  title: "Privacy",
  description: "What Beach Time does with your data. Short version: almost nothing.",
};

const items = [
  {
    t: "No account, no tracking",
    p: "Beach Time has no sign-up, no ads, no analytics and no cookies. This website does not track you either.",
  },
  {
    t: "What stays on your device",
    p: "Your saved beaches, chosen activity, beach bag checklist and settings are stored on your phone or in your browser. They never leave it.",
  },
  {
    t: "Forecasts",
    p: "To get a forecast the app sends the beach's coordinates to Open-Meteo. If you use “near me”, your location is used only for that request and is not stored.",
  },
  {
    t: "Beach Buddy",
    p: "When you ask Beach Buddy a question, your question and the forecast for the selected beach are sent to the AI service you have set (by default the free Pollinations service running GPT-OSS). Don't type personal details into the chat.",
  },
  {
    t: "Your own AI key",
    p: "If you add your own AI provider and key in Settings, it is stored only on your device and sent only to that provider.",
  },
];

export default function PrivacyPage() {
  return (
    <>
      <Header />
      <main className={styles.page}>
        <section className="wrap">
          <div className={styles.intro}>
            <span className="label">Privacy</span>
            <h1 className="display">Your beach days are your business.</h1>
            <p className="lead">The short version: Beach Time collects nothing about you.</p>
          </div>
          {items.map((i) => (
            <div key={i.t} className={styles.block}>
              <div className={styles.blockHead}>
                <h2 className="title">{i.t}</h2>
              </div>
              <p className="lead">{i.p}</p>
            </div>
          ))}
        </section>
      </main>
      <Footer />
    </>
  );
}
