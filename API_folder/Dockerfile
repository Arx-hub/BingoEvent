# Build stage
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build

WORKDIR /app

# Copy project file
COPY API_folder.csproj ./

# Restore dependencies
RUN dotnet restore

# Copy the rest of the code
COPY . .

# Build the application
RUN dotnet build -c Release -o /app/build

# Publish the application
RUN dotnet publish -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:9.0

WORKDIR /app

# Create Data directory for database
RUN mkdir -p /app/Data

# Copy the built application
COPY --from=build /app/publish .

# Install wget for healthcheck
RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/*

# Expose port 8080
EXPOSE 8080

# Health check - using wget to verify API is responding
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD wget -q -O- http://localhost:8080/health | grep -q Healthy || exit 1

# Start the application
ENTRYPOINT ["dotnet", "API_folder.dll"]
