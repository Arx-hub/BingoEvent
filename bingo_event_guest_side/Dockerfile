# Production stage - serves pre-built web assets
FROM nginx:alpine

# Copy nginx config for SPA routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the pre-built Flutter web app
# Build locally with: flutter build web --release
COPY build/web /usr/share/nginx/html

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]