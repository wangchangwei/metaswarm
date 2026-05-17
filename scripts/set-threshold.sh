#!/bin/bash
# set-threshold.sh — Set or show the decision threshold
#
# Usage:
#   ./scripts/set-threshold.sh [value]    # Set threshold
#   ./scripts/set-threshold.sh --show     # Show current threshold
#   ./scripts/set-threshold.sh --reset    # Reset to default (8.0)
#
# Examples:
#   ./scripts/set-threshold.sh 9.0
#   ./scripts/set-threshold.sh --show
#   ./scripts/set-threshold.sh --reset

CONFIG_FILE=".metaswarm/config.yaml"
DEFAULT_THRESHOLD=8.0

show_threshold() {
    if [[ -f "$CONFIG_FILE" ]]; then
        local threshold=$(grep "^  threshold:" "$CONFIG_FILE" | awk '{print $2}')
        if [[ -n "$threshold" ]]; then
            echo "当前阈值: $threshold"
        else
            echo "当前阈值: $DEFAULT_THRESHOLD (默认)"
        fi
    else
        echo "当前阈值: $DEFAULT_THRESHOLD (默认，未找到配置文件)"
    fi
}

set_threshold() {
    local value="$1"

    # Validate value
    if ! [[ "$value" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        echo "错误: 阈值必须是数字 (0-10)" >&2
        echo "用法: $0 [0-10]" >&2
        exit 1
    fi

    if (( $(echo "$value > 10" | bc -l) )) || (( $(echo "$value < 0" | bc -l) )); then
        echo "错误: 阈值必须在 0-10 之间" >&2
        exit 1
    fi

    mkdir -p "$(dirname "$CONFIG_FILE")"

    if [[ -f "$CONFIG_FILE" ]]; then
        # Update existing config
        if grep -q "^  threshold:" "$CONFIG_FILE"; then
            sed -i '' "s/^  threshold:.*/  threshold: $value/" "$CONFIG_FILE"
        else
            # Insert after decision: line
            sed -i '' '/^decision:/a\  threshold: '"$value" "$CONFIG_FILE"
        fi
    else
        # Create new config
        cat > "$CONFIG_FILE" << EOF
# metaswarm Configuration

decision:
  threshold: $value
  auto_execute_above_threshold: true
  show_detailed_scores: true
  learning_enabled: true

version:
  default_bump: minor
  auto_patch: true

checkpoints:
  auto_proceed: false

gates:
  auto_proceed_on_approve: true

output:
  rich_output: true
  show_progress: true
  verbose: false
EOF
    fi

    echo "阈值已设置为: $value"
}

reset_threshold() {
    set_threshold "$DEFAULT_THRESHOLD"
}

case "${1:-}" in
    --show|"")
        show_threshold
        ;;
    --reset)
        reset_threshold
        ;;
    -h|--help)
        echo "用法: $0 [value|--show|--reset]"
        echo ""
        echo "选项:"
        echo "  (value)     设置阈值 (0-10)"
        echo "  --show      显示当前阈值"
        echo "  --reset     重置为默认值 (8.0)"
        echo "  --help      显示此帮助"
        ;;
    *)
        set_threshold "$1"
        ;;
esac
