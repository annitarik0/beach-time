// Shared WebGL sea used by the 3D loader and the ocean above the footer.
// three.js is imported lazily by callers, so it never blocks first paint.

export type Three = typeof import("three");

export const loadThree = () => import("three");

export const hex3 = (T: Three, h: string) => {
  const n = parseInt(h.slice(1), 16);
  return new T.Vector3(((n >> 16) & 255) / 255, ((n >> 8) & 255) / 255, (n & 255) / 255);
};

const vertex = /* glsl */ `
  uniform float uTime;
  uniform float uAmp;
  varying vec3 vWorld;
  varying vec3 vNormal;
  varying float vH;

  // Gerstner wave: points move in circles so crests are sharp and troughs round.
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
    o += wave(vec2(0.25, 1.0), 0.16 * uAmp, 11.0, p, t, b);
    o += wave(vec2(-0.55, 1.0), 0.13 * uAmp, 6.5, p, t, b);
    o += wave(vec2(0.9, 0.55), 0.09 * uAmp, 3.6, p, t, b);
    o += wave(vec2(-0.2, 1.0), 0.07 * uAmp, 2.1, p, t, b);
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
  uniform float uFadeNear;
  uniform float uFadeFar;
  uniform float uHaze;
  uniform float uHazeNear;
  uniform float uHazeFar;
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
    col += uSun * (pow(sd, 220.0) * 1.8 + pow(sd, 14.0) * 0.18);

    float foam = smoothstep(0.42, 0.8, vH);
    col = mix(col, vec3(0.94, 0.98, 0.97), foam * 0.5);

    // Haze into the sky colour, then fade out so the water melts into
    // whatever sky sits behind the canvas.
    float d = length(vWorld.xz - cameraPosition.xz);
    col = mix(col, uSky, smoothstep(uHazeNear, uHazeFar, d) * uHaze);
    float a = 1.0 - smoothstep(uFadeNear, uFadeFar, d);
    gl_FragColor = vec4(col * a, a);
  }
`;

export type SeaColors = { deep: string; shallow: string; sky: string; sun: string };

/** A large animated sea plane. Call `uniforms.uTime.value = t` every frame. */
export function makeSea(T: Three, c: SeaColors, segments = 150) {
  const geo = new T.PlaneGeometry(90, 90, segments, segments);
  geo.rotateX(-Math.PI / 2);
  geo.translate(0, 0, -32);
  const uniforms = {
    uTime: { value: 0 },
    uAmp: { value: 1 },
    uDeep: { value: hex3(T, c.deep) },
    uShallow: { value: hex3(T, c.shallow) },
    uSky: { value: hex3(T, c.sky) },
    uSun: { value: hex3(T, c.sun) },
    uSunDir: { value: new T.Vector3(0.38, 0.22, -1) },
    uFadeNear: { value: 18 },
    uFadeFar: { value: 34 },
    uHaze: { value: 0.7 },
    uHazeNear: { value: 10 },
    uHazeFar: { value: 34 },
  };
  const mat = new T.ShaderMaterial({
    vertexShader: vertex,
    fragmentShader: fragment,
    uniforms,
    transparent: true,
    premultipliedAlpha: true,
  });
  const mesh = new T.Mesh(geo, mat);
  return {
    mesh,
    uniforms,
    dispose: () => {
      geo.dispose();
      mat.dispose();
    },
  };
}

/** Renderer tuned for smooth frame rates over pixel-perfect edges. */
export function makeRenderer(T: Three) {
  const dpr = Math.min(window.devicePixelRatio || 1, 1.5);
  const r = new T.WebGLRenderer({
    antialias: dpr < 1.5,
    alpha: true,
    powerPreference: "high-performance",
  });
  r.setPixelRatio(dpr);
  r.setClearColor(0x000000, 0);
  return r;
}
