#!/bin/bash
# show-scores.sh — Show decision scores and learning history
#
# Usage:
#   ./scripts/show-scores.sh              # Show current threshold and recent history
#   ./scripts/show-scores.sh --history    # Show full learning history
#   ./scripts/show-scores.sh --stats     # Show statistics
#   ./scripts/show-scores.sh --reset      # Reset learning history

LEARNING_FILE="${HOME}/.metaswarm/decision-history.jsonl"
CONFIG_FILE=".metaswarm/config.yaml"

show_current() {
    echo ""
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│                    决策系统状态                             │"
    echo "└─────────────────────────────────────────────────────────────┘"
    echo ""

    # Show threshold
    if [[ -f "$CONFIG_FILE" ]]; then
        local threshold=$(grep "^  threshold:" "$CONFIG_FILE" 2>/dev/null | awk '{print $2}')
        [[ -z "$threshold" ]] && threshold=8.0
    else
        local threshold=8.0
    fi
    echo "当前阈值: $threshold"

    # Show auto-execute setting
    if [[ -f "$CONFIG_FILE" ]]; then
        local auto_exec=$(grep "auto_execute_above_threshold:" "$CONFIG_FILE" 2>/dev/null | awk '{print $2}')
        [[ -z "$auto_exec" ]] && auto_exec=true
    else
        local auto_exec=true
    fi
    echo "自动执行: $auto_exec"

    # Show learning status
    if [[ -f "$CONFIG_FILE" ]]; then
        local learning=$(grep "learning_enabled:" "$CONFIG_FILE" 2>/dev/null | awk '{print $2}')
        [[ -z "$learning" ]] && learning=true
    else
        local learning=true
    fi
    echo "学习功能: $learning"

    echo ""
}

show_history() {
    echo ""
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│                    学习历史                                │"
    echo "└─────────────────────────────────────────────────────────────┘"
    echo ""

    if [[ ! -f "$LEARNING_FILE" ]]; then
        echo "暂无学习历史"
        echo ""
        echo "学习历史会在你做出选择时自动记录:"
        echo "  - 当你选择某个选项时，该选项 +1 chosen"
        echo "  - 当你跳过某个选项时，该选项 +1 rejected"
        echo ""
        return
    fi

    echo "最近 10 条记录:"
    echo ""

    local count=0
    while IFS= read -r line && [[ $count -lt 10 ]]; do
        local opt=$(echo "$line" | jq -r '.option')
        local choice=$(echo "$line" | jq -r '.choice')
        local ts=$(echo "$line" | jq -r '.timestamp')

        local badge="🤔"
        if [[ "$choice" == "chosen" ]]; then
            badge="✅"
        elif [[ "$choice" == "rejected" ]]; then
            badge="❌"
        fi

        printf "  %s %s — %s\n" "$badge" "$opt" "$ts"
        count=$((count + 1))
    done < <(tac "$LEARNING_FILE")

    echo ""
}

show_stats() {
    echo ""
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│                    统计信息                                │"
    echo "└─────────────────────────────────────────────────────────────┘"
    echo ""

    if [[ ! -f "$LEARNING_FILE" ]]; then
        echo "暂无统计数据"
        return
    fi

    echo "选项选择统计:"
    echo ""

    local total_choices=0
    declare -A opt_chosen
    declare -A opt_rejected

    while IFS= read -r line; do
        local opt=$(echo "$line" | jq -r '.option')
        local choice=$(echo "$line" | jq -r '.choice')

        if [[ "$choice" == "chosen" ]]; then
            opt_chosen[$opt]=$((opt_chosen[$opt] + 1))
            total_choices=$((total_choices + 1))
        elif [[ "$choice" == "rejected" ]]; then
            opt_rejected[$opt]=$((opt_rejected[$opt] + 1))
        fi
    done < "$LEARNING_FILE"

    # Get unique options
    declare -A all_opts
    for opt in "${!opt_chosen[@]}" "${!opt_rejected[@]}"; do
        all_opts[$opt]=1
    done

    for opt in "${!all_opts[@]}"; do
        local chosen=${opt_chosen[$opt]:-0}
        local rejected=${opt_rejected[$opt]:-0}
        local total=$((chosen + rejected))

        if [[ $total -gt 0 ]]; then
            local rate=$(echo "scale=1; $chosen * 100 / $total" | bc)
            printf "  %s: %d/%d (%.0f%% 选择率)\n" "$opt" "$chosen" "$total" "$rate"
        fi
    done

    echo ""
    echo "总选择次数: $total_choices"
    echo ""
}

reset_history() {
    if [[ -f "$LEARNING_FILE" ]]; then
        rm "$LEARNING_FILE"
        echo "学习历史已重置"
    else
        echo "没有需要重置的历史"
    fi
}

case "${1:-}" in
    --history|-h)
        show_current
        show_history
        ;;
    --stats|-s)
        show_current
        show_stats
        ;;
    --reset)
        reset_history
        ;;
    "")
        show_current
        show_history
        show_stats
        ;;
    *)
        echo "用法: $0 [--history|--stats|--reset]"
        ;;
esac
