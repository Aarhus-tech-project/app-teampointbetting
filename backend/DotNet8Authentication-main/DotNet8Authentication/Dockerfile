# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# Copy csproj and restore
COPY ["DotNet8Authentication/DotNet8Authentication.csproj", "DotNet8Authentication/"]
RUN dotnet restore "./DotNet8Authentication/DotNet8Authentication.csproj"

# Copy everything and build
COPY . .
WORKDIR "/src/DotNet8Authentication"
RUN dotnet build "./DotNet8Authentication.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Publish
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./DotNet8Authentication.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Install required Linux dependencies
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libssl-dev \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Expose ports
EXPOSE 5000
EXPOSE 5001

# Copy published app
COPY --from=publish /app/publish .

# Run as default root user (no segfault)
ENTRYPOINT ["dotnet", "DotNet8Authentication.dll"]
