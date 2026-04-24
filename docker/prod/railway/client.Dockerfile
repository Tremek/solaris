# Railway-compatible single-Dockerfile build for the solaris client.
# Combines the upstream base (Node build) + client (nginx serve)
# stages so Railway doesn't need a pre-pushed ghcr.io base image.
#
# Build context: repo root.

FROM node:24-slim AS build

# Vue build-time env. Defaulted to the solaris-beta.tremek.dev
# domains the iOS app's BETA server slot points at. Override with
# Railway build args if the target changes.
ARG VUE_APP_API_HOST=https://api.solaris-beta.tremek.dev
ARG VUE_APP_SOCKETS_HOST=api.solaris-beta.tremek.dev
ENV VUE_APP_API_HOST=$VUE_APP_API_HOST
ENV VUE_APP_SOCKETS_HOST=$VUE_APP_SOCKETS_HOST

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
