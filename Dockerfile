
FROM node:20.18.0 AS base

FROM base AS builder
# Building
WORKDIR /build
COPY . .
RUN npm install

# This feels like cheating. Docker should be able to handle this on its own accordingly.
# RUN npm install @libsql/linux-arm64-gnu
# Lets first test adding hese to the package.json
#       "libsql": "^0.4.6",
#       "@libsql/client": "^0.14.0",
    

RUN npm run build

FROM base AS runner
WORKDIR /app
# Copy built standalone version.
# Note: This is missing /public 
# We need to check if public even exists before we can copy it!
COPY --from=builder /build/.next/standalone .
COPY --from=builder /build/.next/static ./.next/static

# Running
ENV NODE_ENV=production
EXPOSE 3000
ENV PORT=3000

# Create mountable folder for local uploads.
RUN mkdir uploads
ENV PAYLOAD_UPLOADS_DIR=./uploads

# Create mountable folder for local database.
RUN mkdir db
ENV DATABASE_URI=file:./db/database.db

# Payloadscret. For testing only.

# Execute standalone compiled version.
CMD ["node", "server.js"]
