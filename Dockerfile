ARG RUNTIME_IMAGE_TAG=4.7.2

FROM microsoft/dotnet-framework:4.7.2-sdk AS build
WORKDIR /app

# copy csproj and restore as distinct layers
COPY aspnetapp-sample/*.sln .
COPY aspnetapp-sample/aspnetapp/*.csproj ./aspnetapp/
COPY aspnetapp-sample/aspnetapp/*.config ./aspnetapp/
RUN nuget restore

# copy everything else and build app
COPY aspnetapp-sample/aspnetapp/. ./aspnetapp/
WORKDIR /app/aspnetapp
RUN msbuild /p:Configuration=Release

# copy binaries to target runtime image
FROM microsoft/aspnet:${RUNTIME_IMAGE_TAG} AS runtime
COPY --from=build /app/aspnetapp/ /inetpub/wwwroot/
