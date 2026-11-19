import { AppleLogo, ArrowUpRight, Browser, GithubLogo } from "@phosphor-icons/react/dist/ssr";
import { REPO_URL, WEB_APP_URL } from "@/lib/brand";
import { SeaWaves } from "./SeaWaves";
import styles from "./GetApp.module.css";

export function GetApp() {
  return (
    <section id="get" className={styles.section}>
      <div className={`wrap ${styles.inner}`}>
        <div className={styles.head} data-reveal>
          <span className="label" style={{ color: "rgb(255 255 255 / 75%)" }}>
            Get Beach Time
          </span>
          <h2 className="display">Your next beach day starts here.</h2>
          <p className="lead" style={{ color: "rgb(255 255 255 / 80%)" }}>
            The full app runs in your browser right now. Add it to your Home Screen and it opens like any
            other app.
          </p>
        </div>

        <div className={styles.options} data-reveal="stagger">
          <a className={styles.option} href={WEB_APP_URL}>
            <span className={styles.icon}>
              <Browser size={22} weight="bold" />
            </span>
            <b>Open the web app</b>
            <span>Works on any phone or computer. On iPhone, tap Share, then Add to Home Screen.</span>
            <span className={styles.go}>
              Open now <ArrowUpRight size={16} weight="bold" />
            </span>
          </a>
          <div className={styles.option}>
            <span className={styles.icon}>
              <AppleLogo size={22} weight="fill" />
            </span>
            <b>Native iPhone app</b>
            <span>
              The native app is built with Flutter. Download BeachTime.ipa from the latest build and install it
              with Sideloadly.
            </span>
            <a className={styles.go} href={`${REPO_URL}/actions/workflows/ios-ipa.yml`}>
              Latest build <ArrowUpRight size={16} weight="bold" />
            </a>
          </div>
          <a className={styles.option} href={REPO_URL}>
            <span className={styles.icon}>
              <GithubLogo size={22} weight="fill" />
            </span>
            <b>Open source</b>
            <span>Read the code, suggest a feature or build it for Android yourself.</span>
            <span className={styles.go}>
              View on GitHub <ArrowUpRight size={16} weight="bold" />
            </span>
          </a>
        </div>
      </div>
      <SeaWaves height={110} />
    </section>
  );
}
