#!/bin/bash

# ================================================
# 脚本名称: retrieve_slow_request.sh
# 功能: 使用 TraceId 精准匹配同一条业务链，
#      统计「从入口(START_KEYWORDS) 到 结束(END_KEYWORDS)」时间间隔 > 自定义秒数的慢请求
# 用法: ./retrieve_slow_request.sh <日志文件> <START_KEYWORDS> <END_KEYWORDS> <慢请求阈值(秒)>
# 示例：
#      ./retrieve_slow_request.sh ./log.log "start keyword" "end keyword" 5
# ================================================

# 检查参数数量
if [ $# -ne 4 ]; then
    echo "❌ 用法错误！"
    echo "正确用法: $0 <日志文件> <START_KEYWORDS> <END_KEYWORDS> <慢请求阈值(秒)>"
    echo ""
    echo "其他示例："
    echo "   $0 ./log.log \"start keyword\" \"start keyword\" 5"
    exit 1
fi

LOG_FILE="$1"
START_KEYWORDS="$2"     # 入口关键词
END_KEYWORDS="$3"       # 结束关键词
THRESHOLD="$4"          # 慢请求阈值（秒），支持任意正整数

# 简单校验阈值必须是数字
if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]]; then
    echo "❌ 错误：第4个参数必须是正整数（秒数）"
    exit 1
fi

# 检查文件是否存在
if [ ! -f "$LOG_FILE" ]; then
    echo "❌ 错误：日志文件不存在 → $LOG_FILE"
    exit 1
fi

echo "🚀 开始检索慢请求（阈值 > ${THRESHOLD}秒）"
echo "日志文件     : $LOG_FILE"
echo "入口关键词   : \"$START_KEYWORDS\""
echo "结束关键词   : \"$END_KEYWORDS\""
echo "慢请求阈值   : ${THRESHOLD} 秒"
echo "**********************************************************************************************************************************"
sleep 2

awk -F'\t' \
-v START_KW="$START_KEYWORDS" \
-v END_KW="$END_KEYWORDS" \
-v THRES="$THRESHOLD" '
BEGIN {
    RED    = "\033[31m"
    GREEN  = "\033[32m"
    YELLOW = "\033[33m"
    GRAY   = "\033[90m"
    RESET  = "\033[0m"

    if (!("TERM" in ENVIRON)) {
        RED=GREEN=YELLOW=GRAY=RESET=""
    }
}

# 每行都检查（使用 index 精确字符串匹配）
{
    # ==================== 入口：匹配 START_KEYWORDS ====================
    if (index($0, START_KW) > 0) {
        if (match($1, /([0-9]{2}):([0-9]{2}):([0-9]{2})/, tm)) {
            hh = tm[1] + 0; mm = tm[2] + 0; ss = tm[3] + 0
            ts = hh*3600 + mm*60 + ss
        } else { ts = 0 }

        if (match($0, /[0-9a-f]{32}/)) {
            trace = substr($0, RSTART, RLENGTH)
            start_ts[trace] = ts
            start_line[trace] = $0
        }
    }

    # ==================== 结束：匹配 END_KEYWORDS ====================
    if (index($0, END_KW) > 0) {
        if (match($1, /([0-9]{2}):([0-9]{2}):([0-9]{2})/, tm)) {
            hh = tm[1] + 0; mm = tm[2] + 0; ss = tm[3] + 0
            ts = hh*3600 + mm*60 + ss
        } else { ts = 0 }

        if (match($0, /[0-9a-f]{32}/)) {
            trace = substr($0, RSTART, RLENGTH)

            if (trace in start_ts && start_ts[trace] > 0) {
                diff = ts - start_ts[trace]

                if (diff > THRES) {
                    print GRAY "----------------------------------------------------------------------------------------------------------------" RESET
                    print RED "⚠️  发现慢请求（入口 → 结束 > " THRES "秒）" RESET
                    print YELLOW "TraceID       : " trace RESET
                    print YELLOW "接口/关键词   : " START_KW RESET
                    print YELLOW "耗时          : " diff " 秒" RESET
                    print GREEN "START 入口    : " start_line[trace] RESET
                    print RED   "END   结束    : " $0 RESET
                    print GRAY "----------------------------------------------------------------------------------------------------------------" RESET
                }

                delete start_ts[trace]
                delete start_line[trace]
            }
        }
    }
}
' "$LOG_FILE"

echo ""
echo "✅ 检索完成！所有 > ${THRESHOLD}秒 的慢请求已高亮显示。"