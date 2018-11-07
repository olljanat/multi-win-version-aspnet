# ASP.NET Docker Sample with support for multiple Windows versions
This sample demonstrates how to use create Docker images which are [compatible](https://docs.microsoft.com/en-us/virtualization/windowscontainers/deploy-containers/version-compatibility) with multiple Windows versions with process isolation mode using native Docker tools.

Solution in briefly:
- [Docker multi-architecture images](https://medium.com/@mauridb/docker-multi-architecture-images-365a44c26be6) are used to handle image selection for target Windows version.
- [Multi-stage builds](https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds) are used to minimize differences between images.
- Newer version of Windows Server can run Dockerfile instructions which does not need start container like **COPY** for older Windows versions too.
- [docker manifest](https://docs.docker.com/edge/engine/reference/commandline/manifest/) command is used to create common manifest for images.
- Sample ASP.NET application from [here](https://github.com/Microsoft/dotnet-framework-docker/tree/master/samples/aspnetapp).
- Using native Docker tools.

Example image is available on [ollijanatuinen/multi-win-version-aspnet](https://hub.docker.com/r/ollijanatuinen/multi-win-version-aspnet/)

You can test it on all supported OS versions (2016, 1709 and 1803) using this command:
```
docker run -t --rm -p 8888:80 ollijanatuinen/multi-win-version-aspnet:1.0
```
and accessing to it using http://servername:8888 after that.

# Build
These build commands are tested with Windows Server, version 1803 which uses process isolation mode.

**NOTE:** You need use unique version tag for each image and you need push them to Docker registry (Docker HUB or private registry) before you can create manifest.


If you try build newer version on older Windows version you will see error like this:
> a Windows version 10.0.16299-based image is incompatible with a 10.0.14393 host

## Build image for Windows Server 2016
Build command on this step will run all Dockerfile instructions and cache them.
```
docker build . --build-arg RUNTIME_IMAGE_TAG=4.7.2-windowsservercore-ltsc2016 -t ollijanatuinen/multi-win-version-aspnet:1.0-ltsc2016
docker push ollijanatuinen/multi-win-version-aspnet:1.0-ltsc2016
```

## Build image for Windows Server, version 1709
Because of most of the commands are stored to docker cache only **FROM** and **COPY** instructions will be rerun for 1709.
```
docker build . --build-arg RUNTIME_IMAGE_TAG=4.7.2-windowsservercore-1709 -t ollijanatuinen/multi-win-version-aspnet:1.0-1709
docker push ollijanatuinen/multi-win-version-aspnet:1.0-1709
```

## Build image for Windows Server, version 1803
Because of most of the commands are stored to docker cache only **FROM** and **COPY** instructions will be rerun for 1803.
```
docker build . --build-arg RUNTIME_IMAGE_TAG=4.7.2-windowsservercore-1803 -t ollijanatuinen/multi-win-version-aspnet:1.0-1803
docker push ollijanatuinen/multi-win-version-aspnet:1.0-1803
```

## Add manifest
Currently *docker manifest* is cli experimental command (PR to remove experimental tag is on [docker/cli#1355](https://github.com/docker/cli/pull/1355)).
To enable cli experimental features you need modify file **$env:userprofile\.docker\config.json** and add this code to it (remember verify that JSON syntax is correct):
```
{
	"experimental": "enabled"
}
```

Then you can add manifest using command:
```
docker manifest create ollijanatuinen/multi-win-version-aspnet:1.0 ollijanatuinen/multi-win-version-aspnet:1.0-ltsc2016 ollijanatuinen/multi-win-version-aspnet:1.0-1709 ollijanatuinen/multi-win-version-aspnet:1.0-1803
docker manifest push ollijanatuinen/multi-win-version-aspnet:1.0
```

## Verify
You can use command: ```docker manifest inspect ollijanatuinen/multi-win-version-aspnet:1.0``` to see created manifest:
```
{
   "schemaVersion": 2,
   "mediaType": "application/vnd.docker.distribution.manifest.list.v2+json",
   "manifests": [
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 3468,
         "digest": "sha256:63dd8a78ceadec8be8e90beeb928462081ec2b81d3dbe184e6131a01b7bb7205",
         "platform": {
            "architecture": "amd64",
            "os": "windows",
            "os.version": "10.0.16299.726"
         }
      },
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 2829,
         "digest": "sha256:6ded117857d750c8930d47511386de3a8542124251d19163157a09e9bedfde59",
         "platform": {
            "architecture": "amd64",
            "os": "windows",
            "os.version": "10.0.17134.345"
         }
      },
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 3469,
         "digest": "sha256:081edad4feb1c0acb25742a95ac0ab89d6526af22027a851bca12f37365a0e0d",
         "platform": {
            "architecture": "amd64",
            "os": "windows",
            "os.version": "10.0.14393.2485"
         }
      }
   ]
}
```