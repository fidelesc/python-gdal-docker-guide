#!/bin/bash

# Update the system packages
echo "Updating system packages..."
sudo apt-get update

# Install Docker
echo "Installing Docker..."
sudo apt-get install docker.io

# Start Docker
echo "Starting Docker..."
sudo systemctl start docker

# Pull the GDAL image from Docker Hub
echo "Pulling GDAL image from Docker Hub..."
docker pull osgeo/gdal

# Build the Docker image
echo "Building the Docker image..."
docker build -t geotiff .

# Print success message
echo "Docker image 'geotiff' built successfully."

