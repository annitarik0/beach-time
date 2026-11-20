import type { Metadata } from "next";
import { DownloadSimple } from "@phosphor-icons/react/dist/ssr";
import { Motion } from "@/components/Motion";
import { Header } from "@/components/Header";
import { Footer } from "@/components/Footer";
import { LogoMark, Wordmark } from "@/components/Logo";
import { ScoreRing } from "@/components/ScoreRing";
import { asset, palette, ratings } from "@/lib/brand";
import styles from "./brand.module.css";

export const metadata: Metadata = {
  title: "Brand kit",
  description: "Logo, colours, type and voice for Beach Time.",
};

const downloads = [
  { file: "/brand/logo-mark.svg", label: "App icon", kind: "SVG" },
  { file: "/brand/app-icon-1024.png", label: "App icon 1024 px", kind: "PNG" },
  { file: "/brand/logo-mark-mono.svg", label: "One-colour mark", kind: "SVG" },
];

const voice = [
  {
    title: "Say the answer first",
    yes: "A good beach day. Go between 12:00 and 18:00.",
    no: "Based on our analysis of current conditions, today could potentially be a good day.",
  },
  {
    title: "Talk like a friend at the beach",
    yes: "Bring a jacket, the wind picks up after 4.",
    no: "Wind speeds are forecast to increase in the late afternoon period.",
  },
  {
    title: "Safety is never a joke",
    yes: "Strong waves today. Swim only where lifeguards are on duty.",
    no: "Surf's up, dude! Hit the waves!",
  },
];

export default function BrandPage() {
  return (
    <>
      <Motion />
      <Header />
      <main className={styles.page}>
        <section className="wrap">
          <div className={styles.intro} data-reveal>
            <span className="label">Brand kit</span>
            <h1 className="display">Warm sand, clear water, one sun.</h1>
            <p className="lead">
              Beach Time should feel like the hour before you leave for the beach: calm, bright and sure of
              itself. Everything here is used the same way in the app and on this site.
            </p>
          </div>
        </section>

        <section className={`wrap ${styles.block}`}>
          <div className={styles.blockHead}>
            <span className="label">01</span>
            <h2 className="title">Logo</h2>
            <p className="muted">
              A sun rising over two waves. It is the score in one picture: the sun is the day, the water is the
              sea. Keep the rounded square shape and never recolour the icon.
            </p>
          </div>
          <div className={styles.logoGrid} data-reveal="stagger">
            <div className={`${styles.logoTile} ${styles.tilePaper}`}>
              <LogoMark size={132} />
            </div>
            <div className={`${styles.logoTile} ${styles.tileInk}`}>
              <Wordmark />
            </div>
            <div className={`${styles.logoTile} ${styles.tileSea}`}>
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src={asset("/brand/logo-mark-mono.svg")} alt="" width={96} height={96} className={styles.mono} />
            </div>
          </div>
          <div className={styles.downloads}>
            {downloads.map((d) => (
              <a key={d.file} href={asset(d.file)} download className={styles.download}>
                <DownloadSimple size={18} weight="bold" />
                {d.label}
                <span>{d.kind}</span>
              </a>
            ))}
          </div>
        </section>

        <section className={`wrap ${styles.block}`}>
          <div className={styles.blockHead}>
            <span className="label">02</span>
            <h2 className="title">Colour</h2>
            <p className="muted">
              Paper and ink do most of the work. Sea is the single accent. Sun, kelp and coral are kept for
              meaning: scores, flags and warnings.
            </p>
          </div>
          <div className={styles.swatches} data-reveal="stagger">
            {palette.map((c) => (
              <div key={c.hex} className={styles.swatch}>
                <div
                  className={styles.chipColor}
                  style={{ background: c.hex, color: c.dark ? "#fff" : "var(--ink)" }}
                >
                  {c.hex}
                </div>
                <b>{c.name}</b>
                <span>{c.use}</span>
              </div>
            ))}
          </div>
          <div className={styles.scale} data-reveal>
            {ratings.map((r) => (
              <div key={r.word} className={styles.scaleItem}>
                <span style={{ background: r.color }} />
                <b>{r.word}</b>
                <small>{r.min > 0 ? `${r.min}+` : "under 40"}</small>
              </div>
            ))}
          </div>
        </section>

        <section className={`wrap ${styles.block}`}>
          <div className={styles.blockHead}>
            <span className="label">03</span>
            <h2 className="title">Type</h2>
            <p className="muted">
              Bricolage Grotesque for headlines and numbers, Manrope for everything you read. Both are free
              under the SIL Open Font License.
            </p>
          </div>
          <div className={styles.typeGrid} data-reveal="stagger">
            <div className={`card ${styles.typeCard}`}>
              <span className="label">Display</span>
              <p className={`display ${styles.bigType}`}>Aa 83</p>
              <p className="muted">Bricolage Grotesque · 600 to 750</p>
            </div>
            <div className={`card ${styles.typeCard}`}>
              <span className="label">Body</span>
              <p className={styles.bodyType}>Water 21°, waves 0.6 m, light breeze from the west.</p>
              <p className="muted">Manrope · 400 to 800</p>
            </div>
          </div>
        </section>

        <section className={`wrap ${styles.block}`}>
          <div className={styles.blockHead}>
            <span className="label">04</span>
            <h2 className="title">The score</h2>
            <p className="muted">
              The ring is the signature element. It always shows a number from 0 to 100 in the colour of its
              rating. Use it only for real scores.
            </p>
          </div>
          <div className={styles.rings} data-reveal="stagger">
            {[91, 76, 58, 34].map((s) => (
              <div key={s} className={styles.ringTile}>
                <ScoreRing score={s} size={150} dark={false} />
              </div>
            ))}
          </div>
        </section>

        <section className={`wrap ${styles.block}`}>
          <div className={styles.blockHead}>
            <span className="label">05</span>
            <h2 className="title">Voice</h2>
            <p className="muted">Short, warm and useful. Numbers over adjectives. No hype.</p>
          </div>
          <div className={styles.voice} data-reveal="stagger">
            {voice.map((v) => (
              <div key={v.title} className={`card ${styles.voiceCard}`}>
                <b>{v.title}</b>
                <p className={styles.yes}>{v.yes}</p>
                <p className={styles.no}>{v.no}</p>
              </div>
            ))}
          </div>
        </section>
      </main>
      <Footer />
    </>
  );
}
