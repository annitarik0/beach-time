"use client";

import { useEffect, useRef, useState } from "react";
import gsap from "gsap";
import { ArrowDown, ArrowUpRight } from "@phosphor-icons/react";
import { PhoneMock } from "./PhoneMock";
import { onIntroDone } from "./Motion";
import { WEB_APP_URL } from "@/lib/brand";
import styles from "./Hero.module.css";

const headline = ["Know", "the", "perfect", "beach", "day."];

export function Hero() {
  const root = useRef<HTMLElement>(null);
  const [play, setPlay] = useState(false);

  useEffect(() => {
    const el = root.current;
    if (!el) return;
    const q = gsap.utils.selector(el);
    const ctx = gsap.context(() => {
      gsap.set(q("[data-hero]"), { opacity: 0, y: 24 });
      gsap.set(q(`.${styles.word}`), { yPercent: 110 });
      gsap.set(q(`.${styles.phoneWrap}`), { opacity: 0, y: 80, rotate: 4 });
    }, el);

    const off = onIntroDone(() => {
      ctx.add(() => {
        gsap
          .timeline({ defaults: { ease: "power3.out" } })
          .to(q(`.${styles.word}`), { yPercent: 0, duration: 1, stagger: 0.07 })
          .to(q("[data-hero]"), { opacity: 1, y: 0, duration: 0.8, stagger: 0.08 }, 0.35)
          .to(
            q(`.${styles.phoneWrap}`),
            { opacity: 1, y: 0, rotate: -3, duration: 1.3, ease: "expo.out", onStart: () => setPlay(true) },
            0.2,
          );
        // Gentle parallax on scroll.
        gsap.to(q(`.${styles.phoneWrap}`), {
          y: -60,
          rotate: 0,
          ease: "none",
          scrollTrigger: { trigger: el, start: "top top", end: "bottom top", scrub: true },
        });
        gsap.to(q(`.${styles.glow}`), {
          scale: 1.25,
          ease: "none",
          scrollTrigger: { trigger: el, start: "top top", end: "bottom top", scrub: true },
        });
      });
    });
    return () => {
      off();
      ctx.revert();
    };
  }, []);

  return (
    <section ref={root} className={styles.hero}>
      <div className={styles.glow} aria-hidden="true" />
      <div className={`wrap ${styles.grid}`}>
        <div className={styles.copy}>
          <span className="label" data-hero>
            Swim · Surf · Chill
          </span>
          <h1 className={`display ${styles.h1}`}>
            {headline.map((w, i) => (
              <span key={i} className={styles.mask}>
                <span className={styles.word}>{w}</span>
              </span>
            ))}
          </h1>
          <p className="lead" data-hero>
            Beach Time scores every hour from 0 to 100 for swimming, surfing or lying in the sun, then
            tells you the best time to go. Water, waves, tides, UV and safety in one calm screen.
          </p>
          <div className={styles.ctas} data-hero>
            <a className="btn btn-ink" href={WEB_APP_URL}>
              Open the web app <ArrowUpRight size={17} weight="bold" />
            </a>
            <a className="btn btn-ghost" href="#features">
              See what it does <ArrowDown size={17} weight="bold" />
            </a>
          </div>
          <ul className={styles.facts} data-hero>
            <li>Free</li>
            <li>No account</li>
            <li>Any beach in the world</li>
          </ul>
        </div>
        <div className={styles.phoneWrap}>
          <PhoneMock play={play} />
        </div>
      </div>
    </section>
  );
}
