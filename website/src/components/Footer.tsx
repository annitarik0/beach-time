import { Wordmark } from "./Logo";
import { asset, REPO_URL, WEB_APP_URL } from "@/lib/brand";
import styles from "./Footer.module.css";

export function Footer() {
  return (
    <footer className={styles.footer}>
      <div className={`wrap ${styles.inner}`}>
        <div className={styles.brand}>
          <Wordmark />
          <p>Know the perfect beach day.</p>
        </div>
        <nav className={styles.cols} aria-label="Footer">
          <div>
            <span className="label">App</span>
            <a href={WEB_APP_URL}>Web app</a>
            <a href={asset("/#features")}>Features</a>
            <a href={asset("/#score")}>The score</a>
          </div>
          <div>
            <span className="label">Brand</span>
            <a href={asset("/brand/")}>Brand kit</a>
            <a href={asset("/privacy/")}>Privacy</a>
            <a href={REPO_URL}>GitHub</a>
          </div>
        </nav>
      </div>
      <div className={`wrap ${styles.legal}`}>
        <span>
          Weather and marine data by <a href="https://open-meteo.com/">Open-Meteo.com</a> (CC BY 4.0).
        </span>
        <span>Forecasts are estimates. Always follow lifeguards and local flags.</span>
      </div>
    </footer>
  );
}
