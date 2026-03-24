FROM node:20-alpine

WORKDIR /app

# Install basic utilities
RUN apk add --no-cache dumb-init

# Copy server file
COPY server.js .

# Copy QuranExplorer files
COPY QuranExplorer/ ./public/

# Copy audio files
COPY audio/ ./public/audio/

# Create .dockerignore equivalent by removing unnecessary files
RUN rm -f ./public/*.md ./public/deploy*.ps1

# Use dumb-init to handle signals properly
ENTRYPOINT ["/sbin/dumb-init", "--"]
CMD ["node", "server.js"]

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})" || exit 1
