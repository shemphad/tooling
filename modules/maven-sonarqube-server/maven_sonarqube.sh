#!/bin/bash

#Installing kubectl client
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.27.12/2024-04-19/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH


# Update the package repository and install necessary dependencies
sudo apt update -y
sudo apt install -y wget unzip

#Installing aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install Amazon Corretto 17 (Java 17)
sudo apt install openjdk-17-jdk -y

# Install Maven 3.9.9
LATEST_MAVEN_VERSION=3.9.9
wget https://dlcdn.apache.org/maven/maven-3/${LATEST_MAVEN_VERSION}/binaries/apache-maven-${LATEST_MAVEN_VERSION}-bin.zip
unzip -o apache-maven-${LATEST_MAVEN_VERSION}-bin.zip -d /opt
sudo ln -sfn /opt/apache-maven-${LATEST_MAVEN_VERSION} /opt/maven

# Set up Maven environment variables globally
echo 'export M2_HOME=/opt/maven' | sudo tee -a /etc/profile.d/maven.sh
echo 'export PATH=$M2_HOME/bin:$PATH' | sudo tee -a /etc/profile.d/maven.sh

# Add environment variables for root user
echo 'export M2_HOME=/opt/maven' | sudo tee -a /root/.bashrc
echo 'export PATH=$M2_HOME/bin:$PATH' | sudo tee -a /root/.bashrc

# Source the profile script to load the new environment variables
source /etc/profile.d/maven.sh

# Verify Maven installation
echo "Verifying Maven installation..."
/opt/maven/bin/mvn -version

# Download and install SonarQube 10.5.1.90531
# Install Maven 3.9.6
# Download and install SonarQube 10.5.1.90531
SONARQUBE_VERSION=10.5.1.90531
sudo apt install unzip -y
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip
if [ $? -ne 0 ]; then
    echo "Failed to download SonarQube. Exiting."
    exit 1
fi

unzip -o sonarqube-${SONARQUBE_VERSION}.zip -d /opt
sudo mv /opt/sonarqube-${SONARQUBE_VERSION} /opt/sonarqube

# Ensure the binaries have executable permissions
sudo chmod +x /opt/maven/bin/mvn
sudo chmod +x /opt/sonarqube/bin/linux-x86-64/sonar.sh

# Create sonarqube group and user if not exists
if ! getent group ddsonar > /dev/null; then
    sudo groupadd ddsonar
fi

if ! id -u ddsonar > /dev/null 2>&1; then
    sudo useradd -g ddsonar ddsonar
fi

sudo chown -R ddsonar:ddsonar /opt/sonarqube

# Install and use PostgreSQL


# Install PostgreSQL repository
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Install PostgreSQL
sudo apt update -y
sudo apt install postgresql postgresql-contrib -y

# Initialize the PostgreSQL database
sudo postgresql-setup initdb

# Enable and start PostgreSQL service
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Set PostgreSQL to start on boot
sudo systemctl enable postgresql

# Verify PostgreSQL service status
sudo systemctl status postgresql

echo "PostgreSQL installation and setup completed."

#Create a database user named ddsonar.
sudo -i -u postgres
createuser ddsonar
psql
ALTER USER ddsonar WITH ENCRYPTED password 'Team@123';
CREATE DATABASE ddsonarqube OWNER ddsonar;
GRANT ALL PRIVILEGES ON DATABASE ddsonarqube to ddsonar;
\q
Exit

# # Configure SonarQube to use PostgreSQL
# sudo bash -c "cat <<EOF > /opt/sonarqube/conf/sonar.properties
# sonar.jdbc.username=ddsonar
# sonar.jdbc.password=Team@123
# sonar.jdbc.url=jdbc:postgresql://localhost:5432/ddsonarqube
# EOF"

# Set up SonarQube as a service
echo -e "[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Description=SonarQube service
After=syslog.target network.target
[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=ddsonar
Group=ddsonar
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/sonar.service

# Reload systemd and start SonarQube service
sudo systemctl daemon-reload
sudo systemctl enable sonar.service
sudo systemctl start sonar.service

# Check the status of the SonarQube service
sudo systemctl status sonar.service



# Update the system
sudo apt update && sudo apt upgrade -y

# Install Nginx
sudo apt install nginx -y

# Adjust the firewall to allow HTTPS traffic
sudo ufw allow 'Nginx Full'

# Install Certbot and Nginx plugin for Let's Encrypt
sudo apt install certbot python3-certbot-nginx -y

# Create an Nginx configuration for sonarqube reverse proxy
sudo tee /etc/nginx/sites-available/sonarqube.conf > /dev/null <<EOL
server {
    listen 80;
    server_name sonarqube.dominionsystem.org;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

# Enable the sonarqube Nginx configuration
sudo ln -s /etc/nginx/sites-available/sonarqube.conf /etc/nginx/sites-enabled/

# Test Nginx configuration
sudo nginx -t

# Reload Nginx to apply changes
sudo systemctl reload nginx

# Obtain an SSL certificate using Certbot and configure Nginx
sudo certbot --nginx -d sonarqube.dominionsystem.org --email fusisoft@gmail.com --non-interactive --agree-tos --redirect

# Setup a cron job to automatically renew the certificate
echo "0 0 * * * /usr/bin/certbot renew --quiet" | sudo tee -a /etc/crontab > /dev/null

# Restart Nginx to apply SSL configuration
sudo systemctl restart nginx

echo "sonarqube is now accessible via https://sonarqube.dominionsystem.org"




# Update existing package list
sudo apt update -y

# Install prerequisite packages for Docker
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    gnupg \
    lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the stable Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the package list to include Docker packages
sudo apt update -y

# Install Docker Engine
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Enable Docker to start on boot
sudo systemctl enable docker

# Start Docker service
sudo systemctl start docker

# Verify Docker installation
sudo docker --version

# Optional: Add the current user to the 'docker' group to avoid using 'sudo' for Docker commands
sudo usermod -aG docker $USER

echo "Docker installation completed successfully."
echo "Please log out and log back in to apply group changes."


