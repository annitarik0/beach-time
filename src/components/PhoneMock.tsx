"use client";

import { useEffect, useState } from "react";
import {
  ArrowClockwise,
  CaretDown,
  Clock,
  Info,
  MapPin,
  PersonSimpleSwim,
  SlidersHorizontal,
  Sparkle,
  Sun,
  SunHorizon,
  Waves,
} from "@phosphor-icons/react";
import { ScoreRing } from "./ScoreRing";
import { SeaWaves } from "./SeaWaves";
import { activities, ratingWord, scoreColor, type ActivityId } from "@/lib/brand";
import styles from "./PhoneMock.module.css";

const icons = { swim: PersonSimpleSwim, surf: Waves, chill: SunHorizon };

// Sample day for Agadir, worded exactly like the app's verdicts.
const sample: Record<
  ActivityId,
  { score: number; title: string; summary: string; window: string; days: number[] }
> = {
  swim: {
    score: 83,
    title: "A good beach day",
    summary: "Mild 23° air, refreshing 21° water, gentle 0.9 m waves and barely a breeze from the SW.",
    window: "12:00 – 18:00",
    days: [83, 69, 78, 82, 88],
  },
  surf: {
    score: 76,
    title: "A good beach day",
    summary: "Mild 22° air, refreshing 21° water, lively 1.4 m waves and a light breeze from the NE.",
    window: "08:00 – 11:00",
    days: [76, 81, 64, 70, 73],
  },
  chill: {
    score: 91,
    title: "A perfect beach day",
    summary: "Warm 27° air, pleasant 22° water, gentle 0.6 m waves and barely a breeze from the W.",
    window: "11:00 – 17:00",
    days: [91, 86, 72, 80, 94],
  },
};

const dayNames = ["Today", "Fri", "Sat", "Sun", "Mon"];

export function PhoneMock({ play = true, autoCycle = true }: { play?: boolean; autoCycle?: boolean }) {
  const [act, setAct] = useState<ActivityId>("swim");
  const idx = activities.findIndex((a) => a.id === act);
  const d = sample[act];

  useEffect(() => {
    if (!play || !autoCycle) return;
    const t = setInterval(() => {
      setAct((a) => activities[(activities.findIndex((x) => x.id === a) + 1) % activities.length].id);
    }, 3600);
    return () => clearInterval(t);
  }, [play, autoCycle]);

  return (
    <div className={styles.phone} role="img" aria-label="The Beach Time app showing today's beach score for Agadir">
      <div className={styles.island} />
      <div className={styles.screen}>
        <div className={styles.status}>
          <span>10:57</span>
          <span className={styles.statusIcons}>
            <i />
            <i />
            <b />
          </span>
        </div>

        <header className={styles.head}>
          <div>
            <div className="label">Thursday 19 November</div>
            <div className={styles.place}>
              Agadir Beach <CaretDown size={14} weight="bold" color="var(--ink-soft)" />
            </div>
            <div className={styles.sub}>
              <MapPin size={11} weight="fill" color="var(--coral)" /> Souss-Massa, Morocco
            </div>
          </div>
          <div className={styles.roundBtns}>
            <span>
              <ArrowClockwise size={15} />
            </span>
            <span>
              <SlidersHorizontal size={15} />
            </span>
          </div>
        </header>

        <div className={styles.selector}>
          <span className={styles.pill} style={{ transform: `translateX(${idx * 100}%)` }} />
          {activities.map((a) => {
            const Icon = icons[a.id];
            return (
              <button
                key={a.id}
                type="button"
                className={a.id === act ? styles.on : undefined}
                onClick={() => setAct(a.id)}
                tabIndex={-1}
              >
                <Icon size={14} />
                {a.label}
              </button>
            );
          })}
        </div>

        <div className={styles.days}>
          {dayNames.map((n, i) => (
            <div key={n} className={`${styles.day} ${i === 0 ? styles.daySel : ""}`}>
              <span>{n}</span>
              <b>{d.days[i]}</b>
              <i style={{ background: scoreColor(d.days[i]) }} />
            </div>
          ))}
        </div>

        <div className={styles.hero}>
          <div className={styles.sunGlow} />
          <div className={styles.sunDisc} />
          <div className={styles.heroTop}>
            <span className="chip" style={{ fontSize: 9, padding: "4px 9px" }}>
              <span className="dot" style={{ background: scoreColor(d.score), width: 6, height: 6 }} />
              {ratingWord(d.score)}
            </span>
            <span className={styles.temp}>
              <Sun size={13} /> 23°
            </span>
          </div>
          <div className={styles.ring}>
            <ScoreRing score={d.score} play={play} size={138} />
          </div>
          <div key={act} className={styles.verdict}>
            <div className={styles.vTitle}>{d.title}</div>
            <p>{d.summary}</p>
          </div>
          <div className={styles.window}>
            <span className={styles.clock}>
              <Clock size={13} weight="bold" />
            </span>
            <div>
              <small>Best time to {activities[idx].verb}</small>
              <b>{d.window}</b>
            </div>
            <span className="chip" style={{ fontSize: 8, padding: "3px 8px", marginLeft: "auto" }}>
              <span className="dot" style={{ width: 5, height: 5 }} />
              Good
            </span>
          </div>
          <div className={styles.tapHint}>
            <Info size={10} /> Tap to see how the score is made
          </div>
          <SeaWaves height={70} />
        </div>

        <div className={styles.fab}>
          <Sparkle size={14} weight="fill" color="var(--sun)" /> Ask Beach Buddy
        </div>
      </div>
    </div>
  );
}
