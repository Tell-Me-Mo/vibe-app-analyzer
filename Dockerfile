# Flutter Web Dockerfile
# Stage 1: Build the Flutter web app
FROM ghcr.io/cirruslabs/flutter:stable AS builder

WORKDIR /app

# Copy pubspec files first for better caching
COPY pubspec.yaml pubspec.lock ./

# Get Flutter dependencies
RUN flutter pub get

# Copy only the Flutter source code
COPY lib ./lib
COPY web ./web
COPY assets ./assets
COPY .env ./
COPY analysis_options.yaml ./

# Build the web app with WebAssembly
RUN flutter build web --release --wasm

# Stage 2: Serve the web app with nginx
FROM nginx:alpine

# Install curl for health check
RUN apk add --no-cache curl

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the built web app from builder stage
COPY --from=builder /app/build/web /usr/share/nginx/html

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
