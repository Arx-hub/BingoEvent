# Builder stage - compile Flutter web app
FROM ubuntu:latest AS builder

WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa && \
    rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /flutter -b stable && \
    export PATH="/flutter/bin:$PATH" && \
    flutter precache

# Copy the Flutter project
COPY . .

# Set Flutter path and build
ENV PATH="/flutter/bin:$PATH"
RUN flutter pub get && \
    flutter build web --release

# Production stage - serves pre-built web assets
FROM nginx:alpine

# Copy nginx config for SPA routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the built Flutter web app from builder stage
COPY --from=builder /app/build/web /usr/share/nginx/html

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]