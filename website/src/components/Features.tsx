"use client";

import { useEffect, useRef, useState } from "react";
import gsap from "gsap";
import {
  Backpack,
  Check,
  Clock,
  Drop,
  Flag,
  MagnifyingGlass,
  MapPin,
  NavigationArrow,
  Star,
  Sun,
  Waves,
} from "@phosphor-icons/react";
import { scoreColor } from "@/lib/brand";
import styles from "./Features.module.css";

const hours = [
  { h: "07", s: 34 },
  { h: "08", s: 42 },
  { h: "09", s: 51 },
  { h: "10", s: 60 },
  { h: "11", s: 69 },
  { h: "12", s: 78 },
  { h: "13", s: 84 },
  { h: "14", s: 88 },
  { h: "15", s: 86 },
  { h: "16", s: 80 },
  { h: "17", s: 72 },
  { h: "18", s: 61 },
  { h: "19", s: 44 },
];

const week = [
  { d: "Today", lo: 17, hi: 23, s: 83 },
  { d: "Fri", lo: 16, hi: 22, s: 69 },
  { d: "Sat", lo: 17, hi: 25, s: 78 },
  { d: "Sun", lo: 18, hi: 26, s: 82 },
  { d: "Mon", lo: 19, hi: 27, s: 91, best: true },
  { d: "Tue", lo: 17, hi: 23, s: 64 },
  { d: "Wed", lo: 15, hi: 20, s: 48 },
];

const bag = [
  { id: "spf", label: "Sunscreen SPF 30", why: "UV peaks at 6" },
  { id: "water", label: "2 litres of water", why: "23° in the afternoon" },
  { id: "hat", label: "Hat and sunglasses", why: "Clear sky from 12:00" },
  { id: "layer", label: "Light layer", why: "17° after sunset" },
];

