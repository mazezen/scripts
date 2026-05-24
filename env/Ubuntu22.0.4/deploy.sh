#!/bin/bash
set -e

echo "=== 开始部署 Nginx 服务 ==="

# 使用官方推荐的新命令
docker compose pull
docker compose up -d --force-recreate

echo "=== 部署完成！ ==="
echo "当前运行的容器："
docker compose ps


# ----------------------------------------------------------------------------------------------------------------
# 如果出现如下错误: 
#   failed to prepare extraction snapshot "extract-975199082-OrXT sha256:219a998c60509502b47b97f1158067d5dd62640d2d689560d32cfd5594f6bc40": failed to open database file: open /var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/metadata.db: no such file or directory
# 这是 containerd 存储数据库损坏或未正确初始化的常见错误，尤其在 Docker 刚安装完就拉镜像时容易出现.
# # 1. 停止 Docker 和 containerd 服务
# sudo systemctl stop docker
# sudo systemctl stop containerd
# 
# 2. 清理损坏的 containerd 存储（安全操作）
# sudo rm -rf /var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/
#
# 3. 重启 containerd 和 Docker
# sudo systemctl start containerd
# sudo systemctl start docker
# 
# 4. 再次尝试部署
# ----------------------------------------------------------------------------------------------------------------
