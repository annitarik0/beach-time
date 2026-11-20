import styles from "./SeaWaves.module.css";

/** Three looping wave layers with foam crests, like the app's SkyScene. */
export function SeaWaves({ height = 120 }: { height?: number }) {
  const wave = (y: number, amp: number) => {
    // One 600-wide period, drawn twice so a -50% shift loops seamlessly.
    let d = `M0 ${y}`;
    for (let x = 0; x < 1200; x += 150) {
      d += ` q75 ${x % 300 === 0 ? -amp : amp} 150 0`;
    }
    return `${d} V200 H0 Z`;
  };
  return (
    <div className={styles.sea} style={{ height }} aria-hidden="true">
      <svg className={`${styles.layer} ${styles.l1}`} viewBox="0 0 1200 200" preserveAspectRatio="none">
        <path d={wave(70, 18)} fill="var(--wave-1)" />
      </svg>
      <svg className={`${styles.layer} ${styles.l2}`} viewBox="0 0 1200 200" preserveAspectRatio="none">
        <path d={wave(105, 14)} fill="var(--wave-2)" />
      </svg>
      <svg className={`${styles.layer} ${styles.l3}`} viewBox="0 0 1200 200" preserveAspectRatio="none">
        <path d={wave(140, 12)} fill="var(--wave-3)" />
      </svg>
    </div>
  );
}
