FROM rust:1.82 as builder

WORKDIR /usr/src/login-service
COPY . .

RUN cargo install --path .

FROM debian:bookworm-slim

RUN rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/local/cargo/bin/login-service /usr/local/bin/login-service

CMD ["login-service"]
