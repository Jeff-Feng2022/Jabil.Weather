# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy project files and restore as distinct layers
COPY *.sln .
COPY ["Jabil.Weather/Jabil.Weather.csproj", "Jabil.Weather/"]
RUN dotnet restore "Jabil.Weather/Jabil.Weather.csproj"

# Copy everything else and build
COPY . .
WORKDIR "/src/Jabil.Weather"
RUN dotnet build "Jabil.Weather.csproj" -c Release -o /app/build

# Stage 2: Publish
FROM build AS publish
RUN dotnet publish "Jabil.Weather.csproj" -c Release -o /app/publish

# Stage 3: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Enable globalization and invariant mode (optional)
# ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

EXPOSE 9527

COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Jabil.Weather.dll"]