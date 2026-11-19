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
    // The site's motion is part of the brand, so it runs even when the OS
    // asks for reduced motion (Windows does whenever "Show animations" is off).
    let lenis: Lenis | null = null;
    const tick = (t: number) => lenis?.raf(t * 1000);

    {
      lenis = new Lenis({ lerp: 0.1, anchors: { offset: -72 } });
      lenis.on("scroll", ScrollTrigger.update);
      gsap.ticker.add(tick);
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

      // One page background that cross-fades as each section comes in, the
      // way most award-winning sites do it, instead of hard colour edges.
      const secs = gsap.utils.toArray<HTMLElement>("[data-bg]");
      // A single fixed layer is repainted instead of restyling the whole body.
      const layer = document.createElement("div");
      layer.className = "page-bg";
      document.body.prepend(layer);
      if (secs.length) layer.style.backgroundColor = secs[0].dataset.bg!;
      secs.forEach((sec, i) => {
        if (i === 0) return;
        const from = secs[i - 1].dataset.bg!;
        const to = sec.dataset.bg!;
        if (from === to) return;
        gsap.fromTo(
          layer,
          { backgroundColor: from },
          {
            backgroundColor: to,
            ease: "none",
            immediateRender: false,
            scrollTrigger: { trigger: sec, start: "top 90%", end: "top 30%", scrub: true },
          },
        );
      });
    });

    // 3D tilt that follows the pointer on elements marked data-tilt="<max deg>".
    const fine = matchMedia("(hover: hover) and (pointer: fine)").matches;
    const cleanups: (() => void)[] = [];
    if (fine) {
      document.querySelectorAll<HTMLElement>("[data-tilt]").forEach((el) => {
        const max = Number(el.dataset.tilt) || 8;
        const glare = el.querySelector<HTMLElement>("[data-glare]");
        const rx = gsap.quickTo(el, "rotationX", { duration: 0.6, ease: "power3.out" });
        const ry = gsap.quickTo(el, "rotationY", { duration: 0.6, ease: "power3.out" });
        gsap.set(el, { transformPerspective: 1000 });
        const move = (e: PointerEvent) => {
          const r = el.getBoundingClientRect();
          const px = (e.clientX - r.left) / r.width - 0.5;
          const py = (e.clientY - r.top) / r.height - 0.5;
          rx(-py * max);
          ry(px * max);
          if (glare) {
            glare.style.setProperty("--gx", `${(px + 0.5) * 100}%`);
            glare.style.setProperty("--gy", `${(py + 0.5) * 100}%`);
            glare.style.setProperty("--go", "1");
          }
        };
        const leave = () => {
          rx(0);
          ry(0);
          glare?.style.setProperty("--go", "0");
        };
        el.addEventListener("pointermove", move);
        el.addEventListener("pointerleave", leave);
        cleanups.push(() => {
          el.removeEventListener("pointermove", move);
          el.removeEventListener("pointerleave", leave);
        });
      });
    }

    return () => {
      cleanups.forEach((c) => c());
      document.querySelector(".page-bg")?.remove();
      ctx.revert();
      gsap.ticker.remove(tick);
      lenis?.destroy();
    };
  }, []);

  return null;
}
