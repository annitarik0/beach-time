// Shared content and tokens. Numbers here come straight from the Flutter app
// (lib/logic/beach_score.dart, lib/theme/palette.dart) so the site never
// promises something the app doesn't do.

export const base = process.env.NEXT_PUBLIC_BASE_PATH ?? "";
export const asset = (p: string) => `${base}${p}`;

export const REPO_URL = "https://github.com/annitarik0/beachtime-app";
export const SITE_REPO_URL = "https://github.com/annitarik0/beach-time";
export const BEHANCE_URL = "https://www.behance.net/gallery/258758635/Beach-Time-Brand-Identity";
export const WEB_APP_URL = asset("/app/");

export type ActivityId = "swim" | "surf" | "chill";

export const activities: { id: ActivityId; label: string; verb: string }[] = [
  { id: "swim", label: "Swim", verb: "swim" },
  { id: "surf", label: "Surf", verb: "surf" },
  { id: "chill", label: "Chill", verb: "lie in the sun" },
];

/** Factor weights per activity, identical to BeachScorer in the app. */
export const weights: Record<ActivityId, { factor: string; weight: number }[]> = {
  swim: [
    { factor: "Air temperature", weight: 22 },
    { factor: "Water temperature", weight: 22 },
    { factor: "Waves", weight: 18 },
    { factor: "Wind", weight: 14 },
    { factor: "Rain", weight: 12 },
    { factor: "Sunshine", weight: 8 },
    { factor: "UV", weight: 4 },
  ],
  surf: [
    { factor: "Waves", weight: 40 },
    { factor: "Wind", weight: 22 },
    { factor: "Water temperature", weight: 10 },
    { factor: "Rain", weight: 10 },
    { factor: "Air temperature", weight: 8 },
    { factor: "Sunshine", weight: 5 },
    { factor: "UV", weight: 5 },
  ],
  chill: [
    { factor: "Air temperature", weight: 26 },
    { factor: "Rain", weight: 22 },
    { factor: "Sunshine", weight: 20 },
    { factor: "Wind", weight: 16 },
    { factor: "UV", weight: 6 },
    { factor: "Water temperature", weight: 6 },
    { factor: "Waves", weight: 4 },
  ],
};

export const ratings = [
  { word: "Epic", min: 85, color: "var(--sea)" },
  { word: "Good", min: 70, color: "var(--kelp)" },
  { word: "Fair", min: 55, color: "var(--sun)" },
  { word: "Poor", min: 40, color: "var(--orange)" },
  { word: "Very poor", min: 0, color: "var(--coral)" },
];

export function scoreColor(s: number) {
  return (ratings.find((r) => s >= r.min) ?? ratings[ratings.length - 1]).color;
}

export function ratingWord(s: number) {
  return (ratings.find((r) => s >= r.min) ?? ratings[ratings.length - 1]).word;
}

export const palette = [
  { name: "Paper", hex: "#F4EEE4", use: "Page background", dark: false },
  { name: "Card", hex: "#FFFCF7", use: "Cards and sheets", dark: false },
  { name: "Sunk", hex: "#EDE5D8", use: "Tracks and chips", dark: false },
  { name: "Line", hex: "#E6DCCD", use: "Borders", dark: false },
  { name: "Ink", hex: "#0F2A35", use: "Text and primary buttons", dark: true },
  { name: "Ink soft", hex: "#52707B", use: "Secondary text", dark: true },
  { name: "Sea", hex: "#127C8A", use: "The one accent", dark: true },
  { name: "Sea deep", hex: "#0B4F5C", use: "Deep water, pressed states", dark: true },
  { name: "Foam", hex: "#D7ECEA", use: "Soft highlights", dark: false },
  { name: "Sun", hex: "#F2B33D", use: "Sun, stars, fair scores", dark: false },
  { name: "Kelp", hex: "#4A9B76", use: "Good scores, green flag", dark: true },
  { name: "Coral", hex: "#E8623F", use: "Warnings, poor scores", dark: true },
];
