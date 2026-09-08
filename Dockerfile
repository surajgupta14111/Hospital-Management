# Multi-stage Dockerfile to build Angular frontend and .NET 10 backend
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

# Clean target wwwroot and copy frontend build output into backend wwwroot
RUN rm -rf Backend/AppointMentBooking/AppointMentBooking/wwwroot || true
COPY --from=node_build /src/frontend/dist ./Backend/AppointMentBooking/AppointMentBooking/wwwroot

# Publish the backend
RUN dotnet publish Backend/AppointMentBooking/AppointMentBooking -c Release -o /app/publish /p:UseAppHost=false

# Stage 3: runtime image
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish ./

# Expose port configured in launchSettings / appsettings
EXPOSE 5032

ENTRYPOINT ["dotnet", "AppointMentBooking.dll"]
