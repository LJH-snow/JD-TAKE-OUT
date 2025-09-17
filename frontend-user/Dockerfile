# syntax=docker/dockerfile:1

FROM node:20-alpine AS builder
WORKDIR /app

COPY frontend-user/package.json frontend-user/package-lock.json ./frontend-user/
RUN cd frontend-user && npm ci

COPY frontend-user ./frontend-user
RUN cd frontend-user && npm run build

FROM nginx:1.27-alpine
COPY --from=builder /app/frontend-user/dist /usr/share/nginx/html
RUN printf 'server { \
    listen 80; \
    server_name _; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { try_files $uri /index.html; } \
    location /assets/ { try_files $uri =404; } \
}\n' > /etc/nginx/conf.d/default.conf
EXPOSE 80


