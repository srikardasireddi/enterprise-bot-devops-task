FROM node:22.14.0-alpine AS builder
WORKDIR /app
COPY server.js ./

FROM node:22.14.0-alpine AS runtime
ENV NODE_ENV=production
WORKDIR /app
COPY --from=builder --chown=node:node /app/server.js ./server.js
USER node
EXPOSE 8080
CMD ["node", "server.js"]
