#!/bin/bash
# decision-scorer.sh — Score options and determine if auto-execute
#
# Usage:
#   ./scripts/decision-scorer.sh [options...]
#
# Options:
#   --option <id> <name> <safety> <complexity> <efficiency> <ai_priority> [pros...] [--cons...]
#   --threshold <score>
#   --learn <option_id> [chosen|rejected]
#   --format [table|json|simple]
#
# Example:
#   ./scripts/decision-scorer.sh \
#     --option 1 "Orchestrated" 9 3 8 9 \
#       "经过验证的流程" "100%覆盖率" "完整审查" \
#       --cons "速度较慢" \
#     --option 2 "Subagent" 7 5 9 7 \
#       "速度快" "灵活" \
#       --cons "覆盖率略低" \
#     --threshold 8.0 \
#     --format table
#
# Scoring Dimensions (Weights):
#   Safety: 30% — Risk level (1=high risk, 10=no risk)
#   Complexity: 20% — Inverse (1=very complex, 10=very simple)
#   Efficiency: 20% — Time/resource efficiency (1=low, 10=high)
#   AI Priority: 10% — AI's original recommendation (1=low, 10=high)
#   User Match: 20% — Learned from historical choices

set -e

# Default values
THRESHOLD=8.0
FORMAT="table"
AUTO_EXECUTE=true
SHOW_REASONING=true
LEARNING_ENABLED=true
LEARNING_FILE="${HOME}/.metaswarm/decision-history.jsonl"

# Weights
SAFETY_WEIGHT=0.30
COMPLEXITY_WEIGHT=0.20
EFFICIENCY_WEIGHT=0.20
AI_PRIORITY_WEIGHT=0.10
USER_MATCH_WEIGHT=0.20

# Parse arguments
declare -a OPTIONS
CURRENT_OPTION=""
declare -A OPT_SAFETY
declare -A OPT_COMPLEXITY
declare -A OPT_EFFICIENCY
declare -A OPT_AI_PRIORITY
declare -A OPT_PROS
declare -A OPT_CONS
declare -A OPT_NAMES

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --option)
                local id="$2"
                local name="$3"
                local safety="$4"
                local complexity="$5"
                local efficiency="$6"
                local ai_priority="$7"
                shift 7

                OPT_NAMES[$id]="$name"
                OPT_SAFETY[$id]="$safety"
                OPT_COMPLEXITY[$id]="$complexity"
                OPT_EFFICIENCY[$id]="$efficiency"
                OPT_AI_PRIORITY[$id]="$ai_priority"

                # Parse pros
                local pros=""
                while [[ $# -gt 0 ]] && [[ "$1" != "--cons" ]] && [[ "$1" != "--option" ]] && [[ "$1" != --* ]]; do
                    pros="$pros $1"
                    shift
                done
                OPT_PROS[$id]="$pros"

                # Parse cons
                if [[ "$1" == "--cons" ]]; then
                    shift
                    local cons=""
                    while [[ $# -gt 0 ]] && [[ "$1" != "--option" ]] && [[ "$1" != --* ]]; do
                        cons="$cons $1"
                        shift
                    done
                    OPT_CONS[$id]="$cons"
                fi

                OPTIONS+=("$id")
                ;;

            --threshold)
                THRESHOLD="$2"
                shift 2
                ;;

            --format)
                FORMAT="$2"
                shift 2
                ;;

            --learn)
                learn "$2" "$3"
                shift 3
                ;;

            --no-learn)
                LEARNING_ENABLED=false
                shift
                ;;

            *)
                shift
                ;;
        esac
    done
}

# Learning function
learn() {
    local option_id="$1"
    local choice="$2"

    if [[ "$LEARNING_ENABLED" != "true" ]]; then
        return
    fi

    mkdir -p "$(dirname "$LEARNING_FILE")"

    echo "{\"option\":\"$option_id\",\"choice\":\"$choice\",\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}" >> "$LEARNING_FILE"
}

# Get user match score based on history
get_user_match() {
    local option_id="$1"
    local total=0
    local chosen=0

    if [[ ! -f "$LEARNING_FILE" ]]; then
        echo "5.0"  # Default neutral score
        return
    fi

    while IFS= read -r line; do
        local opt=$(echo "$line" | jq -r '.option')
        local ch=$(echo "$line" | jq -r '.choice')

        if [[ "$opt" == "$option_id" ]]; then
            total=$((total + 1))
            if [[ "$ch" == "chosen" ]]; then
                chosen=$((chosen + 1))
            fi
        fi
    done < "$LEARNING_FILE"

    if [[ $total -eq 0 ]]; then
        echo "5.0"
        return
    fi

    local ratio=$(echo "scale=2; $chosen / $total" | bc)
    local score=$(echo "scale=1; $ratio * 10" | bc)
    echo "$score"
}

# Calculate score for an option
calculate_score() {
    local id="$1"

    local safety="${OPT_SAFETY[$id]}"
    local complexity="${OPT_COMPLEXITY[$id]}"
    local efficiency="${OPT_EFFICIENCY[$id]}"
    local ai_priority="${OPT_AI_PRIORITY[$id]}"
    local user_match=$(get_user_match "$id")

    # Complexity is inverse (lower complexity = higher score)
    local complexity_score=$(echo "scale=1; 11 - $complexity" | bc)

    local score=$(echo "scale=2; \
        $safety * $SAFETY_WEIGHT + \
        $complexity_score * $COMPLEXITY_WEIGHT + \
        $efficiency * $EFFICIENCY_WEIGHT + \
        $ai_priority * $AI_PRIORITY_WEIGHT + \
        $user_match * $USER_MATCH_WEIGHT" | bc)

    echo "$score"
}

