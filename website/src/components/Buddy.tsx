"use client";

import { useEffect, useRef, useState } from "react";
import { PaperPlaneRight, Sparkle } from "@phosphor-icons/react";
import styles from "./Buddy.module.css";

const script = [
  { me: true, text: "Is it OK for kids today?" },
  {
    me: false,
    text: "Yes, it looks calm. Green flag, low rip current risk and gentle 0.6 m waves. The water is about 21°, so keep swims short. Best between 12:00 and 16:00, and reapply SPF 30 every two hours.",
  },
  { me: true, text: "Which day this week is best?" },
  {
    me: false,
    text: "Monday. It scores 91/100 with warm 27° air and almost no wind, best from 11:00 to 17:00.",
  },
];

export function Buddy() {
  const box = useRef<HTMLDivElement>(null);
  const [shown, setShown] = useState(0);
  const [typing, setTyping] = useState(false);
  const started = useRef(false);

  useEffect(() => {
    const el = box.current;
    if (!el) return;
    let timers: ReturnType<typeof setTimeout>[] = [];
    const play = () => {
      setShown(0);
      let t = 400;
      script.forEach((m, i) => {
        if (!m.me) {
          timers.push(setTimeout(() => setTyping(true), t));
          t += 1400;
        }
        timers.push(
          setTimeout(() => {
            setTyping(false);
            setShown(i + 1);
          }, t),
        );
        t += m.me ? 900 : 2200;
      });
      timers.push(setTimeout(play, t + 3500));
    };
    const io = new IntersectionObserver(
      ([e]) => {
        if (e.isIntersecting && !started.current) {
          started.current = true;
          play();
        }
      },
      { threshold: 0.4 },
    );
    io.observe(el);
    return () => {
      io.disconnect();
      timers.forEach(clearTimeout);
      timers = [];
    };
  }, []);

  return (
    <section id="buddy" className="section" data-bg="#F4EEE4">
      <div className={`wrap ${styles.grid}`}>
        <div className={`card ${styles.chat}`} ref={box} data-reveal>
          <div className={styles.top}>
            <span className={styles.avatar}>
              <Sparkle size={18} weight="fill" color="var(--sun)" />
            </span>
            <div>
              <b>Beach Buddy</b>
              <small>Free open-source AI · reading Agadir Beach</small>
            </div>
          </div>
          <div className={styles.msgs}>
            <div className={styles.bubble}>
              Hi, I&apos;m Beach Buddy. I&apos;m reading the live forecast for Agadir Beach. Ask me anything.
            </div>
            {script.slice(0, shown).map((m, i) => (
              <div key={i} className={`${styles.bubble} ${m.me ? styles.me : ""}`}>
                {m.text}
              </div>
            ))}
            {typing && (
              <div className={`${styles.bubble} ${styles.typing}`} aria-label="Beach Buddy is typing">
                <i />
                <i />
                <i />
              </div>
            )}
          </div>
          <div className={styles.input}>
            <span>Ask about the beach...</span>
            <span className={styles.send}>
              <PaperPlaneRight size={16} weight="fill" />
            </span>
          </div>
        </div>

        <div className="section-head" data-reveal style={{ marginBottom: 0 }}>
          <span className="label">Beach Buddy</span>
          <h2 className="display">Ask the beach a question.</h2>
          <p className="lead">
            Beach Buddy is an AI assistant that reads the same live forecast as the app and answers in plain
            words: when to go, whether it is safe for kids, what to bring.
          </p>
          <ul className={styles.points}>
            <li>
              <b>Free and open source.</b> Runs on GPT-OSS, an open-weight model. No account, no API key.
            </li>
            <li>
              <b>Safety first.</b> It never encourages swimming in storms, red-flag surf or strong offshore wind.
            </li>
            <li>
              <b>Always answers.</b> If the AI is busy or you are offline, it replies straight from the forecast.
            </li>
          </ul>
        </div>
      </div>
    </section>
  );
}
