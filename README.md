# Beach Time website

The marketing site and brand kit for Beach Time, built with Next.js, GSAP and Lenis.
It uses the same fonts, colours and score logic as the [Flutter app](https://github.com/annitarik0/beachtime-app).

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
checks out the app from [beachtime-app](https://github.com/annitarik0/beachtime-app),
builds its Flutter web version into `/app/`, and publishes both to GitHub Pages:
https://annitarik0.github.io/beach-time/

After changing the app, run the workflow again from the Actions tab ("Run workflow") to refresh `/app/`.



## Brand kit

`branding/` holds the logo files, icons, colours, fonts, the brand guidelines PDF and the identity
presentation published on [Behance](https://www.behance.net/gallery/258758635/Beach-Time-Brand-Identity).
See [`branding/README.md`](branding/README.md).
