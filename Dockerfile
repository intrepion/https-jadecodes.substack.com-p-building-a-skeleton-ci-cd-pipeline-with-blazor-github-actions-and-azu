# Base Image (base):

# This line specifies the base image for the first stage of the build. It's using the official ASP.NET runtime image from Microsoft.
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
# Sets the user to "app" for security reasons, by default docker runs as root user. Setting this means that even if an attacker compromises the application, they are restricted to the permissions of this user rather than the root user.
USER app
# Sets the working directory to /app.
WORKDIR /app
# Exposes ports 8080 and 8081 from the container. Port 8080 is used by default in Azure App Service.
EXPOSE 8080
EXPOSE 8081

# Build Image (build):

# Specifies the base image for the second stage of the build. This image includes the .NET SDK, allowing you to build the application.
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
# Defines a build argument that defaults to "Release". This configuration is intended for deployment to production or testing environments. It produces optimised, smaller, and more efficient executables suitable for production use.
ARG BUILD_CONFIGURATION=Release
# Sets the working directory to /src.
WORKDIR /src
# Copies the project file to the working directory.
COPY ["EduTaskHub.Frontend/EduTaskHub.Frontend.csproj", "EduTaskHub.Frontend/"]
# Restores the NuGet packages that the project needs.
RUN dotnet restore "./EduTaskHub.Frontend/./EduTaskHub.Frontend.csproj"
# Copies the rest of the source code to the working directory.
COPY . .
# Changes the working directory to the specific project folder.
WORKDIR "/src/EduTaskHub.Frontend"
# Builds the application and places the output in the /app/build directory.
RUN dotnet build "./EduTaskHub.Frontend.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Publish Image (publish):

# Specifies that this stage is based on the "build" stage.
FROM build AS publish
# Defines a build argument again.
ARG BUILD_CONFIGURATION=Release
# Publishes the application, producing the final output in the /app/publish directory.
RUN dotnet publish "./EduTaskHub.Frontend.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Final Image (final):

# Specifies that this stage is based on the "base" stage.
FROM base AS final
# Sets the working directory to /app.
WORKDIR /app
# Copies the published application from the "publish" stage to the final image.
COPY --from=publish /app/publish .
# Sets the default command to run when the container starts, which will launch the .NET application.
ENTRYPOINT ["dotnet", "EduTaskHub.Frontend.dll"]
