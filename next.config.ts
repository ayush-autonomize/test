import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  images: {
    domains: ['images.unsplash.com'],
    unoptimized: process.env.NODE_ENV === 'development',
  },
  // Disable ESLint during the production build inside Docker to avoid build failures
  // caused by lint rules (keeps CI/linting local or in CI pipeline).
  eslint: {
    ignoreDuringBuilds: true,
  },
}

export default nextConfig;
