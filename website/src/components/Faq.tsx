import styles from "./Faq.module.css";

const faqs = [
  {
    q: "Where does the data come from?",
    a: "Weather, marine and air quality forecasts come from Open-Meteo, a free open data service that combines national weather models. Water temperature, waves and tides use its marine model. Data is licensed CC BY 4.0.",
  },
  {
    q: "How accurate is the score?",
    a: "The score is only as good as the forecast, which is very reliable for the next two or three days and less so after that. It is a guide for planning, not a safety guarantee.",
  },
  {
    q: "Is the beach flag real?",
    a: "No. Beach Time estimates a flag colour from wave height, wave period and wind. Real flags are set by lifeguards on the spot, so always follow them.",
  },
  {
    q: "Does it cost anything or need an account?",
    a: "No and no. There are no ads, no sign-up and no tracking. Your saved beaches and checklist stay on your device.",
  },
  {
    q: "Which AI does Beach Buddy use?",
    a: "By default GPT-OSS, an open-weight model, through a free public service. You can switch to your own provider or a model running on your computer in Settings. Only the forecast and your question are sent.",
  },
  {
    q: "Does it work everywhere?",
    a: "Weather works for any place on Earth. Sea data (water temperature, waves, tides) is available along coastlines; for lakes and some sheltered bays it may be missing, and the app says so.",
  },
];

export function Faq() {
  return (
    <section className="section" id="faq">
      <div className={`wrap ${styles.grid}`}>
        <div className="section-head" data-reveal>
          <span className="label">Questions</span>
          <h2 className="display">Good to know.</h2>
        </div>
        <div className={styles.list} data-reveal="stagger">
          {faqs.map((f) => (
            <details key={f.q} className={styles.item}>
              <summary>
                {f.q}
                <span className={styles.plus} aria-hidden="true" />
              </summary>
              <p>{f.a}</p>
            </details>
          ))}
        </div>
      </div>
    </section>
  );
}
