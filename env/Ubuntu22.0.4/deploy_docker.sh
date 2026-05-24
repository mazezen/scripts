#!/bin/bash
# Ubuntu 22.04 / 20.04 Docker & Docker Compose 安装脚本
set -e  # 脚本出错立即退出

echo "================= 开始安装 Docker & Docker Compose (Ubuntu 版) ================="

# ================= 1. 卸载旧版本 Docker =================
echo "检查并卸载旧版本 Docker..."
sudo apt-get remove -y docker docker-engine docker.io containerd runc \
                       docker-ce docker-ce-cli || true

# 清理残留目录
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd

# 卸载旧的 docker-compose（如果存在）
if command -v docker-compose &>/dev/null; then
    echo "卸载旧的 docker-compose..."
    sudo rm -f /usr/local/bin/docker-compose
    sudo rm -f /usr/bin/docker-compose
fi

# ================= 2. 安装必要依赖 =================
echo "安装必要工具..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# ================= 3. 添加 Docker 官方 GPG 密钥 =================
echo "添加 Docker 官方 GPG 密钥..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# ================= 4. 添加 Docker 官方 APT 源 =================
echo "添加 Docker 官方仓库..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# ================= 5. 更新包索引并安装 Docker =================
echo "更新软件源并安装 Docker..."
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# ================= 6. 启动并设置开机自启 =================
echo "启动 Docker 服务..."
sudo systemctl enable --now docker

# ================= 7. 把当前用户加入 docker 组 =================
echo "把当前用户加入 docker 组..."
sudo usermod -aG docker $USER
echo "已加入 docker 组，请重新登录或执行 newgrp docker 使之生效"

# ================= 8. 验证 Docker 安装 =================
echo "验证 Docker 安装..."
docker version
sudo docker run --rm hello-world | cat

# ================= 9. 安装独立版 Docker Compose（v2） =================
echo "安装独立版 docker-compose（兼容旧项目）..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -oP '(?<="tag_name": ")[^"]*')

sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
     -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

# ================= 10. 验证 docker-compose =================
echo "验证 docker-compose 安装..."
docker-compose --version

echo "=================================================================="
echo "✅ Docker & Docker Compose 安装完成！（Ubuntu 22.04）"
echo "推荐执行以下命令使 docker 组权限立即生效："
echo "   newgrp docker"
echo ""
echo "现在你可以使用以下两种方式："
echo "   docker compose up     # 官方推荐（插件方式）"
echo "   docker-compose up     # 传统独立二进制方式"
echo "=================================================================="
