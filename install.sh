#!/bin/bash
# Telegram Proxy 一键管理脚本 (增强版)
# 支持安装 / 卸载 / 查看状态
# 安装时可自定义端口，并显示真实代理链接

CONTAINER_NAME="tg-proxy"

install_proxy() {
    echo "==========================="
    echo "   安装 Telegram 代理"
    echo "==========================="

    # 输入端口，默认 443
    read -p "请输入代理端口 [默认: 443]: " PORT
    PORT=${PORT:-443}
    echo "使用端口: $PORT"

    # 安装 Docker
    apt update -y
    apt install -y docker.io

    # 如果已存在旧容器，先移除
    if docker ps -a | grep -q "$CONTAINER_NAME"; then
        docker rm -f "$CONTAINER_NAME"
    fi

    # 生成随机 secret
    SECRET=$(head -c 16 /dev/urandom | xxd -p)

    # 启动 Telegram 官方 mtproto-proxy 容器
    docker run -d --name "$CONTAINER_NAME" --restart always         -p ${PORT}:443         telegrammessenger/proxy:latest -u nobody -p "$SECRET"

    # 获取公网 IP
    SERVER_IP=$(curl -s ifconfig.me)

    echo "✅ 代理已安装并运行在端口 ${PORT}"
    echo "🔗 代理链接（直接可用）："
    echo "tg://proxy?server=${SERVER_IP}&port=${PORT}&secret=${SECRET}"
}

uninstall_proxy() {
    echo "==========================="
    echo "   卸载 Telegram 代理"
    echo "==========================="
    if docker ps -a | grep -q "$CONTAINER_NAME"; then
        docker rm -f "$CONTAINER_NAME"
        echo "✅ 代理已卸载完成。"
    else
        echo "❌ 没有找到正在运行的代理容器。"
    fi
}

status_proxy() {
    echo "==========================="
    echo "   查看代理运行状态"
    echo "==========================="
    if docker ps | grep -q "$CONTAINER_NAME"; then
        echo "✅ Telegram 代理正在运行"
        docker ps | grep "$CONTAINER_NAME"
    else
        echo "❌ Telegram 代理未运行"
    fi
}

show_menu() {
    clear
    echo "==========================="
    echo " Telegram 代理管理脚本"
    echo "==========================="
    echo "1. 安装代理"
    echo "2. 卸载代理"
    echo "3. 查看状态"
    echo "0. 退出"
    echo "==========================="
    read -p "请选择操作 [0-3]: " choice
    case $choice in
        1) install_proxy ;;
        2) uninstall_proxy ;;
        3) status_proxy ;;
        0) exit 0 ;;
        *) echo "❌ 无效选择，请重试。" ; sleep 2 ;;
    esac
}

# 主循环
while true; do
    show_menu
done
