"use client";

import { useEffect, useState } from "react";
import { ArrowUpRight } from "@phosphor-icons/react";
import { Wordmark } from "./Logo";
import { asset, WEB_APP_URL } from "@/lib/brand";
import styles from "./Header.module.css";

const links = [
  { href: "/#features", label: "Features" },
  { href: "/#score", label: "The score" },
  { href: "/#buddy", label: "Beach Buddy" },
  { href: "/#get", label: "Get the app" },
];

export function Header() {
  const [scrolled, setScrolled] = useState(false);
  const [dark, setDark] = useState(false);
  useEffect(() => {
    const on = () => {
      setScrolled(window.scrollY > 12);
      // Switch to the dark glass while a dark section sits under the header.
      const under = Array.from(document.querySelectorAll<HTMLElement>("[data-header='dark']")).some((el) => {
        const r = el.getBoundingClientRect();
        return r.top < 36 && r.bottom > 36;
      });
      setDark(under);
    };
    on();
    window.addEventListener("scroll", on, { passive: true });
    return () => window.removeEventListener("scroll", on);
  }, []);

  return (
    <header className={`${styles.header} ${scrolled ? styles.scrolled : ""} ${dark ? styles.dark : ""}`}>
      <div className={`wrap ${styles.inner}`}>
        <a href={asset("/")} aria-label="Beach Time home">
          <Wordmark />
        </a>
        <nav className={styles.nav} aria-label="Main">
          {links.map((l) => (
            <a key={l.href} href={asset(l.href)}>
              {l.label}
            </a>
          ))}
        </nav>
        <a className={`btn btn-ink ${styles.cta}`} href={WEB_APP_URL}>
          Open the app <ArrowUpRight size={16} weight="bold" />
        </a>
      </div>
    </header>
  );
}
