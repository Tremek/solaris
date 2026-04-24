# Railway-compatible single-Dockerfile build for the solaris client.
# Combines the upstream base (Node build) + client (nginx serve)
# stages so Railway doesn't need a pre-pushed ghcr.io base image.
#
# Build context: repo root.

FROM node:24-slim AS build

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

FROM nginx:1.29.7-alpine AS client

RUN rm /etc/nginx/conf.d/default.conf

COPY docker/prod/client/solaris.conf /etc/nginx/conf.d/solaris.conf

COPY --from=build /solaris/client/dist /usr/share/nginx/html

EXPOSE 8080
