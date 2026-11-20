"use client";

import { useEffect, useRef, useState } from "react";
import gsap from "gsap";
import { PersonSimpleSwim, SunHorizon, Waves } from "@phosphor-icons/react";
import { activities, ratings, weights, type ActivityId } from "@/lib/brand";
import styles from "./ScoreExplainer.module.css";

const icons = { swim: PersonSimpleSwim, surf: Waves, chill: SunHorizon };

export function ScoreExplainer() {
  const [act, setAct] = useState<ActivityId>("swim");
  const bars = useRef<HTMLDivElement>(null);
  const seen = useRef(false);

  useEffect(() => {
    const el = bars.current;
    if (!el) return;
    const fills = el.querySelectorAll<HTMLElement>("[data-w]");
    const run = () =>
      gsap.to(fills, {
        width: (_i: number, t: HTMLElement) => `${(Number(t.dataset.w) / 40) * 100}%`,
        duration: 0.8,
        ease: "power3.out",
        stagger: 0.05,
      });
    if (seen.current) {
      run();
      return;
    }
    const io = new IntersectionObserver(
      ([e]) => {
        if (e.isIntersecting) {
          seen.current = true;
          run();
          io.disconnect();
        }
      },
      { threshold: 0.3 },
    );
    io.observe(el);
    return () => io.disconnect();
  }, [act]);

  const idx = activities.findIndex((a) => a.id === act);

  return (
    <section id="score" className={`section ${styles.section}`} data-bg="#FFFCF7">
      <div className={`wrap ${styles.grid}`}>
        <div className="section-head" data-reveal style={{ marginBottom: 0 }}>
          <span className="label">The Beach Score</span>
          <h2 className="display">One number. Weighted for what you came to do.</h2>
          <p className="lead">
            A swimmer cares about water temperature. A surfer cares about waves and wind. Someone with a book
            cares about sunshine and no rain. Beach Time weighs the same forecast differently for each.
          </p>
          <ul className={styles.scale}>
            {ratings.map((r) => (
              <li key={r.word}>
                <i style={{ background: r.color }} />
                <b>{r.word}</b>
                <span>{r.min === 0 ? "below 40" : `${r.min}+`}</span>
              </li>
            ))}
          </ul>
        </div>

        <div className={`card ${styles.panel}`} data-reveal>
          <div className={styles.selector} role="tablist" aria-label="Activity">
            <span className={styles.pill} style={{ transform: `translateX(${idx * 100}%)` }} />
            {activities.map((a) => {
              const Icon = icons[a.id];
              return (
                <button
                  key={a.id}
                  role="tab"
                  aria-selected={a.id === act}
                  className={a.id === act ? styles.on : undefined}
                  onClick={() => setAct(a.id)}
                >
                  <Icon size={18} />
                  {a.label}
                </button>
              );
            })}
          </div>

          <div ref={bars} className={styles.bars}>
            {weights[act].map((f) => (
              <div key={f.factor} className={styles.row}>
                <span className={styles.factor}>{f.factor}</span>
                <span className={styles.track}>
                  <span className={styles.fill} data-w={f.weight} />
                </span>
                <span className={styles.pct}>{f.weight}%</span>
              </div>
            ))}
          </div>

          <p className={styles.penalty}>
            Then the safety rules: a thunderstorm caps the score at 5, strong gusts and heavy rain cut it, and
            night hours barely count.
          </p>
        </div>
      </div>
    </section>
  );
}
