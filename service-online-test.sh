#!/bin/sh

# 要检测的URL（必须修改为你的 Cloudflare Worker 绑定的自定义域）
URL="https://"

# 最大重试次数（检测失败最多尝试多少次）
MAX_TRIES=5

# 每次检测之间的间隔时间（秒）
SLEEP_SECONDS=60

# 日志文件路径
LOG_FILE="/root/cf_check.log"

# 日志最大大小（10MB），超过后会清空（日志轮转）
MAX_LOG_SIZE=$((10 * 1024 * 1024))  # 10MB

# 日志函数：写入日志并控制日志大小
log() {
    # 如果日志文件存在
    if [ -f "$LOG_FILE" ]; then
        # 获取当前日志文件大小（字节）
        LOG_SIZE=$(wc -c < "$LOG_FILE")
        
        # 如果超过最大限制（10MB）
        if [ "$LOG_SIZE" -ge "$MAX_LOG_SIZE" ]; then
            # 清空日志文件
            : > "$LOG_FILE"
            # 记录日志被清理（轮转）
            echo "$(date '+%Y-%m-%d %H:%M:%S') log rotated (exceeded 10MB)" >> "$LOG_FILE"
        fi
    fi
    
    # 写入当前日志（带时间戳）
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG_FILE"
}

# 初始化计数器
i=1

# 循环检测（最多执行 MAX_TRIES 次）
while [ $i -le $MAX_TRIES ]; do
    # 使用 curl 请求目标URL
    # -f：请求失败返回非0状态
    # -sS：静默但保留错误信息
    # --max-time 10：超时时间10秒
    # 2>/dev/null：忽略错误输出
    RESPONSE=$(curl -fsS --max-time 30 "$URL" 2>/dev/null)

    # 判断返回内容中是否包含 "server":"online"
    if echo "$RESPONSE" | grep -q '"server":"online"'; then
        # 检测成功，记录日志并退出脚本
        log "Check $i: online"
        exit 0
    else
        # 检测失败或没有响应
        log "Check $i: offline or no response"
    fi

    # 计数器 +1
    i=$((i + 1))

    # 等待指定时间后再进行下一次检测
    sleep "$SLEEP_SECONDS"
done

# 如果连续 MAX_TRIES 次检测都失败
# 记录日志并执行重启系统
log "Offline detected $MAX_TRIES times, rebooting system"
reboot