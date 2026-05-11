# Production stage - serves pre-built Flutter web app
# Build the Flutter web app locally FIRST, then build this Docker image
# Command: flutter build web --release (run this locally before docker build)
FROM httpd:2.4-alpine

WORKDIR /app

# Copy httpd config for SPA routing
COPY httpd.conf /usr/local/apache2/conf/httpd.conf

# Copy the pre-built Flutter web app
COPY build/web /usr/local/apache2/htdocs/

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Expose port 80
EXPOSE 80

# Start httpd
CMD ["httpd", "-DFOREGROUND"]