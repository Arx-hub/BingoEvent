commands for building and pushing to docker hub:

docker build -t arxie/bingo_api2:latest ./API_folder
docker build -t arxie/bingo_admin2:latest ./bingo_event_administrator_side
docker build -t arxie/bingo_guest2:latest ./bingo_event_guest_side

docker push arxie/bingo_api2:latest
docker push arxie/bingo_admin2:latest
docker push arxie/bingo_guest2:latest

optional for running outside of server:
docker compose up --build