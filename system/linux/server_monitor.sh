#!/bin/bash

# 脚本名称: server_monitor.sh
# 描述: 监控服务器CPU和磁盘使用率，如果超过70%，分析导致高负载的进程或文件。
# 假设运行在Linux系统，需要安装bc、top、df、du等命令（通常已安装）。
# 使用方法: ./server_monitor.sh [interval] [filesystem]
#   interval: 检查间隔秒数，默认60秒
#   filesystem: 要监控的文件系统，默认根分区 '/'

INTERVAL=${1:-60}  # 默认间隔60秒
FILESYSTEM=${2:-/} # 默认监控根分区

while true; do
    echo "检查时间: $(date)"

    # 检查CPU使用率
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    CPU_THRESHOLD=70

    if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
        echo "警告: CPU使用率超过${CPU_THRESHOLD}%! 当前: ${CPU_USAGE}%"
        echo "导致高CPU的进程（前5个）:"
        ps -eo pid,ppid,cmd,%cpu --sort=-%cpu | head -n 6
    else
        echo "CPU使用率正常: ${CPU_USAGE}%"
    fi

    # 检查磁盘使用率
    DISK_USAGE=$(df -h "$FILESYSTEM" | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 }' | sed 's/%//g')
    DISK_THRESHOLD=70

    if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
        echo "警告: 磁盘使用率超过${DISK_THRESHOLD}%! 当前: ${DISK_USAGE}%"
        echo "导致高磁盘占用的目录或文件（前10个最大文件/目录，从根分区开始）:"
        du -ah "$FILESYSTEM" | sort -rh | head -n 10
    else
        echo "磁盘使用率正常: ${DISK_USAGE}%"
    fi

    echo "-----------------------------------"
    sleep "$INTERVAL"
done
