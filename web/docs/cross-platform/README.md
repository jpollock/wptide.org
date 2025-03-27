# Cross-Platform Development

This guide provides detailed information for developers working on non-linux/amd64 systems (such as macOS with Apple Silicon/M1/M2) who need to build Docker images that will run in GCP Cloud Run.

## The Challenge

GCP Cloud Run requires containers to be built for the `linux/amd64` platform. However, when building Docker images on systems with different architectures (like Apple Silicon's `arm64`), Docker by default builds for the host architecture. This creates compatibility issues when deploying to Cloud Run.

## Our Solution

The Makefile in this project includes automatic architecture detection and cross-platform build support. This ensures that Docker images built on any system will be compatible with GCP Cloud Run.

## Setting Up Your Environment

Before building Docker images on a non-linux/amd64 system, you should set up the cross-platform build environment:

```bash
make setup.crossplatform
```

This command does two things:
1. Installs QEMU emulation layers for cross-platform emulation
2. Configures Docker buildx for multi-architecture builds

You only need to run this setup once on your system.

If you prefer to set up components individually:

```bash
make setup.qemu    # Install QEMU emulation layers
make setup.buildx  # Configure Docker buildx
```

## How It Works

The Makefile includes architecture detection that automatically applies the appropriate platform flag when needed:

```makefile
# Architecture detection for cross-platform builds
ARCH := $(shell uname -m)
PLATFORM_FLAG := $(if $(filter arm64,$(ARCH)),--platform=linux/amd64,)
```

This means:
- On ARM64 systems (like Apple Silicon), the `--platform=linux/amd64` flag is applied
- On x86_64/amd64 systems, no platform flag is needed

The build commands use Docker buildx with the conditional platform flag:

```makefile
build.lighthouse:
    @docker buildx build $(PLATFORM_FLAG) --no-cache -t gcr.io/${GOOGLE_CLOUD_PROJECT}/lighthouse:${VERSION} -f ./app/docker/Dockerfile.lighthouse ./app --load
```

## Building Images

You can use the standard build commands without any changes to your workflow:

```bash
make build.lighthouse
make build.phpcs
make build.sync
```

The system will automatically detect your architecture and apply the appropriate platform flag when needed.

## Performance Considerations

Cross-architecture builds (building `linux/amd64` images on `arm64` systems) require emulation, which can be slower than native builds. Here are some tips to improve performance:

1. **First Build**: The first cross-platform build will be significantly slower as QEMU sets up the emulation environment.

2. **Use Caching**: Avoid using `--no-cache` for subsequent builds if possible.

3. **Optimize Dockerfiles**: Keep your Dockerfiles efficient with minimal layers and smaller base images.

4. **Consider Cloud Builds**: For very large or complex builds, consider using Google Cloud Build instead of local builds:
   ```bash
   gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/lighthouse:${VERSION} --file=./app/docker/Dockerfile.lighthouse ./app
   ```

## Troubleshooting

### Common Issues

1. **"Unknown platform" error**:
   - Make sure you've run `make setup.crossplatform` first
   - Verify Docker is running and up to date

2. **Very slow builds**:
   - This is normal for cross-platform builds, especially the first time
   - Consider optimizing your Dockerfile or using cloud builds for production

3. **"exec format error" when running containers locally**:
   - This typically means you're trying to run an amd64 container on an arm64 system without proper emulation
   - Make sure QEMU is installed correctly with `make setup.qemu`

4. **"load" command not supported**:
   - Update Docker to the latest version
   - Make sure buildx is properly installed

### Verifying Image Architecture

To verify that your image was built for the correct architecture:

```bash
docker inspect gcr.io/${GOOGLE_CLOUD_PROJECT}/lighthouse:${VERSION} | grep Architecture
```

This should show `"Architecture": "amd64"` even when built on an ARM system.

## Additional Resources

- [Docker Buildx Documentation](https://docs.docker.com/buildx/working-with-buildx/)
- [Multi-platform builds with Docker](https://docs.docker.com/build/building/multi-platform/)
- [QEMU for Docker](https://github.com/tonistiigi/binfmt)
- [GCP Cloud Run Container Requirements](https://cloud.google.com/run/docs/container-contract)
