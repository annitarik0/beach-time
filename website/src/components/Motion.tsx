"use client";

import { useEffect } from "react";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import Lenis from "lenis";
import { INTRO_DONE } from "./Loader";

gsap.registerPlugin(ScrollTrigger);

/** Resolves when the intro loader has finished (or was skipped). */
export function onIntroDone(cb: () => void) {
  if ((window as unknown as { __btIntroDone?: boolean }).__btIntroDone) {
    cb();
    return () => {};
  }
  window.addEventListener(INTRO_DONE, cb, { once: true });
  return () => window.removeEventListener(INTRO_DONE, cb);
}

/**
 * Smooth scrolling (Lenis) synced with GSAP ScrollTrigger, plus scroll
 * reveals for every element marked data-reveal (optionally data-reveal="stagger"
 * to animate its children one after another).
 */
export function Motion() {
  useEffect(() => {
    const reduce = matchMedia("(prefers-reduced-motion: reduce)").matches;
    let lenis: Lenis | null = null;
    const tick = (t: number) => lenis?.raf(t * 1000);

    if (!reduce) {
      lenis = new Lenis({ lerp: 0.1, anchors: { offset: -72 } });
      lenis.on("scroll", ScrollTrigger.update);
      gsap.ticker.add(tick);
      gsap.ticker.lagSmoothing(0);
    }

    const ctx = gsap.context(() => {
      gsap.utils.toArray<HTMLElement>("[data-reveal]").forEach((el) => {
        const stagger = el.dataset.reveal === "stagger";
        const targets = stagger ? Array.from(el.children) : [el];
        if (stagger) gsap.set(el, { opacity: 1 });
        gsap.fromTo(
          targets,
          { opacity: 0, y: 36 },
          {
            opacity: 1,
            y: 0,
            duration: 0.9,
            ease: "power3.out",
            stagger: stagger ? 0.08 : 0,
            scrollTrigger: { trigger: el, start: "top 86%", once: true },
          },
        );
      });
    });

    return () => {
      ctx.revert();
      gsap.ticker.remove(tick);
      lenis?.destroy();
    };
  }, []);

  return null;
}
