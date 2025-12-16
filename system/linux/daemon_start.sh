#!/bin/bash

# 根据提供的容器名,查看容器是否存在.不存在容器不处理
# 存在的容器是否启动 如: 已启动, 不再启动. 未启动, 自动启动
# 加入 Linux 定时任务
# crontab -e
# 0 9 * * * /bin/bash damon_run.sh

CONTAINERS=("jenkins-blueocean" "admiring_lichterman")

LOG_DIR="/var/log/docker"
LOG_FILE="${LOG_DIR}/run-$(date '+%F').log"
mkdir -p "${LOG_DIR}"

log() { echo "[$(date '+%F %T')] $1" | tee -a "${LOG_FILE}"; }

log "------------------------------------------------------------"
log "------------------------------------------------------------"
log "Docker容器自启流程开始"

for CONTAINER in "${CONTAINERS[@]}"; do
	if [[ -n "$(docker ps -a -q -f "name=^${CONTAINER}$")" ]]; then
		echo "${CONTAINER} 容器存在"
		if [[ -n "$(docker ps -q -f "name=^${CONTAINER}$")" ]]; then
			log "${CONTAINER} 容器正在运行中, 无需重启"
			continue
		else 
			log "${CONTAINER} 容器停止状态,需要重启"
			if docker start "${CONTAINER}" >/dev/null 2>&1; then
				log "${CONTAINER} 容器启动成功..."
				continue
			else 
				log "${CONTAINER} 容器启动失败..."
				docker update --restart=unless-stopped "{$CONTAINER}" > /dev/null 2>&1
				log "已开启自动重启策略：$container"
			fi
		fi
		continue
	else 
		echo "${CONTAINER} 容器不存在"
		continue
	fi
done

log "Docker容器自启流程结束"

