#!/bin/bash
# CentOS / RHEL / Rocky Linux / AlmaLinux / Fedora

set -e  # 脚本出错立即退出

echo "================= 开始安装 Docker & Docker Compose (yum/dnf 版) ================="

# ================= 1. 卸载旧版本 Docker =================
echo "检查并卸载旧版本 Docker..."

sudo yum remove -y docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine \
                  docker-ce \
                  docker-ce-cli \
                  containerd.io \
                  runc || true

sudo dnf remove -y docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine \
                  docker-ce \
                  docker-ce-cli \
                  containerd.io \
                  runc || true

# 清理残留目录
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd

# 卸载旧的 docker-compose（如果是通过 pip 或手动放到 /usr/local/bin 的）
if command -v docker-compose &>/dev/null; then
    echo "卸载旧的 docker-compose..."
    sudo rm -f /usr/local/bin/docker-compose
    sudo rm -f /usr/bin/docker-compose
fi

# ================= 2. 安装 yum/dnf 必要的工具 =================
echo "安装必要工具..."
if command -v dnf &>/dev/null; then
    PKG_MANAGER=dnf
else
    PKG_MANAGER=yum
fi

sudo $PKG_MANAGER install -y yum-utils device-mapper-persistent-data lvm2

# ================= 3. 添加 Docker 官方 yum 源 =================
echo "添加 Docker 官方 yum 仓库..."
sudo $PKG_MANAGER config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# 对于 RHEL 8+/Rocky/AlmaLinux，有时需要把 $releasever 替换为 8 或 9 更稳妥
# 如果上面那条在某些系统报错，可以改用下面这行（取消注释）：
# sudo $PKG_MANAGER config-manager --add-repo https://download.docker.com/linux/centos/8/x86_64/stable/docker-ce.repo

# ================= 4. 更新包索引 =================
sudo $PKG_MANAGER makecache

# ================= 5. 安装最新版 Docker CE =================
echo "安装 Docker CE、CLI 和 containerd..."
sudo $PKG_MANAGER install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# ================= 6. 启动并设置开机自启 =================
echo "启动 Docker 服务..."
sudo systemctl enable --now docker

# ================= 7. 把当前用户加入 docker 组（可选，避免每次 sudo）================
echo "把当前用户加入 docker 组..."
sudo usermod -aG docker $USER
echo "已加入 docker 组，请重新登录或执行 newgrp docker 使之生效"

# ================= 8. 验证 Docker 安装 =================
echo "验证 Docker 安装..."
docker version
sudo docker run --rm hello-world | cat

# ================= 9. 安装独立版 Docker Compose（v2） =================
# 注意：上面安装的 docker-ce 已经自带 docker compose 插件（docker compose，不带-），
# 但很多老项目仍然习惯使用 docker-compose（带-）命令，这里再装一个独立二进制版作为兼容

echo "安装独立版 docker-compose（兼容旧项目）..."

# 获取最新版本号
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -oP '(?<="tag_name": ")[^"]*')

sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
     -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

# ================= 10. 验证 docker-compose =================
echo "验证 docker-compose 安装..."
docker-compose --version

echo "=================================================================="
echo "Docker 及 Docker Compose 安装完成！"
echo "推荐重启终端或执行：newgrp docker 使无 sudo 权限生效"
echo "现在你可以使用以下两种方式调用 Compose："
echo "   docker compose up        # 官方推荐（插件方式）"
echo "   docker-compose up        # 传统独立二进制方式"
echo "=================================================================="