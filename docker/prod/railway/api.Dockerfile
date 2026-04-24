# Railway-compatible single-Dockerfile build for the solaris API.
# Combines the upstream base + server-api stages into one so Railway's
# build doesn't need a pre-pushed ghcr.io/solaris-games/solaris-base-prod.
#
# Build context: repo root.

FROM node:24-slim

RUN mkdir /solaris
WORKDIR /solaris

ADD package.json package.json
ADD package-lock.json package-lock.json
ADD client/ client/
ADD common/ common/
ADD server/ server/

RUN rm -f client/.env
RUN rm -f server/.env

RUN npm install
RUN npm run build

WORKDIR /solaris/server

# Railway exposes $PORT — the server reads PORT from env, we just set
# a sensible default matching docker-compose.yml.
ENV PORT=3000
EXPOSE 3000

CMD ["npm", "run", "start-api:prod"]
