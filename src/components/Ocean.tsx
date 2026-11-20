"use client";

import { useEffect, useRef, useState } from "react";
import { loadThree, makeRenderer, makeSea } from "@/lib/sea3d";
import { SeaWaves } from "./SeaWaves";
import styles from "./Ocean.module.css";

/** A real-time 3D sea under the "Get the app" sky, ending in a shoreline. */
export function Ocean() {
  const host = useRef<HTMLDivElement>(null);
  const [failed, setFailed] = useState(false);

  useEffect(() => {
    const el = host.current;
    if (!el) return;
    let cleanup = () => {};
    let cancelled = false;

    // Only download three.js and start WebGL when the section is close.
    const near = new IntersectionObserver(
      async ([entry]) => {
        if (!entry.isIntersecting) return;
        near.disconnect();
        let T: Awaited<ReturnType<typeof loadThree>>;
        try {
          T = await loadThree();
        } catch {
          setFailed(true);
          return;
        }
        if (cancelled) return;
        let renderer: InstanceType<typeof T.WebGLRenderer>;
        try {
          renderer = makeRenderer(T);
        } catch {
          setFailed(true);
          return;
        }
        el.appendChild(renderer.domElement);
        renderer.domElement.style.opacity = "0";
        renderer.domElement.style.transition = "opacity 1.2s ease";

        const scene = new T.Scene();
        const camera = new T.PerspectiveCamera(42, 1, 0.1, 200);
        const look = new T.Vector3(0, 0.4, -12);
        const sea = makeSea(T, { deep: "#0B4F5C", shallow: "#2A97A3", sky: "#9CD1D3", sun: "#FFE2A1" }, 140);
        scene.add(sea.mesh);

        const size = () => {
          const w = el.clientWidth;
          const h = el.clientHeight;
          renderer.setSize(w, h, false);
          camera.aspect = w / h;
          camera.fov = w < 700 ? 58 : 42;
          camera.updateProjectionMatrix();
        };
        size();
        const ro = new ResizeObserver(size);
        ro.observe(el);

        const pointer = { x: 0, tx: 0 };
        const onMove = (e: PointerEvent) => {
          pointer.tx = (e.clientX / window.innerWidth - 0.5) * 2;
        };
        window.addEventListener("pointermove", onMove, { passive: true });

        let visible = true;
        let raf = 0;
        const start = performance.now();
        const frame = () => {
          raf = 0;
          sea.uniforms.uTime.value = ((performance.now() - start) / 1000) * 0.75;
          pointer.x += (pointer.tx - pointer.x) * 0.05;
          const r = el.getBoundingClientRect();
          const p = Math.min(Math.max(1 - r.top / window.innerHeight, 0), 1.4);
          camera.position.set(pointer.x * 1.4, 3.3 - p * 0.9, 6);
          look.x = pointer.x * 0.6;
          camera.lookAt(look);
          renderer.render(scene, camera);
          if (visible && !document.hidden) raf = requestAnimationFrame(frame);
        };
        const io = new IntersectionObserver(([e]) => {
          visible = e.isIntersecting;
          if (visible && !raf) raf = requestAnimationFrame(frame);
        });
        io.observe(el);
        frame();
        requestAnimationFrame(() => (renderer.domElement.style.opacity = "1"));

        cleanup = () => {
          cancelAnimationFrame(raf);
          io.disconnect();
          ro.disconnect();
          window.removeEventListener("pointermove", onMove);
          sea.dispose();
          renderer.dispose();
          renderer.domElement.remove();
        };
      },
      { rootMargin: "900px 0px" },
    );
    near.observe(el);

    return () => {
      cancelled = true;
      near.disconnect();
      cleanup();
    };
  }, []);

  return (
    <div className={styles.ocean} aria-hidden="true">
      <div ref={host} className={styles.canvas} />
      {failed && <SeaWaves height={140} />}
      <div className={styles.shore} />
    </div>
  );
}
