"use client";

import { useEffect, useRef } from "react";
import gsap from "gsap";
import { hex3, loadThree, makeRenderer, makeSea } from "@/lib/sea3d";
import styles from "./Loader.module.css";

export const INTRO_DONE = "bt:intro-done";

const skyVertex = /* glsl */ `
  varying vec3 vDir;
  void main() {
    vec4 w = modelMatrix * vec4(position, 1.0);
    vDir = w.xyz - cameraPosition;
    gl_Position = projectionMatrix * viewMatrix * w;
  }
`;

// Dawn sky with the sun and its glow drawn analytically, so it is always
// crisp and costs a single draw call.
const skyFragment = /* glsl */ `
  uniform vec3 uZenith;
  uniform vec3 uHorizon;
  uniform vec3 uSunDir;
  uniform vec3 uSunA;
  uniform vec3 uSunB;
  varying vec3 vDir;
  void main() {
    vec3 d = normalize(vDir);
    vec3 col = mix(uHorizon, uZenith, smoothstep(0.0, 0.42, d.y));
    vec3 s = normalize(uSunDir);
    float ang = acos(clamp(dot(d, s), -1.0, 1.0));
    float above = smoothstep(-0.016, 0.004, d.y);
    col += uSunA * exp(-ang * 7.0) * 0.55 * above;
    float disc = 1.0 - smoothstep(0.072, 0.078, ang);
    float t = clamp((d.y - s.y) / 0.15 + 0.5, 0.0, 1.0);
    col = mix(col, mix(uSunB, uSunA, t), disc * above);
    gl_FragColor = vec4(col, 1.0);
  }
`;

/**
 * 3D intro: the sun rises over a WebGL sea while the camera lifts off the
 * water and the score counts to 100, then three tide layers wash the screen
 * away. Plays once per browser session.
 */
