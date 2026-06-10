# GitHub Actions CI/CD Setup for Docker Images

This directory contains GitHub Actions workflows for building and pushing Docker images to Docker Hub.

## Setup Instructions

### Prerequisites

1. **Docker Hub Account**: Create an account at https://hub.docker.com if you don't have one
2. **Docker Username**: Your Docker Hub username (e.g., `eowyn`)
3. **Docker Personal Access Token**: Create at https://hub.docker.com/settings/security
   - Click "New Access Token"
   - Name it: `github-actions` or similar
   - Select "Read, Write" permissions
   - Copy the token

### Configure GitHub Secrets

For each repository (debian-ecflow, alpine-ecflow), add these secrets:

1. Go to repository **Settings** → **Secrets and variables** → **Actions**
2. Add new secret `DOCKER_USERNAME` = your Docker Hub username
3. Add new secret `DOCKER_PASSWORD` = your Docker Hub personal access token

### Workflow Triggers

The workflows are triggered by:

1. **Push events** to `master` or `develop` branches
2. **Changes to Dockerfile/Makefile** 
3. **Weekly schedule** - Monday 00:00 UTC (keeps images fresh)
4. **Manual trigger** - Via `workflow_dispatch` with optional tag override

### Manual Build

To manually trigger a build with custom tag:

1. Go to **Actions** tab in GitHub
2. Select **Build and Push Docker Image**
3. Click **Run workflow**
4. (Optional) Enter custom tag like `5.16.0-custom`
5. Click **Run workflow**

### Monitor Builds

- Check **Actions** tab to monitor workflow execution
- View logs by clicking on workflow run
- Docker Hub repository will show new tags after successful push

### Verify in Docker Hub

After successful workflow:
1. Go to https://hub.docker.com/r/eowyn/alpine-ecflow (replace `eowyn` with your username)
2. Check **Tags** tab for new image versions
3. Check **Build History** tab for build logs

## Environment Variables

The workflows extract the ecFlow version from the Dockerfile. Version format: `5.XX.Y`

Override the tag in manual workflow dispatch if extraction fails.

## Troubleshooting

### Build Fails
- Check workflow logs for specific error
- Verify Docker credentials are correct
- Ensure Dockerfile is valid (test locally first)

### Image Not Pushed
- Check Docker Hub credentials in GitHub Secrets
- Verify Docker Hub repository exists and you have push permission
- Check disk space and network in workflow logs

### Cannot Find Image on Docker Hub
- Verify username in repository name matches Docker Hub username
- Wait a few moments for Docker Hub to refresh
- Clear browser cache

## Docker Usage Examples

```bash
# List available tags
docker search eowyn/alpine-ecflow

# Pull latest version
docker pull eowyn/alpine-ecflow:latest

# Run with specific version
docker pull eowyn/alpine-ecflow:5.16.0
docker run --net=host -ti eowyn/alpine-ecflow:5.16.0 bash

# Use in docker-compose
services:
  ecflow-server:
    image: eowyn/alpine-ecflow:latest
    ports:
      - "3141:3141"
    network_mode: "host"
```

## References

- GitHub Actions Documentation: https://docs.github.com/actions
- Docker Hub Documentation: https://docs.docker.com/docker-hub/
- ECMWF ecFlow: https://confluence.ecmwf.int/display/ECFLOW/Documentation
