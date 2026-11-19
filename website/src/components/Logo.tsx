import { useId } from "react";

/** The app icon as an inline mark: sun rising over two waves. */
export function LogoMark({ size = 36, className }: { size?: number; className?: string }) {
  const id = useId().replace(/:/g, "");
  return (
    <svg width={size} height={size} viewBox="0 0 1024 1024" className={className} aria-hidden="true">
      <defs>
        <linearGradient id={`${id}s`} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="#FBE2BE" />
          <stop offset="1" stopColor="#F6EBDC" />
        </linearGradient>
        <linearGradient id={`${id}u`} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="#F6C24E" />
          <stop offset="1" stopColor="#EE7F45" />
        </linearGradient>
        <clipPath id={`${id}r`}>
          <rect width="1024" height="1024" rx="230" />
        </clipPath>
        <clipPath id={`${id}a`}>
          <rect width="1024" height="640" />
        </clipPath>
      </defs>
      <g clipPath={`url(#${id}r)`}>
        <rect width="1024" height="1024" fill={`url(#${id}s)`} />
        <circle cx="512" cy="600" r="250" fill={`url(#${id}u)`} clipPath={`url(#${id}a)`} />
        <path d="M0 610 Q128 560 256 610 T512 610 T768 610 T1024 610 V1024 H0 Z" fill="#168493" />
        <path
          d="M0 610 Q128 560 256 610 T512 610 T768 610 T1024 610"
          fill="none"
          stroke="#FFFCF7"
          strokeWidth="30"
          strokeLinecap="round"
        />
        <path d="M0 790 Q128 745 256 790 T512 790 T768 790 T1024 790 V1024 H0 Z" fill="#0B4F5C" />
      </g>
    </svg>
  );
}

export function Wordmark({ className }: { className?: string }) {
  return (
    <span className={className} style={{ display: "inline-flex", alignItems: "center", gap: 10 }}>
      <LogoMark size={34} />
      <span
        className="display"
        style={{ fontSize: 22, letterSpacing: "-0.03em", lineHeight: 1, fontWeight: 750 }}
      >
        Beach Time
      </span>
    </span>
  );
}
