# ---------- Stage 1: build the Flutter web app ----------
FROM debian:bookworm-slim AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git unzip xz-utils zip ca-certificates libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 -b stable https://github.com/flutter/flutter.git /flutter \
    && git config --global --add safe.directory /flutter
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"

RUN flutter config --no-analytics && flutter precache --web

WORKDIR /app

COPY pubspec.* ./
RUN flutter pub get

COPY . .
RUN flutter build web --release

# ---------- Stage 2: serve with nginx ----------
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80