#!/bin/bash

# ================================================
# 脚本名称: count_occurrence_log.sh
# 功能: 使用 awk 统计日志文件中某个特定日志字符串出现的次数，并打印到屏幕
# 用法: ./count_occurrence_log.sh <日志文件路径> <要统计的日志字符串>
# 示例: ./count_occurrence_log.sh /var/log/app.log "ERROR: connection failed"
# ================================================

# 检查参数数量
if [ $# -ne 2 ]; then
    echo "❌ 用法错误！"
    echo "正确用法: $0 <日志文件> <搜索字符串>"
    echo "示例: $0 /path/to/your.log \"[ERROR] something happened\""
    exit 1
fi

LOGFILE="$1"      # 日志文件路径
PATTERN="$2"      # 要统计的日志字符串（支持任意字符串，精确匹配子串）

# 检查文件是否存在
if [ ! -f "$LOGFILE" ]; then
    echo "❌ 错误：日志文件不存在 → $LOGFILE"
    exit 1
fi

# 使用 awk 统计（使用 index 精确匹配子串，避免正则特殊字符问题）
COUNT=$(awk -v pat="$PATTERN" '
{
    if (index($0, pat) > 0) {
        count++
    }
}
END {
    print (count > 0 ? count : 0)
}' "$LOGFILE")

# 输出结果
echo "✅ 统计完成！"
echo "日志文件: $LOGFILE"
echo "搜索字符串: \"$PATTERN\""
echo "出现次数: $COUNT 次"
