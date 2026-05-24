#!/bin/bash
# Ubuntu 22.04 Docker & Docker Compose 安装脚本（优化版）

set -e

echo "================= 开始安装 Docker & Docker Compose (Ubuntu 22.04) ================="

# ================= 1. 卸载旧版本 =================
echo "卸载旧版本 Docker..."
sudo apt-get remove -y docker docker-engine docker.io containerd runc docker-ce docker-ce-cli || true

sudo rm -rf /var/lib/docker /var/lib/containerd

# 清理旧 docker-compose
sudo rm -f /usr/local/bin/docker-compose /usr/bin/docker-compose

# ================= 2. 安装依赖 =================
echo "安装必要依赖..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# ================= 3. 添加 Docker 官方源 =================
echo "添加 Docker 官方 GPG 密钥和仓库..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# ================= 4. 安装 Docker =================
echo "安装 Docker CE..."
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# ================= 5. 启动 Docker =================
echo "启动 Docker 服务..."
sudo systemctl enable --now docker

# ================= 6. 把当前用户加入 docker 组 =================
echo "把当前用户加入 docker 组..."
if [ "$EUID" -eq 0 ]; then
    echo "⚠️  请使用普通用户身份运行此脚本（不要用 sudo 执行整个脚本）"
    exit 1
fi
sudo usermod -aG docker $USER

# ================= 7. 安装独立版 docker-compose =================
echo "安装独立版 docker-compose v2..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -oP '(?<="tag_name": ")[^"]*')

sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
     -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

# 更新 shell 命令缓存
hash -r

# ================= 8. 验证安装 =================
echo "==================== 验证安装 ===================="
echo "Docker 版本："
docker version | head -n 5

echo "Docker Compose 插件版本："
docker compose version

echo "独立版 docker-compose 版本："
docker-compose --version

echo "=================================================="
echo "✅ 安装完成！"
echo ""
echo "请执行以下命令使权限立即生效："
echo "   newgrp docker"
echo ""
echo "推荐使用以下命令部署："
echo "   docker compose up -d          # 官方推荐"
echo "   docker-compose up -d          # 传统方式"
