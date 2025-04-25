#!/bin/bash
<<<<<<< HEAD

# Update and upgrade the system
echo "Updating system packages..."
sudo apt-get update -y && sudo apt-get upgrade -y

# Remove older versions of Docker if any
echo "Removing older Docker versions if installed..."
sudo apt-get remove -y docker docker-engine docker.io containerd runc

# Install required dependencies
echo "Installing required dependencies..."
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    gnupg \
    lsb-release

# Add Docker's official GPG key
echo "Adding Docker's GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up Docker stable repository
echo "Setting up Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index again
echo "Updating package index..."
sudo apt-get update -y

# Install Docker Engine
echo "Installing Docker Engine..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Verify Docker installation
echo "Verifying Docker installation..."
sudo docker --version

# Enable and start Docker service
echo "Enabling and starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# Add current user to the Docker group
echo "Adding current user to the Docker group..."
sudo usermod -aG docker $USER

echo "Docker installation completed! Please log out and back in or run 'newgrp docker' to apply group changes."
=======
# Install Java
sudo apt-get upgrade -y
sudo apt-get update && apt-get -y install openjdk-17-jdk 

#It seems that the Jenkins GPG key was not added properly. You can add it manually using the following commands:

curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
#Make sure the Jenkins repository is added correctly:

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

#Update your package lists to include the Jenkins repository:
sudo apt-get update -y
sudo apt-get install jenkins -y

# Start Jenkins service
sudo systemctl start jenkins
<<<<<<< HEAD
sudo systemctl enable jenkins
>>>>>>> d58be69 (first commit)
=======
sudo systemctl enable jenkins


# Update the system
sudo apt update && sudo apt upgrade -y

# Install Nginx
sudo apt install nginx -y

# Adjust the firewall to allow HTTPS traffic
sudo ufw allow 'Nginx Full'

# Install Certbot and Nginx plugin for Let's Encrypt
sudo apt install certbot python3-certbot-nginx -y

# Create an Nginx configuration for Jenkins reverse proxy
sudo tee /etc/nginx/sites-available/jenkins.conf > /dev/null <<EOL
server {
    listen 80;
    server_name jenkins.dominionsystem.org;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

# Enable the Jenkins Nginx configuration
sudo ln -s /etc/nginx/sites-available/jenkins.conf /etc/nginx/sites-enabled/

# Test Nginx configuration
sudo nginx -t

# Reload Nginx to apply changes
sudo systemctl reload nginx

# Obtain an SSL certificate using Certbot and configure Nginx
sudo certbot --nginx -d jenkins.dominionsystem.org --email fusisoft@gmail.com --non-interactive --agree-tos --redirect

# Setup a cron job to automatically renew the certificate
echo "0 0 * * * /usr/bin/certbot renew --quiet" | sudo tee -a /etc/crontab > /dev/null

# Restart Nginx to apply SSL configuration
sudo systemctl restart nginx

echo "Jenkins is now accessible via https://jenkins.dominionsystem.org"
>>>>>>> 1de37e6 (tooling first commit)
