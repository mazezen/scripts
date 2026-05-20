## 方案一:

```shell
# 上传到服务器需要的文件清单
# ┌────────────────────────────┬──────────────────────────────┬────────────────────────────────────────────────────────────────────────────────┐
# │ 文件/目录                   │ 用途                         │ 说明                                                                           │
# ├────────────────────────────┼──────────────────────────────┼────────────────────────────────────────────────────────────────────────────────┤
# │ temp/linux_amd64/main      │ 编译好的二进制程序           │ build-adapter.sh 产出的                                                        │
# │ manifest/docker/Dockerfile │ 构建镜像的脚本               │ 定义如何打包                                                                   │
# │ resource/ 整个目录          │ 资源文件（模板、静态文件等） │ 虽然现在基本都是空 .gitkeep，但 Dockerfile 有 ADD resource，少它镜像构建会失败 │
# └────────────────────────────┴──────────────────────────────┴────────────────────────────────────────────────────────────────────────────────┘
# 在服务器上构建时，目录结构需要是
# project-dir/
# ├── temp/linux_amd64/main
# ├── manifest/docker/Dockerfile
# └── resource/
#     ├── template/
#     ├── public/
#     └── doc/
#
# ============================================================
# docker-run.sh — 编译 → 构建镜像 → 运行容器 一站式脚本

#!/usr/bin/env bash
set -e

echo "开始构建..."
docker build -t demo -f manifest/docker/Dockerfile .
echo "构建结束..."

sleep(1)

docker run  -d --name demo --restart unless-stopped -p "8000:8000"
```

## 方案二:

```markdown
方案：本地打包镜像 → scp → 服务器加载运行

// bash

# 1. 本地：编译 + 构建镜像

./docker-run.sh --no-run

# 2. 本地：把镜像导出成一个 tar 文件

docker save -o demo.tar demo:latest

# 3. 本地：传到服务器

scp demo.tar user@your-server:~/

# 4. 服务器上：加载镜像并运行

docker load -i demo.tar

docker run -d --name demo --restart unless-stopped \
-p 8000:8000 \
demo:latest
```
