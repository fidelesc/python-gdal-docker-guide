# Use an official GDAL image as the base image
FROM osgeo/gdal

# install pip
RUN apt-get update && apt-get -y install python3-pip --fix-missing

# Set the working directory in the container
WORKDIR /app

# Copy the requirements.txt file to the container
COPY requirements.txt /app/

# Install the necessary dependencies
RUN pip install --no-cache-dir -r requirements.txt
