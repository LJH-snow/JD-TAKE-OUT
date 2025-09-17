# syntax=docker/dockerfile:1

FROM golang:1.25-alpine AS builder
WORKDIR /app

# 先拉依赖
COPY backend/go.mod backend/go.sum ./backend/
RUN cd backend && go mod download

# 拷贝源码并构建
COPY backend ./backend
RUN cd backend && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /out/server ./cmd/main.go

FROM alpine:3.20
WORKDIR /app

# 可执行文件与配置目录
COPY --from=builder /out/server /app/server
COPY --from=builder /app/backend/configs /app/configs

EXPOSE 8090

# 默认环境变量，可被 docker-compose 覆盖
ENV SERVER_MODE=release \
    SERVER_PORT=8090 \
    DATABASE_HOST=postgres \
    DATABASE_PORT=5432 \
    DATABASE_USER=user_pgsql \
    DATABASE_PASSWORD=password_ZKnm32 \
    DATABASE_DBNAME=jd_take_out \
    DATABASE_SSLMODE=disable

CMD ["/app/server"]


