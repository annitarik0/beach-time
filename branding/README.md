# Beach Time — Brand kit

Everything needed to use the Beach Time brand, matching the app and the website.

| File / folder | What it is |
| --- | --- |
| `Beach Time Brand Identity.pdf` | 14-page brand identity presentation (concept, symbol, wave wordmark, modes, graphics, campaign, merch, social, outdoor) |
| `behance/` | The same 14 pages as 1920×1200 PNGs, a cover thumbnail and the post text for Behance |
| `Beach Time Brand Guidelines.pdf` | 11-page guide: idea, logo, usage, colour, type, score, interface, motion, voice, examples |
| `Beach Time Brand Board (Figma preview).png` | Preview of the Figma brand board |
| Figma file | https://www.figma.com/design/Hrhm4OQZZabNDXCk0RFw5c (brand board with colour variables and text styles, plus the identity presentation page) |
| `logo/` | Wave wordmark PNGs (ink, white), app icon SVG, one-colour marks (ink, white, sea), PNG lockups (horizontal and stacked, ink and white, transparent) |
| `icons/` | App icon PNGs at 1024, 512, 180, 64 and 32 px |
| `colors/` | Palette as JSON, CSS variables (`--bt-*`) and plain text, with contrast ratios |
| `fonts/` | Bricolage Grotesque (display) and Manrope (body), both SIL Open Font License |
| `source/` | HTML sources for the PDF and lockups, plus app screenshots |

## Quick reference

- **Colours:** Paper `#F4EEE4`, Card `#FFFCF7`, Ink `#0F2A35`, Sea `#127C8A`, Sea deep `#0B4F5C`, Foam `#D7ECEA`, Sun `#F2B33D`, Coral `#E8623F`, Kelp `#4A9B76`
- **Type:** Bricolage Grotesque 700–750, tight tracking (−0.025 to −0.045em) for headings; Manrope 400–800 for text; labels 11–12 px caps, 0.12em
- **Score scale:** Epic 85+ · Good 70+ · Fair 55+ · Poor 40+ · Very poor below 40
- **Voice:** say the answer first, numbers over adjectives, no hype, safety is never a joke

## The identity

- **Idea:** Read the ocean. Sun + wave + number.
- **Wave wordmark:** lowercase "beach time" set on a sine curve with a tide line under it.
- **Modes:** Swim (foam, lagoon), Surf (night ink, wax orange), Chill (gold, sunset).
- **Graphic system:** tide lines, sunset stripes, score rings.
- **Campaign voice:** "Today is a 94." "Go at 16:00." "Shade after lunch."

To rebuild the PDFs, serve this folder (`python -m http.server 8801`) and print `source/guidelines.html` (1440×900) or `source/behance.html` (1920×1200) with backgrounds on.
