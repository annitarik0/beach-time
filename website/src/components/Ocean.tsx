"use client";

import { useEffect, useRef, useState } from "react";
import * as THREE from "three";
import { SeaWaves } from "./SeaWaves";
import styles from "./Ocean.module.css";

const hex = (h: string) => {
  const n = parseInt(h.slice(1), 16);
  return new THREE.Vector3(((n >> 16) & 255) / 255, ((n >> 8) & 255) / 255, (n & 255) / 255);
};

const vertex = /* glsl */ `
  uniform float uTime;
  varying vec3 vWorld;
  varying vec3 vNormal;
  varying float vH;

  // Gerstner wave: moves points in circles so crests get sharp and troughs round.
  vec3 wave(vec2 dir, float steep, float len, vec3 p, inout vec3 t, inout vec3 b) {
    float k = 6.28318 / len;
    float c = sqrt(9.8 / k);
    vec2 d = normalize(dir);
    float f = k * (dot(d, p.xz) - c * uTime);
    float a = steep / k;
    float s = sin(f), co = cos(f);
    t += vec3(-d.x * d.x * steep * s, d.x * steep * co, -d.x * d.y * steep * s);
    b += vec3(-d.x * d.y * steep * s, d.y * steep * co, -d.y * d.y * steep * s);
    return vec3(d.x * a * co, a * s, d.y * a * co);
  }

  void main() {
    vec3 p = position;
    vec3 t = vec3(1.0, 0.0, 0.0);
    vec3 b = vec3(0.0, 0.0, 1.0);
    vec3 o = p;
    o += wave(vec2(0.25, 1.0), 0.16, 11.0, p, t, b);
    o += wave(vec2(-0.55, 1.0), 0.13, 6.5, p, t, b);
    o += wave(vec2(0.9, 0.55), 0.09, 3.6, p, t, b);
    o += wave(vec2(-0.2, 1.0), 0.07, 2.1, p, t, b);
    vH = o.y;
    vNormal = normalize(cross(b, t));
    vec4 w = modelMatrix * vec4(o, 1.0);
    vWorld = w.xyz;
    gl_Position = projectionMatrix * viewMatrix * w;
  }
`;

const fragment = /* glsl */ `
  uniform vec3 uDeep;
  uniform vec3 uShallow;
  uniform vec3 uSky;
  uniform vec3 uSun;
  uniform vec3 uSunDir;
  varying vec3 vWorld;
  varying vec3 vNormal;
  varying float vH;

  void main() {
    vec3 n = normalize(vNormal);
    vec3 v = normalize(cameraPosition - vWorld);
    float fres = pow(1.0 - max(dot(n, v), 0.0), 4.0);

    vec3 col = mix(uDeep, uShallow, smoothstep(-0.35, 0.55, vH));
    col = mix(col, uSky, fres * 0.65);

    vec3 r = reflect(-v, n);
    float sd = max(dot(r, normalize(uSunDir)), 0.0);
    col += uSun * (pow(sd, 220.0) * 1.8 + pow(sd, 14.0) * 0.16);

    float foam = smoothstep(0.42, 0.8, vH);
    col = mix(col, vec3(0.94, 0.98, 0.97), foam * 0.5);

    // Towards the horizon, first haze into the sky colour, then fade out
    // completely so the water melts into the CSS sky behind the canvas.
    float d = length(vWorld.xz - cameraPosition.xz);
    col = mix(col, uSky, smoothstep(10.0, 30.0, d) * 0.7);
    float a = 1.0 - smoothstep(18.0, 34.0, d);
    gl_FragColor = vec4(col * a, a);
  }
`;

/** A real-time 3D sea under the "Get the app" sky, ending in a shoreline. */
export function Ocean() {
  const host = useRef<HTMLDivElement>(null);
  const [failed, setFailed] = useState(false);

  useEffect(() => {
    const el = host.current;
    if (!el) return;

    let renderer: THREE.WebGLRenderer;
    try {
      renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true, powerPreference: "low-power" });
    } catch {
      // No WebGL: fall back to the flat CSS waves.
      queueMicrotask(() => setFailed(true));
      return;
    }
    const reduce = matchMedia("(prefers-reduced-motion: reduce)").matches;
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 1.5));
    renderer.setClearColor(0x000000, 0);
    el.appendChild(renderer.domElement);

    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(42, 1, 0.1, 200);
    const look = new THREE.Vector3(0, 0.4, -12);

    const geo = new THREE.PlaneGeometry(90, 90, 220, 220);
    geo.rotateX(-Math.PI / 2);
    geo.translate(0, 0, -32);
    const uniforms = {
      uTime: { value: 0 },
      uDeep: { value: hex("#0B4F5C") },
      uShallow: { value: hex("#2A97A3") },
      uSky: { value: hex("#9CD1D3") },
      uSun: { value: hex("#FFE2A1") },
      uSunDir: { value: new THREE.Vector3(0.38, 0.22, -1) },
    };
    const mat = new THREE.ShaderMaterial({
      vertexShader: vertex,
      fragmentShader: fragment,
      uniforms,
      transparent: true,
      premultipliedAlpha: true,
    });
    scene.add(new THREE.Mesh(geo, mat));

    const size = () => {
      const w = el.clientWidth;
      const h = el.clientHeight;
      renderer.setSize(w, h, false);
      camera.aspect = w / h;
      // Keep the horizon in a similar place on narrow phones.
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

    let visible = false;
    let raf = 0;
    const start = performance.now();
    const frame = () => {
      raf = 0;
      const t = (performance.now() - start) / 1000;
      uniforms.uTime.value = t * 0.75;
      pointer.x += (pointer.tx - pointer.x) * 0.04;
      const r = el.getBoundingClientRect();
      const p = Math.min(Math.max(1 - r.top / window.innerHeight, 0), 1.4);
      camera.position.set(pointer.x * 1.4, 3.3 - p * 0.9, 6);
      look.x = pointer.x * 0.6;
      camera.lookAt(look);
      renderer.render(scene, camera);
      if (visible && !reduce) raf = requestAnimationFrame(frame);
    };
    const io = new IntersectionObserver(([entry]) => {
      visible = entry.isIntersecting;
      if (visible && !raf) raf = requestAnimationFrame(frame);
    });
    io.observe(el);
    frame();

    return () => {
      cancelAnimationFrame(raf);
      io.disconnect();
      ro.disconnect();
      window.removeEventListener("pointermove", onMove);
      geo.dispose();
      mat.dispose();
      renderer.dispose();
      renderer.domElement.remove();
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
