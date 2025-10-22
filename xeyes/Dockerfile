# Stage 1: Build stage
FROM alpine:3.19

# Update package repositories and install x11-apps
RUN apk update && \
    apk add --no-cache xeyes

# Set the entrypoint for the image
ENTRYPOINT ["xeyes"]
