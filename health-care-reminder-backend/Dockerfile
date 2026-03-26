# Build stage
FROM golang:1.25.4-alpine AS build

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o main ./cmd/main.go


# Run stage
FROM alpine:3.19

WORKDIR /app

RUN adduser -D appuser

COPY --from=build /app/main .

USER appuser

EXPOSE 8080

CMD ["./main"]