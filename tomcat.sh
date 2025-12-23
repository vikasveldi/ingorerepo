#!/bin/bash

# Define Variables
TOMCAT_VERSION="10.1.34"
TOMCAT_MAJOR_VERSION="v10.1.34"
INSTALL_DIR="/opt/tomcat"

# 1. Update and Install Java (Prerequisite)
sudo apt update && sudo apt install -y default-jdk

# 2. Create a dedicated Tomcat user
sudo useradd -r -m -U -d $INSTALL_DIR -s /bin/false tomcat

# 3. Download and Extract Tomcat
cd /tmp
wget downloads.apache.org{TOMCAT_MAJOR_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz
sudo tar xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz -C $INSTALL_DIR --strip-components=1

# 4. Set Permissions
sudo chown -R tomcat:tomcat $INSTALL_DIR
sudo chmod +x $INSTALL_DIR/bin/*.sh

# 5. Create Systemd Service File
cat <<EOF | sudo tee /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking
User=tomcat
Group=tomcat
Environment="JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")"
Environment="CATALINA_HOME=$INSTALL_DIR"
Environment="CATALINA_BASE=$INSTALL_DIR"
ExecStart=$INSTALL_DIR/bin/startup.sh
ExecStop=$INSTALL_DIR/bin/shutdown.sh

[Install]
WantedBy=multi-user.target
EOF

# 6. Start and Enable Tomcat
sudo systemctl daemon-reload
sudo systemctl start tomcat
sudo systemctl enable tomcat

echo "Tomcat installation complete. Access it at http://localhost:8080"

