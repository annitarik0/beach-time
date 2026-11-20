import type { Metadata, Viewport } from "next";
import localFont from "next/font/local";
import "./globals.css";

// The same variable fonts the Flutter app bundles.
const display = localFont({
  src: "../fonts/BricolageGrotesque.ttf",
  variable: "--font-display",
  weight: "200 800",
  display: "swap",
});
const body = localFont({
  src: "../fonts/Manrope.ttf",
  variable: "--font-body",
  weight: "200 800",
  display: "swap",
});

const site = "https://annitarik0.github.io/beach-time";

export const metadata: Metadata = {
  metadataBase: new URL(site),
  title: {
    default: "Beach Time | Know the perfect beach day",
    template: "%s | Beach Time",
  },
  description:
    "Beach Time scores every hour from 0 to 100 for swimming, surfing or chilling, and tells you the best time to go. Water temperature, waves, tides, UV and safety in one calm app.",
  openGraph: {
    title: "Beach Time",
    description: "Know the perfect beach day. Every hour scored for swim, surf and chill.",
    url: site,
    siteName: "Beach Time",
    type: "website",
  },
};

export const viewport: Viewport = {
  themeColor: "#F4EEE4",
  width: "device-width",
  initialScale: 1,
};

// Runs before first paint: marks JS as available (so reveal animations can
// start hidden) and skips the intro loader after the first visit this session.
const boot = `(function(){var d=document.documentElement;d.classList.add('js');try{if(sessionStorage.getItem('bt-intro'))d.classList.add('intro-seen')}catch(e){}})();`;

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en" className={`${display.variable} ${body.variable}`} suppressHydrationWarning>
      <head>
        <script dangerouslySetInnerHTML={{ __html: boot }} />
      </head>
      <body>{children}</body>
    </html>
  );
}
