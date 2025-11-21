# Minimal multi-stage Dockerfile for a Next.js app
# - Builder stage installs dependencies (including dev deps) and runs the build
# - Runner stage installs only production deps and runs the app with NODE_ENV=production
FROM node:20-alpine AS builder
WORKDIR /app

# Install native build tools (some deps may need them) and copy package files
RUN apk add --no-cache python3 make g++
# Copy package files from the Next app folder
COPY graceful-gathering/package*.json ./

# Use npm ci when package-lock.json is present, otherwise fall back to npm install
RUN sh -lc "if [ -f package-lock.json ]; then npm ci; else npm install; fi"

# Copy the Next.js app source (from the subfolder) and build
COPY graceful-gathering/ .
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

# Install tini (small init) and then install production dependencies only
RUN apk add --no-cache tini
COPY graceful-gathering/package*.json ./
RUN sh -lc "if [ -f package-lock.json ]; then npm ci --only=production; else npm install --only=production; fi"

# Copy built output and public files
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public

EXPOSE 3000

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["npm", "run", "start"]

