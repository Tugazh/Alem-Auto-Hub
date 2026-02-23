# syntax=docker/dockerfile:1

FROM golang:1.24-alpine AS build
WORKDIR /app

RUN apk add --no-cache ca-certificates

COPY go.mod go.sum ./
RUN go mod download

COPY . .

ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64
RUN go build -o server ./cmd/server

FROM alpine:3.19
WORKDIR /app
RUN apk add --no-cache ca-certificates

COPY --from=build /app/server /app/server
COPY --from=build /app/cars.json /app/cars.json
COPY --from=build /app/data /app/data
COPY --from=build /app/migrations /app/migrations

EXPOSE 8080

CMD ["/app/server"]
