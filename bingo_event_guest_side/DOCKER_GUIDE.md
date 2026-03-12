# Guest Side - Quick Docker Guide

## Build & Run

```bash
# 1. Build Flutter web version (first time or after code changes)
flutter pub get
flutter build web --release

# 2. Build Docker image
docker compose build

# 3. Start container
docker compose up

# Access at: http://localhost:8081
```

## Stop

```bash
docker compose down
```

## Rebuild & Restart

```bash
flutter build web --release && docker compose build --no-cache && docker compose up
```

## View Logs

```bash
docker compose logs -f
```

## Rebuild Without Cache

```bash
docker compose build --no-cache
docker compose up
```

## Files

- `Dockerfile` - Serves pre-built web assets with Nginx
- `docker-compose.yml` - Container configuration (port 8081)
- `nginx.conf` - Nginx configuration for SPA routing
- `.dockerignore` - Excludes unnecessary files from build context
- `build/web/` - Pre-built Flutter web app (created by flutter build)

For detailed information, see ../DOCKER_SETUP.md
