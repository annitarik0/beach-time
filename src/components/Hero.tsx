"use client";

import { useEffect, useRef, useState } from "react";
import gsap from "gsap";
import { ArrowDown, ArrowUpRight, Drop, Sun, Waves } from "@phosphor-icons/react";
import { PhoneMock } from "./PhoneMock";
import { onIntroDone } from "./Motion";
import { WEB_APP_URL } from "@/lib/brand";
import styles from "./Hero.module.css";

const headline = ["Know", "the", "perfect", "beach", "day."];
const EDGES = 9;

export function Hero() {
  const root = useRef<HTMLElement>(null);
  const [play, setPlay] = useState(false);

  useEffect(() => {
    const el = root.current;
    if (!el) return;
    const q = gsap.utils.selector(el);
    const rig = q(`.${styles.rig}`)[0];
    const turn = q(`.${styles.turn}`)[0];
    const pops = q(`.${styles.pop}`);

    const ctx = gsap.context(() => {
      gsap.set(q("[data-hero]"), { opacity: 0, y: 24 });
      gsap.set(q(`.${styles.word}`), { yPercent: 110 });
      gsap.set(rig, { autoAlpha: 0, rotationY: -70, rotationX: 24, rotationZ: -10, z: -500, y: 120 });
      gsap.set(pops, { autoAlpha: 0, z: -160 });
    }, el);

    // Pointer: the whole hero steers the phone, not only the phone itself.
    const rx = gsap.quickTo(turn, "rotationX", { duration: 0.9, ease: "power3.out" });
    const ry = gsap.quickTo(turn, "rotationY", { duration: 0.9, ease: "power3.out" });
    const glare = q(`.${styles.glare}`)[0] as HTMLElement | undefined;
    const onMove = (e: PointerEvent) => {
      const r = el.getBoundingClientRect();
      const px = (e.clientX - r.left) / r.width - 0.5;
      const py = (e.clientY - r.top) / r.height - 0.5;
      rx(-py * 16);
      ry(px * 26);
      if (glare) {
        glare.style.setProperty("--gx", `${50 + px * 90}%`);
        glare.style.setProperty("--gy", `${50 + py * 90}%`);
      }
    };
    const onLeave = () => {
      rx(0);
      ry(0);
    };
    const fine = matchMedia("(hover: hover) and (pointer: fine)").matches;
    if (fine) {
      el.addEventListener("pointermove", onMove);
      el.addEventListener("pointerleave", onLeave);
    }

    const off = onIntroDone(() => {
      ctx.add(() => {
        gsap
          .timeline({ defaults: { ease: "power3.out" } })
          .to(q(`.${styles.word}`), { yPercent: 0, duration: 1, stagger: 0.07 })
          .to(q("[data-hero]"), { opacity: 1, y: 0, duration: 0.8, stagger: 0.08 }, 0.35)
          // The phone flies in and swings round to its resting pose.
          .to(
            rig,
            {
              autoAlpha: 1,
              rotationY: -22,
              rotationX: 10,
              rotationZ: 0,
              z: 0,
              y: 0,
              duration: 1.9,
              ease: "expo.out",
              onStart: () => setPlay(true),
            },
            0.15,
          )
          .to(pops, { autoAlpha: 1, z: (i) => [130, 90, 170][i] ?? 100, duration: 1.2, stagger: 0.12, ease: "back.out(1.6)" }, 0.9);

        // Idle: a slow float and sway, like a phone resting on water.
        gsap.to(q(`.${styles.float}`), { y: -16, rotationZ: 1.5, duration: 3.2, ease: "sine.inOut", yoyo: true, repeat: -1 });
        gsap.to(q(`.${styles.float}`), { rotationY: 8, duration: 5.5, ease: "sine.inOut", yoyo: true, repeat: -1 });
        gsap.to(q(`.${styles.shadow}`), { scale: 0.86, opacity: 0.5, duration: 3.2, ease: "sine.inOut", yoyo: true, repeat: -1 });

        // Scroll: the phone turns to face you, then away, as the hero leaves.
        gsap.fromTo(
          q(`.${styles.scroll}`),
          { rotationY: 0, rotationX: 0, y: 0 },
          {
            rotationY: 38,
            rotationX: -8,
            y: -90,
            ease: "none",
            scrollTrigger: { trigger: el, start: "top top", end: "bottom top", scrub: true },
          },
        );
        gsap.to(q(`.${styles.glow}`), {
          scale: 1.25,
          ease: "none",
          scrollTrigger: { trigger: el, start: "top top", end: "bottom top", scrub: true },
        });
      });
    });

    return () => {
      off();
      el.removeEventListener("pointermove", onMove);
      el.removeEventListener("pointerleave", onLeave);
      ctx.revert();
    };
  }, []);

  return (
    <section ref={root} className={styles.hero} data-bg="#F4EEE4">
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

        <div className={styles.stage}>
          <div className={styles.shadow} aria-hidden="true" />
          <div className={styles.rig}>
            <div className={styles.scroll}>
              <div className={styles.turn}>
                <div className={styles.float}>
                  {/* Stacked layers behind the screen give the phone real thickness. */}
                  {Array.from({ length: EDGES }, (_, i) => (
                    <span
                      key={i}
                      className={styles.edge}
                      style={{ transform: `translateZ(${-(i + 1) * 1.7}px)` }}
                      aria-hidden="true"
                    />
                  ))}
                  <div className={styles.front}>
                    <PhoneMock play={play} />
                    <span className={styles.glare} aria-hidden="true" />
                  </div>

                  <div className={`${styles.pop} ${styles.popA}`} aria-hidden="true">
                    <span className={styles.popIcon} style={{ background: "var(--foam)", color: "var(--sea)" }}>
                      <Drop size={18} weight="fill" />
                    </span>
                    <span>
                      <b>21°</b>
                      <small>Water · refreshing</small>
                    </span>
                  </div>
                  <div className={`${styles.pop} ${styles.popB}`} aria-hidden="true">
                    <span className={styles.popIcon} style={{ background: "#FDEBC4", color: "#C98A12" }}>
                      <Sun size={18} weight="fill" />
                    </span>
                    <span>
                      <b>UV 6</b>
                      <small>Shade after 13:00</small>
                    </span>
                  </div>
                  <div className={`${styles.pop} ${styles.popC}`} aria-hidden="true">
                    <span className={styles.popIcon} style={{ background: "#DDEFE6", color: "var(--kelp)" }}>
                      <Waves size={18} weight="bold" />
                    </span>
                    <span>
                      <b>0.9 m</b>
                      <small>Gentle waves</small>
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
