#!/usr/bin/env bash
set -e
# 用法:
#   ./docker_run.sh                      # 默认构建并启动
#   ./docker_run.sh --no-run             # 仅构建镜像，不启动容器
#   IMAGE_NAME=myapp ./docker_run.sh     # 自定义镜像名
#   TAG=v1.0 ./docker_run.sh             # 自定义版本标签
#   ./docker_run.sh --env-file .env      # 加载环境变量文件传递给容器
#   ./docker_run.sh --help               # 查看帮助
# ============================================================

# ---- 默认值 ----
APP_NAME="${APP_NAME:-demo}"
IMAGE_NAME="${IMAGE_NAME:-${APP_NAME}}"
TAG="${TAG:-latest}"
FULL_IMAGE="${IMAGE_NAME}:${TAG}"
HOST_PORT="${PORT:-9010}"
RUN_CONTAINER=true
ENV_FILE=""

# ---- 前置检查 ----
command -v docker >/dev/null 2>&1 || {
  echo "错误: 未找到 docker 命令，请先安装 Docker"
  exit 1
}

# ---- 解析参数 ----
while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-run)
      RUN_CONTAINER=false
      shift
      ;;
    --env-file)
      ENV_FILE="$2"
      shift 2
      ;;
    --help|-h)
      echo "用法: $0 [选项]"
      echo ""
      echo "选项:"
      echo "  --no-run             仅构建镜像，不启动容器"
      echo "  --env-file <file>    加载 .env 文件传递环境变量给容器"
      echo "  --help, -h           显示帮助"
      echo ""
      echo "环境变量:"
      echo "  APP_NAME    应用名称，也作为容器名和二进制文件名 (默认: demo)"
      echo "  IMAGE_NAME  镜像名称 (默认: \$APP_NAME)"
      echo "  TAG         镜像标签 (默认: latest)"
      echo "  PORT        宿主机端口映射 (默认: 9010)"
      exit 0
      ;;
    *)
      echo "未知参数: $1"
      echo "用法: $0 [--no-run] [--env-file <file>] [--help]"
      exit 1
      ;;
  esac
done

# ---- 1. 编译 ----
echo "========================================"
echo "  Step 1/3: 编译二进制文件"
echo "========================================"
if [ ! -f "build-adapter.sh" ]; then
  echo "错误: 未找到 build-adapter.sh，请在项目根目录执行此脚本"
  exit 1
fi

APP_NAME="${APP_NAME}" bash build-adapter.sh

# ---- 2. 构建 Docker 镜像 ----
echo ""
echo "========================================"
echo "  Step 2/3: 构建 Docker 镜像"
echo "  Image: ${FULL_IMAGE}"
echo "========================================"

# 将 UPX 压缩后的二进制覆盖到 Dockerfile 期望的路径
# 这样 Docker 镜像也能使用压缩后的二进制，大幅减小镜像体积
cp -f "${APP_NAME}" temp/linux_amd64/main

docker build -t "${FULL_IMAGE}" -f manifest/docker/Dockerfile .
echo ""
echo "✅ 镜像构建完成: ${FULL_IMAGE}"
docker image ls "${FULL_IMAGE}"

# ---- 3. 运行容器 ----
if [ "$RUN_CONTAINER" = false ]; then
  echo ""
  echo "跳过容器启动 (--no-run)"
  echo "你可以稍后手动运行:"
  echo "  docker run -d --name ${APP_NAME} -p ${HOST_PORT}:9010 ${FULL_IMAGE}"
  exit 0
fi

# 停止并删除同名旧容器（如果存在）
if docker ps -a --format '{{.Names}}' | grep -q "^${APP_NAME}$"; then
  echo ""
  echo "发现旧容器 ${APP_NAME}，正在停止并删除..."
  docker stop "${APP_NAME}" 2>/dev/null || true
  docker rm "${APP_NAME}" 2>/dev/null || true
fi

echo ""
echo "========================================"
echo "  Step 3/3: 启动容器"
echo "  端口映射: ${HOST_PORT}:9010"
echo "========================================"

DOCKER_RUN_ARGS=(
  -d
  --name "${APP_NAME}"
  --restart unless-stopped
  -p "${HOST_PORT}:9010"
)

# 使用 Docker 原生的 --env-file 支持，安全可靠
if [ -n "$ENV_FILE" ]; then
  if [ ! -f "$ENV_FILE" ]; then
    echo "警告: 未找到 .env 文件: ${ENV_FILE}，跳过"
  else
    DOCKER_RUN_ARGS+=(--env-file "$ENV_FILE")
  fi
fi

DOCKER_RUN_ARGS+=("${FULL_IMAGE}")

CONTAINER_ID=$(docker run "${DOCKER_RUN_ARGS[@]}")
echo ""
echo "✅ 容器已启动!"
echo "  容器 ID: ${CONTAINER_ID:0:12}"
echo "  容器名称: ${APP_NAME}"
echo "  访问地址: http://localhost:${HOST_PORT}"
echo ""
echo "常用命令:"
echo "  查看日志:  docker logs -f ${APP_NAME}"
echo "  停止容器:  docker stop ${APP_NAME}"
echo "  启动容器:  docker start ${APP_NAME}"
echo "  进入容器:  docker exec -it ${APP_NAME} sh"
