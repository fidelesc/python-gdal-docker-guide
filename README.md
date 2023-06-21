# Geospatial Analysis with Python in Docker

## Short Description

This is a step-by-step guide on how to build a Docker image that has the Geospatial Data Abstraction Library (GDAL) installed, alongside Python libraries like OpenCV and NumPy.

### Description

The process of installing GDAL (Geospatial Data Abstraction Library) can often be a complex and time-consuming task due to its various dependencies and potentially conflicting library versions. To simplify this process and ensure a smooth installation, the approach used in this repository follows a detailed tutorial found on Towards Data Science, titled ["Configuring a Minimal Docker Image for Spatial Analysis with Python"](https://towardsdatascience.com/configuring-a-minimal-docker-image-for-spatial-analysis-with-python-dc9970ca8a8a). This tutorial provides clear steps on setting up a Docker container pre-installed with GDAL, effectively bypassing the usual installation headaches.

To further streamline this process, this repository includes a Dockerfile and requirements.txt, which specify the necessary environment and Python libraries, respectively. To replicate the image setup and save time on manually running each step, a shell script, `generate_image.sh`, has been provided. To use it, navigate to the directory containing the script and execute it with the command `./generate_image.sh`. This script automates the process, building the Docker image as per the instructions in the Dockerfile and requirements.txt, making it significantly easier to reproduce this geospatial analysis environment.

### Step 1: Install Docker
If you're on a Linux system, you can use the `apt` package manager for installation:

```bash
sudo apt-get update
sudo apt-get install docker.io
sudo systemctl start docker
docker run hello-world
```

### Step 2: Use GDAL Base Image

We'll use the OSGeo community's base image from Docker Hub, which already has GDAL pre-installed.

Visit `hub.docker.com/u/osgeo` and select the `gdal` repository. Several versions are available under the "Tags" tab.

Download the image and create a container from it:

```bash
docker pull osgeo/gdal
docker run -it osgeo/gdal
```

After you're "inside" the container, you can check the installed versions of the base packages:

```bash
python
from osgeo import gdal
gdal.__version__
```

### Step 3: Install Additional Packages

In the container, install `pip` and then use it to install additional packages:

```bash
apt-get update
apt-get -y install python3-pip --fix-missing
```

For our purposes, the required packages are:

- numpy=1.21.5
- opencv-python-headless=4.7.0.72

You can install them using pip:

```bash
pip install numpy==1.21.5
pip install opencv-python-headless==4.7.0.72
```

#### Step 3.2: Setup Docker to get latest github code

If you are using this Docker image to process using your own code, you can create a github repo with the code you want to use and do a git clone everytime the image is called.

If you want to ensure that you're using the latest version of the repository every time a container is started, you would need to handle the git clone operation at runtime rather than at build time.

One way to do this is to modify your startup command (CMD in the Dockerfile) or use an entrypoint script that performs the clone operation before starting your application. Here's an example of an entrypoint script:

```
#!/bin/sh

# Clone the latest version of the repository
git clone https://github.com/<username>/<repository>.git /app/<repository>

# Run the application
python /app/<repository>/run.py
```

And in your Dockerfile, you would COPY this script into the image and set it as the entrypoint:

```
FROM python:3.8-slim

RUN apt-get update && \
    apt-get install -y git && \
    apt-get clean

WORKDIR /app

COPY entrypoint.sh /app
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
```

### Step 4: Create a Dockerfile

For reproducibility across different architectures, we'll use a Dockerfile. Create a text file named "Dockerfile" and refer to the existing Dockerfile as an example.

### Step 5: Building the Docker Image

With `requirements.txt` and `Dockerfile` in place, you can build the final image:

```bash
docker build -t geotiff .
```

### Optional Step: Push Image to DockerHub

To push your image to DockerHub, tag it with your repository and use the `docker push` command:

```bash
docker tag geotiff:latest <hub_user>/<hub_repository>:tag
docker push <hub_user>/<hub_repository>:tag
```

Replace `<hub_user>`, `<hub_repository>`, and `tag` with your DockerHub username, repository name, and tag respectively.


### Optional Step: Use Image with  AWS Fargate

To use your Docker image on AWS Fargate, you will first need to push your Docker image to a Docker registry that Fargate can pull from. A common option is to use the Amazon Elastic Container Registry (ECR).

1. **Installing AWS CLI**: The AWS Command Line Interface (CLI) is an open-source tool that enables you to interact with AWS services using commands in your command line shell. Here's a basic installation guide for Ubuntu:

   First, download the AWS CLI installation package:

   ```bash
   curl "https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   ```
   Unzip the downloaded package:

   ```bash
   unzip awscliv2.zip
   ```
   Run the install script:

   ```bash
   sudo ./aws/install
   ```
   To verify the AWS CLI is installed correctly:

   ```bash
   aws --version
   ```
   This should return something like `aws-cli/2.x.x` along with Python and OS version information.

Please refer to the official [AWS documentation](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) for the most accurate and up-to-date information. The exact commands can vary depending on your specific system configuration.


2. **Create a Repository in Amazon ECR**: Go to the ECR console on your AWS account and create a new repository.

2.1 **Sign in to your AWS account**: Open your AWS Management Console and sign in. If you don't already have an AWS account, you'll need to create one and set up your billing information.

2.2. **Navigate to the ECR Console**: On the AWS Management Console, find the "Services" dropdown in the top left corner. Click on it and search for "ECR". Click on the Elastic Container Registry to navigate to the ECR console.

2.3. **Create a new repository**: Once you are in the ECR console, click on the "Repositories" link in the left navigation panel. This will take you to a page with a list of your existing repositories if you have any.

2.4. **Create a new repository**: Click on the "Create repository" button. You will be prompted to enter a name for your new repository. Choose a name that is meaningful to you. This will be part of the repository URI that you will use to push your Docker image.

2.5. **Set up permissions**: You can also choose whether to set up resource-based permissions for your repository. By default, only the account that creates a repository in Amazon ECR can push and pull images. You can modify these permissions to allow other AWS accounts or IAM users to push and pull images.

2.6. **Create the repository**: Once you've chosen a name and set your permissions, click on the "Create repository" button to create your repository.

Your new repository should now appear in your list of repositories in the ECR console. You can select it to view the repository URI, which you will use in your `docker tag` and `docker push` commands to push your Docker image to this repository.


3. **Authenticate Docker to your Amazon ECR Registry**: Use the aws ecr get-login-password command to authenticate Docker to your ECR registry.

```
aws ecr get-login-password --region region | docker login --username AWS --password-stdin <your-account-id>.dkr.ecr.<region>.amazonaws.com
```
Replace <region> with your AWS region, and <your-account-id> with your AWS account ID.

If this is your first time using the AWS CLI it will request you AWS access key and Secret Access Key. You can configure your aws cli with:

```
aws configure
```

If you have an IAM Identity Center login:

```
aws configure sso
SSO session name (Recommended): my-sso
SSO start URL [None]: https://my-sso-portal.awsapps.com/start # You can get your URL at IAM Identity Center (AWS access portal URL)
SSO region [None]: us-east-2 # your region
SSO registration scopes [None]: sso:account:access
```


After setting up your sso connection you will be asked to name your profile, which you then use to authenticate your ecr connection:


```
aws ecr get-login-password --region <aws-region> --profile <my-sso-profile> | docker login --username AWS --password-stdin <account ID>.dkr.ecr.<aws-region>.amazonaws.com

```

You can find more information in the [AWS documentation](https://docs.aws.amazon.com/cli/latest/userguide/sso-configure-profile-token.html)

4. **Tag your Docker Image**: You'll need to tag the Docker image using the URI of the ECR repository you created.

```
docker tag geotiff:latest <your-account-id>.dkr.ecr.<region>.amazonaws.com/<repository-name>:<image tag>
```

Replace <your-account-id> with your AWS account ID, <region> with your AWS region, <repository-name> with the name of your repository, and tag with your preferred tag name.

5. **Push your Docker Image**: You can now push your Docker image to your ECR repository.

```
docker push <your-account-id>.dkr.ecr.<region>.amazonaws.com/<repository-name>:<image tag>
```

Once your image is in ECR, you can configure your task definition in AWS Fargate to use that image. In the task definition, you'll provide the URI of your image in ECR for the "Image" parameter.

Please note that these steps are subject to changes in AWS's interface and CLI, so it's always a good idea to consult the most recent AWS documentation.