# Get badge for score
get_badge() {
    local score="$1"

    if (( $(echo "$score >= 9" | bc -l) )); then
        echo "🌟"
    elif (( $(echo "$score >= 8" | bc -l) )); then
        echo "✅"
    elif (( $(echo "$score >= 7" | bc -l) )); then
        echo "👍"
    elif (( $(echo "$score >= 5" | bc -l) )); then
        echo "🤔"
    else
        echo "⚠️"
    fi
}

# Get status based on threshold
get_status() {
    local score="$1"

    if (( $(echo "$score >= $THRESHOLD" | bc -l) )); then
        echo "✅ 自动执行"
    elif (( $(echo "$score >= 7" | bc -l) )); then
        echo "👍 建议执行"
    elif (( $(echo "$score >= 5" | bc -l) )); then
        echo "🤔 询问确认"
    else
        echo "⚠️ 需确认"
    fi
}

# Format as table
format_table() {
    echo ""
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│                    选项评分结果                              │"
    echo "└─────────────────────────────────────────────────────────────┘"
    echo ""

    local best_id=""
    local best_score="0"

    for id in "${OPTIONS[@]}"; do
        local score=$(calculate_score "$id")

        if (( $(echo "$score > $best_score" | bc -l) )); then
            best_score="$score"
            best_id="$id"
        fi
    done

    for id in "${OPTIONS[@]}"; do
        local name="${OPT_NAMES[$id]}"
        local score=$(calculate_score "$id")
        local safety="${OPT_SAFETY[$id]}"
        local complexity="${OPT_COMPLEXITY[$id]}"
        local efficiency="${OPT_EFFICIENCY[$id]}"
        local pros="${OPT_PROS[$id]}"
        local cons="${OPT_CONS[$id]}"
        local badge=$(get_badge "$score")
        local status=$(get_status "$score")

        if [[ "$id" == "$best_id" ]]; then
            echo "┌─────────────────────────────────────────────────────────────┐"
            echo "│  $id. $name $(printf '%*s' $((48 - ${#name} - 4)) "[$badge $score]") │"
            echo "│     $pros $status                                       │"
            [[ -n "$cons" ]] && echo "│     $cons                                              │"
            echo "└─────────────────────────────────────────────────────────────┘"
        else
            echo "│  $id. $name $(printf '%*s' $((48 - ${#name} - 4)) "[$badge $score]")"
            echo "│     $pros $status"
            [[ -n "$cons" ]] && echo "│     $cons"
            echo "│"
        fi
    done

    echo ""
    echo "阈值: $THRESHOLD | 推荐: $best_id ($best_score分)"
    echo ""

    if (( $(echo "$best_score >= $THRESHOLD" | bc -l) )) && [[ "$AUTO_EXECUTE" == "true" ]]; then
        echo "状态: ⏩ 自动执行选项 $best_id..."
        echo ""
        echo "auto_execute: true"
        echo "selected_option: $best_id"
        echo "score: $best_score"
    else
        echo "状态: ⏸ 等待用户确认..."
        echo ""
        echo "auto_execute: false"
        echo "selected_option: null"
        echo "options:"
        for id in "${OPTIONS[@]}"; do
            local score=$(calculate_score "$id")
            echo "  - id: $id"
            echo "    score: $score"
        done
    fi
}

# Format as JSON
format_json() {
    echo "{"
    echo "  \"threshold\": $THRESHOLD,"
    echo "  \"options\": ["

    local first=true
    for id in "${OPTIONS[@]}"; do
        [[ "$first" == "false" ]] && echo ","
        local score=$(calculate_score "$id")
        echo "    {"
        echo "      \"id\": \"$id\","
        echo "      \"name\": \"${OPT_NAMES[$id]}\","
        echo "      \"score\": $score,"
        echo "      \"status\": \"$(get_status $score)\""
        echo -n "    }"
        first=false
    done

    echo ""
    echo "  ],"

    local best_score="0"
    local best_id=""
    for id in "${OPTIONS[@]}"; do
        local score=$(calculate_score "$id")
        if (( $(echo "$score > $best_score" | bc -l) )); then
            best_score="$score"
            best_id="$id"
        fi
    done

    echo "  \"recommended\": {"
    echo "    \"id\": \"$best_id\","
    echo "    \"score\": $best_score"
    echo "  },"

    if (( $(echo "$best_score >= $THRESHOLD" | bc -l) )) && [[ "$AUTO_EXECUTE" == "true" ]]; then
        echo "  \"auto_execute\": true,"
        echo "  \"selected_option\": \"$best_id\""
    else
        echo "  \"auto_execute\": false,"
        echo "  \"selected_option\": null"
    fi

    echo "}"
}

# Format as simple
format_simple() {
    for id in "${OPTIONS[@]}"; do
        local score=$(calculate_score "$id")
        local status=$(get_status "$score")
        echo "[$score] $id. ${OPT_NAMES[$id]} - $status"
    done

    local best_score="0"
    local best_id=""
    for id in "${OPTIONS[@]}"; do
        local score=$(calculate_score "$id")
        if (( $(echo "$score > $best_score" | bc -l) )); then
            best_score="$score"
            best_id="$id"
        fi
    done

    echo ""
    echo "推荐: $best_id ($best_score分)"

    if (( $(echo "$best_score >= $THRESHOLD" | bc -l) )) && [[ "$AUTO_EXECUTE" == "true" ]]; then
        echo "→ 自动执行"
    else
        echo "→ 等待确认"
    fi
}

# Main
main() {
    parse_args "$@"

    case "$FORMAT" in
        table)
            format_table
            ;;
        json)
            format_json
            ;;
        simple)
            format_simple
            ;;
    esac
}

main "$@"
