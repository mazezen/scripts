#!/bin/bash

# 通过关键词搜索同一条业务链的日志,查找慢处理的程序
# 定义关键 START_KEYWORDS END_KEYWORDS
# START_KEYWORDS: 程序搜索开始位
# END_KEYWORDS: 程序搜索结束位


LOG_FILE="xxxx.log"

START_KEYWORDS="api consumer, 监测到交易的转出地址是API的授权地址" # 交易是否存在
END_KEYWORDS="api consumer,检测此交易不存在本地数据库中"


echo "通过日志检索慢程序脚本启动"
echo "**********************************************************************************************************************************"
sleep 1
echo "交易是否存在"
awk -F'\t' \
-v START_KW="$START_KEYWORDS" \
-v END_KW="$END_KEYWORDS" '
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

# START
$0 ~ START_KW {
    split($1, t, /[ :]/)
    start_ts = t[2]*3600 + t[3]*60 + t[4]
    start_line = $0
}

# END
$0 ~ END_KW && start_ts > 0 {
    split($1, t, /[ :]/)
    end_ts = t[2]*3600 + t[3]*60 + t[4]
    diff = end_ts - start_ts

    if (diff > 4) {
        print GRAY  "----------------------------------------------------------------------------------------------------------------" RESET
        print RED "⚠️  发现慢处理" RESET
        printf "%s开始关键词: %s 结束关键词: %s%s\n", YELLOW, START_KW, END_KW, RESET
        print YELLOW "耗时: " diff " 秒" RESET
        print GREEN "START: " start_line RESET
        print RED   "END  : " $0 RESET
        print GRAY  "----------------------------------------------------------------------------------------------------------------" RESET
    }
    start_ts = 0
}
' "$LOG_FILE"
