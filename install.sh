#!/bin/bash
# Telegram Proxy 一键管理脚本 (Linux 可用，无 BOM，Unix LF)
# 支持安装 / 卸载 / 查看状态
# 安装时可自定义端口

install_proxy() {
    echo "==========================="
    echo "   安装 Telegram 代理"
    echo "==========================="

    read -p "请输入代理端口 [默认: 443]: " port
    port=${port:-443}

    echo "使用端口: $port"

    apt update -y
    apt install -y docker.io

    docker rm -f tg-proxy >/dev/null 2>&1

    docker run -d --name tg-proxy --restart always         -p ${port}:443         telegrammessenger/proxy:latest

    echo "✅ 代理已安装并运行在端口 ${port}"
    echo "🔗 连接方式：tg://proxy?server=$(curl -s ifconfig.me)&port=${port}&secret=生成的密钥"
}

uninstall_proxy() {
    echo "==========================="
    echo "   卸载 Telegram 代理"
    echo "==========================="
    docker rm -f tg-proxy >/dev/null 2>&1
    echo "✅ 代理已卸载完成。"
}

status_proxy() {
    echo "==========================="
    echo "   查看代理运行状态"
    echo "==========================="
    if docker ps | grep -q tg-proxy; then
        echo "✅ Telegram 代理正在运行"
        docker ps | grep tg-proxy
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

while true; do
    show_menu
done
