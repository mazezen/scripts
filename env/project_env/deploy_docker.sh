#!/bin/bash

# 检查并卸载已存在的 Docker 和 Docker Compose
echo "Checking for existing Docker installation..."

# 检查是否已安装 Docker
if command -v docker &> /dev/null
then
    echo "Docker is already installed. Uninstalling Docker..."
    sudo apt-get remove -y docker-ce docker-ce-cli containerd.io
    sudo apt-get purge -y docker-ce docker-ce-cli containerd.io
    sudo rm -rf /var/lib/docker
    echo "Docker has been uninstalled."
else
    echo "Docker is not installed."
fi

# 检查是否已安装 Docker Compose
echo "Checking for existing Docker Compose installation..."

if command -v docker-compose &> /dev/null
then
    echo "Docker Compose is already installed. Uninstalling Docker Compose..."
    sudo rm -f /usr/local/bin/docker-compose
    echo "Docker Compose has been uninstalled."
else
    echo "Docker Compose is not installed."
fi

# 更新系统
echo "Updating system..."
sudo apt update && sudo apt upgrade -y

# 安装 Docker 的依赖项
echo "Installing dependencies..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# 添加 Docker 官方的 GPG 密钥
echo "Adding Docker GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 添加 Docker APT 源
echo "Adding Docker APT repository..."
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 更新 APT 包索引
echo "Updating APT package index..."
sudo apt update

# 安装 Docker 引擎
echo "Installing Docker..."
sudo apt install -y docker-ce docker-ce-cli containerd.io

# 启动并启用 Docker 服务
echo "Starting and enabling Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# 验证 Docker 安装
echo "Verifying Docker installation..."
sudo docker --version

# 安装 Docker Compose
echo "Installing Docker Compose..."

# 获取最新版本的 Docker Compose
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)

# 下载 Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# 为 Docker Compose 添加执行权限
sudo chmod +x /usr/local/bin/docker-compose

# 验证 Docker Compose 安装
echo "Verifying Docker Compose installation..."
docker-compose --version

echo "Docker and Docker Compose installation completed successfully!"
