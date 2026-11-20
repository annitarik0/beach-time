"use client";

import { useEffect, useRef } from "react";
import gsap from "gsap";
import { scoreColor } from "@/lib/brand";

/**
 * The app's 270° score gauge (lib/widgets/score_ring.dart): white track,
 * ticks, a knob in the rating colour and a number that counts up.
 */
export function ScoreRing({
  score,
  play = true,
  size = 190,
  dark = true,
}: {
  score: number;
  play?: boolean;
  size?: number;
  dark?: boolean;
}) {
  const arc = useRef<SVGCircleElement>(null);
  const knob = useRef<SVGGElement>(null);
  const num = useRef<HTMLSpanElement>(null);
  const last = useRef(0);

  const r = 76;
  const c = 2 * Math.PI * r;
  const sweep = 0.75; // 270°
  const fg = dark ? "#fff" : "var(--ink)";

  useEffect(() => {
    if (!play) return;
    const state = { v: last.current };
    const tween = gsap.to(state, {
      v: score,
      duration: 1.4,
      ease: "power3.out",
      onUpdate: () => {
        const v = state.v;
        arc.current?.setAttribute("stroke-dashoffset", String(c * sweep * (1 - v / 100)));
        if (knob.current) knob.current.style.transform = `rotate(${135 + 270 * (v / 100)}deg)`;
        if (num.current) num.current.textContent = String(Math.round(v));
      },
    });
    last.current = score;
    return () => {
      tween.kill();
    };
  }, [score, play, c]);

  const ticks = Array.from({ length: 11 }, (_, i) => 135 + i * 27);

  return (
    <div style={{ position: "relative", width: size, height: size }}>
      <svg viewBox="0 0 200 200" width={size} height={size} aria-hidden="true">
        <g transform="rotate(135 100 100)">
          <circle
            cx="100"
            cy="100"
            r={r}
            fill="none"
            stroke={dark ? "rgb(255 255 255 / 28%)" : "var(--sunk)"}
            strokeWidth="12"
            strokeLinecap="round"
            strokeDasharray={`${c * sweep} ${c}`}
          />
          <circle
            ref={arc}
            cx="100"
            cy="100"
            r={r}
            fill="none"
            stroke={fg}
            strokeWidth="12"
            strokeLinecap="round"
            strokeDasharray={`${c * sweep} ${c}`}
            strokeDashoffset={c * sweep}
          />
        </g>
        {ticks.map((a) => {
          const rad = (a * Math.PI) / 180;
          const x1 = 100 + Math.cos(rad) * 58;
          const y1 = 100 + Math.sin(rad) * 58;
          const x2 = 100 + Math.cos(rad) * 63;
          const y2 = 100 + Math.sin(rad) * 63;
          return (
            <line
              key={a}
              x1={x1}
              y1={y1}
              x2={x2}
              y2={y2}
              stroke={dark ? "rgb(255 255 255 / 45%)" : "var(--line)"}
              strokeWidth="1.6"
              strokeLinecap="round"
            />
          );
        })}
        <g ref={knob} style={{ transformOrigin: "100px 100px", transform: "rotate(135deg)" }}>
          <circle cx="176" cy="100" r="9" fill="#fff" />
          <circle cx="176" cy="100" r="5.5" fill={scoreColor(score)} />
        </g>
      </svg>
      <div
        style={{
          position: "absolute",
          inset: 0,
          display: "grid",
          placeItems: "center",
          alignContent: "center",
          color: fg,
        }}
      >
        <span
          ref={num}
          className="display"
          style={{ fontSize: size * 0.31, letterSpacing: "-0.04em", lineHeight: 0.9 }}
        >
          0
        </span>
        <span style={{ fontSize: Math.max(11, size * 0.07), opacity: 0.8, marginTop: 6 }}>out of 100</span>
      </div>
    </div>
  );
}