export function Features() {
  const root = useRef<HTMLElement>(null);
  const [ticked, setTicked] = useState<Set<string>>(new Set(["spf"]));

  useEffect(() => {
    const el = root.current;
    if (!el) return;
    const q = gsap.utils.selector(el);
    const ctx = gsap.context(() => {
      const st = (trigger: Element) => ({ trigger, start: "top 82%", once: true });
      gsap.fromTo(
        q(`.${styles.bar}`),
        { scaleY: 0 },
        { scaleY: 1, duration: 0.9, ease: "power3.out", stagger: 0.04, scrollTrigger: st(q(`.${styles.bars}`)[0]) },
      );
      gsap.fromTo(
        q(`.${styles.tidePath}`),
        { strokeDashoffset: 1 },
        { strokeDashoffset: 0, duration: 1.6, ease: "power2.inOut", scrollTrigger: st(q(`.${styles.tide}`)[0]) },
      );
      gsap.fromTo(
        q(`.${styles.sunArc}`),
        { strokeDashoffset: 1 },
        { strokeDashoffset: 0.42, duration: 1.6, ease: "power2.inOut", scrollTrigger: st(q(`.${styles.sunSvg}`)[0]) },
      );
      gsap.fromTo(
        q(`.${styles.sunDot}`),
        { rotate: -90 },
        { rotate: 14, duration: 1.6, ease: "power2.inOut", scrollTrigger: st(q(`.${styles.sunSvg}`)[0]) },
      );
      gsap.fromTo(
        q(`.${styles.range}`),
        { scaleX: 0 },
        { scaleX: 1, duration: 0.9, ease: "power3.out", stagger: 0.06, scrollTrigger: st(q(`.${styles.week}`)[0]) },
      );
    }, el);
    return () => ctx.revert();
  }, []);

  const toggle = (id: string) =>
    setTicked((s) => {
      const n = new Set(s);
      if (!n.delete(id)) n.add(id);
      return n;
    });

  return (
    <section ref={root} id="features" className="section" data-bg="#F4EEE4">
      <div className="wrap">
        <div className="section-head" data-reveal>
          <span className="label">What you get</span>
          <h2 className="display">Everything that decides a beach day, on one screen.</h2>
          <p className="lead">
            Live weather, marine and air quality data, turned into plain answers. No charts to decode, no
            jargon. Just when to go and what to bring.
          </p>
        </div>

        <div className={styles.bento} data-reveal="stagger">
          {/* Best time */}
          <article data-tilt="5" className={`card ${styles.cell} ${styles.wide}`}>
            <Head icon={<Clock size={18} weight="bold" />} label="Hour by hour" />
            <h3 className="title">The best window, found for you</h3>
            <p className="muted">
              Every hour gets its own score. Beach Time finds the best three to six hours of daylight and
              puts them at the top.
            </p>
            <div className={styles.bars}>
              {hours.map((x) => {
                const best = x.s >= 78;
                return (
                  <div key={x.h} className={styles.barCol}>
                    <span className={styles.barNum}>{x.s}</span>
                    <div className={styles.barTrack}>
                      <div
                        className={styles.bar}
                        style={{ height: `${x.s}%`, background: scoreColor(x.s), opacity: best ? 1 : 0.55 }}
                      />
                    </div>
                    <span className={styles.barH}>{x.h}</span>
                    <NavigationArrow
                      size={11}
                      weight="fill"
                      color="var(--ink-faint)"
                      style={{ transform: `rotate(${140 + Number(x.h) * 6}deg)` }}
                    />
                  </div>
                );
              })}
              <div className={styles.bestTag}>Best 12:00 – 16:00</div>
            </div>
          </article>

          {/* Sea */}
          <article data-tilt="5" className={`card ${styles.cell}`}>
            <Head icon={<Waves size={18} weight="bold" />} label="Sea" />
            <h3 className="title">Water, waves and tides</h3>
            <div className={styles.stats}>
              <Stat icon={<Drop size={16} />} k="Water" v="21°" />
              <Stat icon={<Waves size={16} />} k="Waves" v="0.9 m · 9 s" />
            </div>
            <svg className={styles.tide} viewBox="0 0 300 90" aria-hidden="true">
              <path d="M0 60 C 40 10, 80 10, 120 45 S 200 95, 240 50 S 290 20, 300 25" className={styles.tideFill} />
              <path
                d="M0 60 C 40 10, 80 10, 120 45 S 200 95, 240 50 S 290 20, 300 25"
                pathLength={1}
                className={styles.tidePath}
              />
              <circle cx="62" cy="23" r="4.5" fill="var(--sea)" />
              <text x="62" y="12" textAnchor="middle" className={styles.tideLabel}>
                High 09:12
              </text>
              <circle cx="180" cy="72" r="4.5" fill="var(--sea-deep)" />
              <text x="180" y="88" textAnchor="middle" className={styles.tideLabel}>
                Low 15:30
              </text>
            </svg>
          </article>

          {/* Sun */}
          <article data-tilt="5" className={`card ${styles.cell}`}>
            <Head icon={<Sun size={18} weight="bold" />} label="Sun & UV" />
            <h3 className="title">Sunscreen advice that means something</h3>
            <svg className={styles.sunSvg} viewBox="0 0 220 120" aria-hidden="true">
              <path d="M20 105 A90 90 0 0 1 200 105" className={styles.sunTrack} />
              <path d="M20 105 A90 90 0 0 1 200 105" pathLength={1} className={styles.sunArc} />
              <g className={styles.sunDot} style={{ transformOrigin: "110px 105px" }}>
                <circle cx="110" cy="15" r="9" fill="var(--sun)" />
                <circle cx="110" cy="15" r="15" fill="var(--sun)" opacity=".25" />
              </g>
              <line x1="8" y1="105" x2="212" y2="105" stroke="var(--line)" strokeWidth="2" />
              <text x="20" y="119" className={styles.sunTime}>
                07:41
              </text>
              <text x="200" y="119" textAnchor="end" className={styles.sunTime}>
                18:24
              </text>
            </svg>
            <p className={styles.uv}>
              <b>UV 6 · High.</b> SPF 30, fair skin burns in about 28 minutes.
            </p>
          </article>

          {/* Safety */}
          <article data-tilt="5" className={`card ${styles.cell}`}>
            <Head icon={<Flag size={18} weight="bold" />} label="Water safety" />
            <h3 className="title">An estimated beach flag</h3>
            <div className={styles.flagRow}>
              <div className={styles.flagPole}>
                <div className={styles.flag} />
              </div>
              <div>
                <div className={styles.flagTitle}>Green flag</div>
                <div className="muted" style={{ fontSize: 15 }}>
                  Calm water, enjoy! Rip current risk is low.
                </div>
              </div>
            </div>
            <p className={styles.note}>Estimated from waves and wind. Always follow lifeguards and local flags.</p>
          </article>

          {/* Bag */}
          <article data-tilt="5" className={`card ${styles.cell}`}>
            <Head icon={<Backpack size={18} weight="bold" />} label="Beach bag" />
            <h3 className="title">A packing list built from the forecast</h3>
            <ul className={styles.bag}>
              {bag.map((b) => {
                const on = ticked.has(b.id);
                return (
                  <li key={b.id}>
                    <button type="button" onClick={() => toggle(b.id)} aria-pressed={on} className={on ? styles.ticked : ""}>
                      <span className={styles.box}>{on && <Check size={12} weight="bold" />}</span>
                      <span>
                        <b>{b.label}</b>
                        <small>{b.why}</small>
                      </span>
                    </button>
                  </li>
                );
              })}
            </ul>
          </article>

          {/* Week */}
          <article data-tilt="5" className={`card ${styles.cell} ${styles.wide}`}>
            <Head icon={<Star size={18} weight="bold" />} label="7-day outlook" />
            <h3 className="title">See the best day of the week at a glance</h3>
            <div className={styles.week}>
              {week.map((w) => (
                <div key={w.d} className={styles.weekRow}>
                  <span className={styles.weekDay}>
                    {w.d}
                    {w.best && <Star size={12} weight="fill" color="var(--sun)" />}
                  </span>
                  <span className={styles.weekLo}>{w.lo}°</span>
                  <span className={styles.rangeTrack}>
                    <span
                      className={styles.range}
                      style={{ left: `${((w.lo - 13) / 16) * 100}%`, right: `${100 - ((w.hi - 13) / 16) * 100}%` }}
                    />
                  </span>
                  <span className={styles.weekHi}>{w.hi}°</span>
                  <span className={styles.weekScore} style={{ background: scoreColor(w.s) }}>
                    {w.s}
                  </span>
                </div>
              ))}
            </div>
          </article>

          {/* Places */}
          <article data-tilt="5" className={`card ${styles.cell} ${styles.full}`}>
            <div className={styles.places}>
              <div>
                <Head icon={<MapPin size={18} weight="bold" />} label="Places" />
                <h3 className="title">Any beach in the world, or right where you are</h3>
                <p className="muted">Search by name, use your location, save favourites.</p>
              </div>
              <div className={styles.search}>
                <MagnifyingGlass size={18} color="var(--ink-soft)" />
                <span>Where to?</span>
              </div>
              <div className={styles.placeChips}>
                {["Agadir", "Taghazout", "Bondi", "Waikiki", "Copacabana", "Navagio", "Maya Bay", "Nice"].map((p) => (
                  <span key={p}>{p}</span>
                ))}
              </div>
            </div>
          </article>
        </div>
      </div>
    </section>
  );
}

function Head({ icon, label }: { icon: React.ReactNode; label: string }) {
  return (
    <div className={styles.head}>
      <span className={styles.icon}>{icon}</span>
      <span className="label">{label}</span>
    </div>
  );
}

function Stat({ icon, k, v }: { icon: React.ReactNode; k: string; v: string }) {
  return (
    <div className={styles.stat}>
      <span className={styles.statK}>
        {icon} {k}
      </span>
      <span className={styles.statV}>{v}</span>
    </div>
  );
}
