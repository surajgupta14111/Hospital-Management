# Multi-stage Dockerfile to build Angular frontend and .NET backend
# Stage 1: build frontend with Node
FROM node:18-bullseye-slim AS node_build
WORKDIR /src/frontend

# Copy frontend sources and install
COPY Frontend/package*.json ./
COPY Frontend/ ./
RUN npm ci --no-audit --no-fund

# Build production frontend into /src/frontend/dist
RUN npm run build -- --configuration production --output-path=dist

# Stage 2: build and publish .NET backend
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy full repository
COPY . ./

# Remove any existing wwwroot in backend and copy frontend build output into backend wwwroot
RUN rm -rf Backend/wwwroot || true
COPY --from=node_build /src/frontend/dist ./Backend/wwwroot

# Publish the backend project (adjust the csproj filename if different)
RUN dotnet publish Backend/YourProject.csproj -c Release -o /app/publish /p:UseAppHost=false

# Stage 3: runtime image
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish ./

# Expose port (adjust if your app uses a different port)
EXPOSE 80

ENTRYPOINT ["dotnet", "YourProject.dll"]
