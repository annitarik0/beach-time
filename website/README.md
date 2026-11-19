# Beach Time website

The marketing site and brand kit for Beach Time, built with Next.js, GSAP and Lenis.
It uses the same fonts, colours and score logic as the Flutter app.

- `src/components/Loader.tsx` is the animated intro (sun, waves and a tide wipe).
- `src/lib/brand.ts` holds the colours, ratings and score weights copied from the app.
- `/brand/` is the brand kit page and `/privacy/` the privacy page.

## Run it

```bash
npm install
npm run dev
```

Open http://localhost:3000.

## Publish

Every push to `main` runs `.github/workflows/website.yml`. It builds this site as static files,
builds the Flutter web app into `/app/`, and publishes both to GitHub Pages.
