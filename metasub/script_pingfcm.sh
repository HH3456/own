#!/system/bin/sh

# 定义 FCM 服务可能使用的关键域名列表
DOMAINS="
mtalk.google.com
alt1-mtalk.google.com
alt2-mtalk.google.com
alt3-mtalk.google.com
alt4-mtalk.google.com
alt5-mtalk.google.com
alt6-mtalk.google.com
alt7-mtalk.google.com
alt8-mtalk.google.com
dl.google.com
dl.l.google.com
"

# 输出标题
echo "--- Firebase Cloud Messaging (FCM) Multi-Domain Ping Test ---"
echo "Testing domains critical for FCM and related services."
echo ""

# 使用printf创建表格的头部
printf "%-35s | %-16s | %s\n" "Domain" "IP Address" "Average Response Time (ms)"
printf "------------------------------------|------------------|---------------------------\n"

# 遍历域名列表
for DOMAIN in $DOMAINS; do
    
    # 执行ping命令：-c 4 (发送4个包), -w 5 (等待5秒超时)
    # 将输出保存到变量
    PING_OUTPUT=$(ping -c 4 -w 5 "$DOMAIN")

    # 初始化变量
    IP_ADDRESS="N/A"
    AVG_LATENCY="Ping Failed/100% loss"

    # 检查ping是否成功
    if [ $? -eq 0 ]; then
        
        # 1. 提取IP地址
        # 示例ping输出: PING domain.com (1.2.3.4) 56(84) bytes of data.
        IP_ADDRESS=$(echo "$PING_OUTPUT" | grep "PING" | head -n 1 | awk -F'[()]' '{print $2}' | sed 's/ //g')

        # 2. 提取平均响应时间 (Avg Latency)
        # 示例ping输出: rtt min/avg/max/mdev = 20.123/21.456/22.789/0.500 ms
        EXTRACTED_LATENCY=$(echo "$PING_OUTPUT" | grep "rtt min/avg/max" | awk -F'/' '{print $5}' | awk '{print $1}')
        
        if [ -n "$EXTRACTED_LATENCY" ]; then
            AVG_LATENCY="${EXTRACTED_LATENCY} ms"
        else
            # 如果ping格式不同但收到了包，标记为N/A
            AVG_LATENCY="N/A (Output Parse Error)"
        fi
    fi
    
    # 3. 打印最终结果到表格
    printf "%-35s | %-16s | %s\n" "$DOMAIN" "$IP_ADDRESS" "$AVG_LATENCY"

done

echo ""
echo "--- Test Complete ---"
