function ??() {
    if [ -z "$1" ]; then echo "Usage: ?? <question>"; return 1; fi
    if command -v glow &> /dev/null; then
        aichat -c /etc/aichat/config.yaml "$*" | glow -
    else
        aichat -c /etc/aichat/config.yaml "$*"
    fi
}
