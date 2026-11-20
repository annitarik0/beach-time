import type { NextConfig } from "next";

// Static site for GitHub Pages. NEXT_PUBLIC_BASE_PATH is "/beach-time" in the
// deploy workflow and empty locally.
const basePath = process.env.NEXT_PUBLIC_BASE_PATH ?? "";

const nextConfig: NextConfig = {
  output: "export",
  basePath,
  trailingSlash: true,
  images: { unoptimized: true },
};

export default nextConfig;
