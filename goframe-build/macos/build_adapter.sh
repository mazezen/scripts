#!/usr/bin/env bash
# Platform: MacOS
# 脚本说明
# ┌──────┬────────────────────────────────────────┬─────────────────────────────────────────────────────────────────────────────────────────────┐
# │ 步骤 │ 命令                                   │ 作用                                                                                        │
# ├──────┼────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────────┤
# │ 1    │ gf build -a amd64 -s linux -p temp -ew │ GoFrame 官方编译，打包资源+注入版本信息，产出到 temp/linux_amd64/main（与 Dockerfile 对齐） │
# │ 2    │ cp temp/linux_amd64/main demo          │ 复制到根目录并重命名为 demo，方便直接取用                                                   │
# │ 3    │ upx -9 demo                            │ 压缩体积      
set -e

echo "================================================"
echo " goframe 项目打包编译脚本"
echo "================================================"

BuildTime=$(date +'%Y.%m.%d.%H:%M:%S')
APP_NAME="${APP_NAME:-demo}"
buildFileName="${APP_NAME}"

echo "编译时间: ${BuildTime}"

# 1. 使用 gf build 编译
#    -a amd64 -s linux : 交叉编译到 linux/amd64
#    -p temp           : 输出到 temp/ 目录（与 Dockerfile 对齐）
#    -e                : 打包 resource/ 中的静态资源到二进制
#    -w                : 注入编译信息（版本、时间等）
echo "开始编译文件..."
gf build -a amd64 -s linux -p temp -ew

# 2. gf build 产出路径: temp/linux_amd64/main
#    将其复制到项目根目录并重命名
BINARY_SRC="temp/linux_amd64/main"
if [ ! -f "$BINARY_SRC" ]; then
    echo "错误: 未找到编译产物 ${BINARY_SRC}"
    ls -la temp/linux_amd64/ 2>/dev/null || echo "temp/linux_amd64/ 目录不存在"
    exit 1
fi

cp "$BINARY_SRC" "$buildFileName"
echo "编译完成, 编译时间 ${BuildTime}"

# 3. UPX 压缩
echo "开始压缩文件..."
upx -9 "$buildFileName"
echo "完成压缩"

ls -lh "$buildFileName"
echo "================================================"
echo " 编译产物: ${buildFileName}"
echo " 原始产物: ${BINARY_SRC}（供 Dockerfile 使用）"
echo "================================================"
