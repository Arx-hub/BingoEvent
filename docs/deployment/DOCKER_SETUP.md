# Docker Setup Guide - Bingo Event

This guide explains how to run both the Guest Side and Administrator Side applications using Docker containers.

## Prerequisites

- Docker installed (version 20.10+)
- Docker Compose installed (v2.x)
- Flutter SDK installed locally (for building the web apps)

## Architecture

The project runs two separate Docker containers:

1. **Guest Side** - Runs on port **8081**
   - Guest-facing Bingo game interface
   - Located in: `bingo_event_guest_side/`

2. **Administrator Side** - Runs on port **8082**  
   - Admin interface for managing the Bingo event
   - Located in: `bingo_event_administrator_side/`

Both containers serve static Web assets (HTML, CSS, JS) via Nginx.

## Quick Start

### 1. Build Web Assets (First Time Only)

Before running Docker, you need to build the Flutter web versions locally:

```bash
# Build guest side
cd bingo_event_guest_side
flutter pub get
flutter build web --release
cd ..

# Build admin side
cd bingo_event_administrator_side
flutter pub get
flutter build web --release
cd ..
```

### 2. Start Both Containers

**Option A: Start each in separate terminals**

Terminal 1 - Guest Side:
```bash
cd bingo_event_guest_side
docker compose up
# Access at: http://localhost:8081
```

Terminal 2 - Admin Side:
```bash
cd bingo_event_administrator_side
docker compose up
# Access at: http://localhost:8082
```

**Option B: Start both in background**

```bash
cd bingo_event_guest_side && docker compose up -d
cd ../bingo_event_administrator_side && docker compose up -d

# Check status
docker ps
```

### 3. Stop Containers

```bash
# Stop guest side
cd bingo_event_guest_side
docker compose down

# Stop admin side
cd bingo_event_administrator_side
docker compose down

# Or stop all containers
docker compose down  # Run from any project directory
```

## Available Ports

| Service | Port | URL |
|---------|------|-----|
| Guest Side | 8081 | http://localhost:8081 |
| Admin Side | 8082 | http://localhost:8082 |

## Docker Configuration Details

### Each Container Configuration

**Container Name:**
- Guest: `bingo_guest_container`
- Admin: `bingo_admin_container`

**Image Name:**
- Guest: `bingo_event_guest_side-bingo-guest`
- Admin: `bingo_event_administrator_side-bingo-admin`

### Dockerfile

The Dockerfile uses a two-stage approach:

1. **Assumes pre-built web assets** from `build/web/` directory
2. **Serves with Nginx** (lightweight Alpine Linux base image)
3. **Includes health checks** to monitor container health

### Nginx Configuration

Both containers use `nginx.conf` for:
- SPA (Single Page Application) routing
- Gzip compression for assets
- Proper caching headers
- Asset optimization

## Development Workflow

### When Modifying Code

1. **Stop the containers:**
   ```bash
   docker compose down
   ```

2. **Rebuild the web app locally:**
   ```bash
   flutter build web --release
   ```

3. **Rebuild and start the container:**
   ```bash
   docker compose up --build
   ```

### Quick Development (Without Docker)

For faster iteration during development, you can run Flutter's dev server directly:

```bash
flutter run -d web
```

Then use Docker only for production/staging deployments.

## Troubleshooting

### Container fails to start

Check logs:
```bash
# Guest side
cd bingo_event_guest_side
docker compose logs

# Admin side
cd bingo_event_administrator_side
docker compose logs
```

### Port already in use

If port 8081 or 8082 is already in use, edit `docker-compose.yml`:

```yaml
ports:
  - "8081:80"  # Change first number to use different port
```

### Web app shows blank page

1. Ensure `build/web/` directory exists
2. Rebuild: `flutter build web --release`
3. Rebuild Docker image: `docker compose build --no-cache`
4. Restart container: `docker compose up`

### Changes not reflected in container

1. Stop container: `docker compose down`
2. Rebuild web app: `flutter build web --release`
3. Rebuild Docker image: `docker compose build --no-cache`
4. Start container: `docker compose up`

## Production Deployment

For production:

1. Build web apps: `flutter build web --release`
2. Build Docker images: `docker compose build`
3. Push to container registry
4. Deploy using orchestration tool (Kubernetes, Docker Swarm, etc.)

### Environment Variables (if needed)

Create `.env` file in each project directory and update `docker-compose.yml` to use them:

```yaml
environment:
  - BASE_URL=${BASE_URL:-http://localhost:8081}
```

## Monitoring & Health Checks

Containers include health checks that:
- Run every 30 seconds
- Check Nginx is responding on port 80
- Mark container as unhealthy after 3 failed checks
- Wait 5 seconds before starting health checks

Check health status:
```bash
docker ps -a
# Look at STATUS column for "(healthy)" or "(unhealthy)"
```

## File Structure

```
BingoEvent/
├── bingo_event_guest_side/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── nginx.conf
│   ├── .dockerignore
│   ├── pubspec.yaml
│   ├── build/web/          # Pre-built web assets
│   └── lib/
│
├── bingo_event_administrator_side/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── nginx.conf
│   ├── .dockerignore
│   ├── pubspec.yaml
│   ├── build/web/          # Pre-built web assets
│   └── lib/
```

## Additional Commands

### View running containers

```bash
docker ps -a
docker stats  # View resource usage
```

### View container logs

```bash
docker logs -f bingo_guest_container
docker logs -f bingo_admin_container
```

### Remove images

```bash
docker rmi bingo_event_guest_side-bingo-guest:latest
docker rmi bingo_event_administrator_side-bingo-admin:latest
```

### Clean up images and containers

```bash
docker system prune -a  # Warning: removes all unused images and containers
```

## Supporting Infrastructure

If your project needs a backend API (e.g., the C# API in `API_folder/`), those services can be added to a separate `docker-compose.yml` orchestration file to run everything together.

## Notes

- Web apps are served as static files using Nginx
- For dynamic features, ensure backend APIs are accessible from containers
- Container networking allows containers to communicate use service names
- Ports expose services to host machine (localhost)