export function Loader() {
  const root = useRef<HTMLDivElement>(null);
  const canvasHost = useRef<HTMLDivElement>(null);
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
    let tl: gsap.core.Timeline | null = null;
    let stop3d = () => {};
    let killed = false;

    // The 3D scene state the timeline drives.
    const s = { sun: -0.09, camY: 0.55, lookY: 0.9, n: 0 };

    const start3d = async () => {
      const host = canvasHost.current;
      if (!host) return false;
      try {
        const T = await loadThree();
        if (killed) return false;
        const renderer = makeRenderer(T);
        host.appendChild(renderer.domElement);
        const scene = new T.Scene();
        const camera = new T.PerspectiveCamera(48, 1, 0.1, 400);

        const sunDir = new T.Vector3(0, s.sun, -1);
        const horizon = hex3(T, "#F9D7B0");
        const sky = new T.Mesh(
          new T.SphereGeometry(200, 32, 16),
          new T.ShaderMaterial({
            vertexShader: skyVertex,
            fragmentShader: skyFragment,
            side: T.BackSide,
            depthWrite: false,
            uniforms: {
              uZenith: { value: hex3(T, "#F4EEE4") },
              uHorizon: { value: horizon },
              uSunDir: { value: sunDir },
              uSunA: { value: hex3(T, "#F8C55A") },
              uSunB: { value: hex3(T, "#EE7F45") },
            },
          }),
        );
        scene.add(sky);

        const sea = makeSea(T, { deep: "#0B4F5C", shallow: "#168493", sky: "#F9D7B0", sun: "#FFD68A" }, 120);
        sea.uniforms.uSky.value = horizon;
        sea.uniforms.uSunDir.value = sunDir;
        sea.uniforms.uHaze.value = 1;
        sea.uniforms.uHazeNear.value = 6;
        sea.uniforms.uHazeFar.value = 74;
        sea.uniforms.uFadeNear.value = 500;
        sea.uniforms.uFadeFar.value = 600;
        sea.uniforms.uAmp.value = 0.8;
        scene.add(sea.mesh);

        const size = () => {
          const w = window.innerWidth;
          const h = window.innerHeight;
          renderer.setSize(w, h, false);
          camera.aspect = w / h;
          camera.fov = w < h ? 62 : 48;
          camera.updateProjectionMatrix();
        };
        size();
        window.addEventListener("resize", size);

        const t0 = performance.now();
        const look = new T.Vector3();
        const tick = () => {
          sea.uniforms.uTime.value = (performance.now() - t0) / 1000;
          sunDir.set(0.0, s.sun, -1);
          camera.position.set(0, s.camY, 7);
          look.set(0, s.lookY, -40);
          camera.lookAt(look);
          renderer.render(scene, camera);
        };
        gsap.ticker.add(tick);
        tick();

        stop3d = () => {
          gsap.ticker.remove(tick);
          window.removeEventListener("resize", size);
          sea.dispose();
          sky.geometry.dispose();
          (sky.material as InstanceType<typeof T.ShaderMaterial>).dispose();
          renderer.dispose();
          renderer.domElement.remove();
        };
        return true;
      } catch {
        return false;
      }
    };

    const play = (has3d: boolean) => {
      if (killed) return;
      tl = gsap.timeline({ defaults: { ease: "power3.out" } });
      tl.set(el, { autoAlpha: 1 })
        .fromTo(q(`.${styles.canvas}`), { autoAlpha: 0 }, { autoAlpha: has3d ? 1 : 0, duration: 0.8, ease: "power1.out" }, 0)
        // Sunrise and the camera lifting off the water.
        .to(s, { sun: 0.11, duration: 2.8, ease: "power2.out" }, 0)
        .to(s, { camY: 2.1, lookY: 1.7, duration: 2.9, ease: "power2.inOut" }, 0)
        .to(
          s,
          {
            n: 100,
            duration: 2.4,
            ease: "power2.inOut",
            onUpdate: () => {
              if (count.current) count.current.textContent = String(Math.round(s.n)).padStart(2, "0");
            },
          },
          0.2,
        )
        .fromTo(q(`.${styles.char}`), { yPercent: 110 }, { yPercent: 0, duration: 0.9, stagger: 0.035 }, 0.7)
        .fromTo(q(`.${styles.caption}`), { autoAlpha: 0, y: 8 }, { autoAlpha: 1, y: 0, duration: 0.6 }, 0.9)
        // Hold until the fonts are in, so the page underneath is final.
        .add(() => {
          tl!.pause();
          document.fonts.ready.then(() => tl!.resume());
        }, 2.7)
        // Tide comes in...
        .to(q(`.${styles.tide}`), { yPercent: -100, duration: 0.9, stagger: 0.09, ease: "power4.inOut" }, 2.75)
        .add(() => stop3d())
        .set(q(`.${styles.stage}`), { autoAlpha: 0 })
        .set(el, { backgroundColor: "transparent" })
        .add(done)
        // ...and goes out, revealing the page.
        .to(q(`.${styles.tide}`), {
          yPercent: -220,
          duration: 1,
          stagger: { each: 0.08, from: "end" },
          ease: "power3.inOut",
        })
        .set(el, { autoAlpha: 0, display: "none" })
        .add(() => {
          try {
            sessionStorage.setItem("bt-intro", "1");
          } catch {}
        });
    };

    gsap.set(el, { autoAlpha: 1 });
    gsap.set(q(`.${styles.char}`), { yPercent: 110 });
    // Give three.js up to 1.6 s to arrive; otherwise run the intro without 3D.
    let started = false;
    const go = (ok: boolean) => {
      if (started) return;
      started = true;
      play(ok);
    };
    const fallback = setTimeout(() => go(false), 1600);
    start3d().then((ok) => {
      clearTimeout(fallback);
      if (ok) go(true);
      else go(false);
    });

    return () => {
      killed = true;
      clearTimeout(fallback);
      tl?.kill();
      stop3d();
      document.body.classList.remove("is-loading");
    };
  }, []);

  const word = "Beach Time".split("");

  return (
    <div ref={root} className={styles.loader} aria-hidden="true">
      <div className={styles.stage}>
        <div ref={canvasHost} className={styles.canvas} />
        <div className={styles.copy}>
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
      </div>

      <div className={`${styles.tide} ${styles.t1}`} />
      <div className={`${styles.tide} ${styles.t2}`} />
      <div className={`${styles.tide} ${styles.t3}`} />
    </div>
  );
}
