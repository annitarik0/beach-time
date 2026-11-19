"use client";

import { useEffect, useRef } from "react";
import gsap from "gsap";
import styles from "./Loader.module.css";

export const INTRO_DONE = "bt:intro-done";

/**
 * Intro: waves draw in, the sun rises while the score counts to 100, the
 * wordmark lands, then three tide layers sweep up and wash the screen away.
 * Plays once per session; skipped for reduced motion.
 */
export function Loader() {
  const root = useRef<HTMLDivElement>(null);
  const count = useRef<HTMLSpanElement>(null);

  useEffect(() => {
    const el = root.current;
    const html = document.documentElement;
    const done = () => {
      (window as unknown as { __btIntroDone?: boolean }).__btIntroDone = true;
      window.dispatchEvent(new Event(INTRO_DONE));
      document.body.classList.remove("is-loading");
    };

    if (!el || html.classList.contains("intro-seen")) {
      done();
      return;
    }

    document.body.classList.add("is-loading");
    const q = gsap.utils.selector(el);
    const state = { n: 0 };

    const tl = gsap.timeline({ defaults: { ease: "power3.out" } });
    tl.set(el, { autoAlpha: 1 })
      .fromTo(q(`.${styles.waveLine}`), { strokeDashoffset: 1 }, { strokeDashoffset: 0, duration: 1, stagger: 0.12, ease: "power2.inOut" })
      .fromTo(q(`.${styles.sunDisc}`), { y: 70 }, { y: 0, duration: 1.3, ease: "expo.out" }, 0.25)
      .fromTo(q(`.${styles.glow}`), { scale: 0.4, autoAlpha: 0 }, { scale: 1, autoAlpha: 1, duration: 1.4 }, 0.5)
      .to(
        state,
        {
          n: 100,
          duration: 1.5,
          ease: "power2.inOut",
          onUpdate: () => {
            if (count.current) count.current.textContent = String(Math.round(state.n)).padStart(2, "0");
          },
        },
        0.2,
      )
      .fromTo(q(`.${styles.char}`), { yPercent: 110 }, { yPercent: 0, duration: 0.8, stagger: 0.035 }, 0.55)
      .fromTo(q(`.${styles.caption}`), { autoAlpha: 0, y: 8 }, { autoAlpha: 1, y: 0, duration: 0.6 }, 0.8)
      // Hold until the fonts are in, so the page underneath is final.
      .add(() => {
        tl.pause();
        document.fonts.ready.then(() => tl.resume());
      }, 1.8)
      // Tide comes in...
      .to(q(`.${styles.tide}`), { yPercent: -100, duration: 0.9, stagger: 0.09, ease: "power4.inOut" }, 1.85)
      .set(q(`.${styles.stage}`), { autoAlpha: 0 })
      .set(el, { backgroundColor: "transparent" })
      .add(done)
      // ...and goes out, revealing the page.
      .to(q(`.${styles.tide}`), { yPercent: -220, duration: 1, stagger: { each: 0.08, from: "end" }, ease: "power3.inOut" })
      .set(el, { autoAlpha: 0, display: "none" })
      .add(() => {
        try {
          sessionStorage.setItem("bt-intro", "1");
        } catch {}
      });

    return () => {
      tl.kill();
      document.body.classList.remove("is-loading");
    };
  }, []);

  const word = "Beach Time".split("");

  return (
    <div ref={root} className={styles.loader} aria-hidden="true">
      <div className={styles.stage}>
        <svg className={styles.art} viewBox="0 0 240 170">
          <defs>
            <linearGradient id="ld-sun" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0" stopColor="#F6C24E" />
              <stop offset="1" stopColor="#EE7F45" />
            </linearGradient>
            <radialGradient id="ld-glow">
              <stop offset="0" stopColor="#F6C24E" stopOpacity=".45" />
              <stop offset="1" stopColor="#F6C24E" stopOpacity="0" />
            </radialGradient>
            <clipPath id="ld-above">
              <rect width="240" height="104" />
            </clipPath>
          </defs>
          <circle className={styles.glow} cx="120" cy="100" r="95" fill="url(#ld-glow)" />
          <g clipPath="url(#ld-above)">
            <circle className={styles.sunDisc} cx="120" cy="100" r="52" fill="url(#ld-sun)" />
          </g>
          <path
            className={styles.waveLine}
            pathLength={1}
            d="M10 104 q27.5 -14 55 0 t55 0 t55 0 t55 0"
            stroke="var(--sea)"
          />
          <path
            className={styles.waveLine}
            pathLength={1}
            d="M30 128 q22.5 -11 45 0 t45 0 t45 0 t45 0"
            stroke="var(--sea-deep)"
            opacity=".5"
          />
        </svg>

        <div className={styles.word} aria-label="Beach Time">
          {word.map((ch, i) => (
            <span key={i} className={styles.charMask}>
              <span className={styles.char}>{ch === " " ? " " : ch}</span>
            </span>
          ))}
        </div>

        <div className={styles.caption}>
          <span className="label">Reading the ocean</span>
          <span className={styles.count}>
            <span ref={count}>00</span>
          </span>
        </div>
      </div>

      <div className={`${styles.tide} ${styles.t1}`} />
      <div className={`${styles.tide} ${styles.t2}`} />
      <div className={`${styles.tide} ${styles.t3}`} />
    </div>
  );
}
