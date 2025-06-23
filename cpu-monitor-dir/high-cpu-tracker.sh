#!/bin/bash
# CPU監視スクリプト

# 設定値の定義
CPU_THRESHOLD_PERCENT=10
MAX_PROCESSES_PER_MEASUREMENT=5
INTERVAL_SECONDS=5
TOTAL_MEASUREMENTS=12

LOG_DIR="$HOME/bin/cpu-monitor-dir/logs/"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/cpu_monitor_log_$(date +%Y%m%d_%H%M%S).json"

function generateHeader() {
    cat <<EOF
    {
        "execution_timestamp": "$(date -Iseconds)",
        "system_info": {
            "cpu_cores": $(sysctl -n hw.ncpu),
            "load_average": "$(uptime | awk -F'load averages: ' '{print $2}')",
            "uptime": "$(uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}')"
        },
    "monitoring_config": {
        "cpu_threshold_percent": $CPU_THRESHOLD_PERCENT,
        "max_processes_per_measurement": $MAX_PROCESSES_PER_MEASUREMENT,
        "measurement_interval_seconds": $INTERVAL_SECONDS,
        "total_measurements": $TOTAL_MEASUREMENTS
    },
"measurements": [
EOF
}

function generateBody {
    for i in $(seq 1 $TOTAL_MEASUREMENTS); do
        echo "測定 $i/$TOTAL_MEASUREMENTS..." >&2

        cat <<EOF
        {
            "timestamp": "$(date -Iseconds)",
            "processes": [
EOF

        getHighCpuProcesses
        cat <<EOF

]
}$([ $i -lt $TOTAL_MEASUREMENTS ] && echo ",")
]
EOF

        [[ $i -lt $TOTAL_MEASUREMENTS ]] && sleep $INTERVAL_SECONDS
    done
}

# CPU率が10%以上のプロセス上位5つを検出
function getHighCpuProcesses() {
    ps aux | awk -v threshold=$CPU_THRESHOLD_PERCENT '$3 > threshold {
        if (process_count > 0) print ","
            printf "                {\"pid\":%s,\"cpu\":%s,\"mem\":%s,\"time\":\"%s\",\"command\":\"%s\"}", $2, $3, $4, $10, $11
            process_count++
        }' | head -$MAX_PROCESSES_PER_MEASUREMENT
}

function main() {
    echo "🚀プロセスチェック開始"
    {
        generateHeader
        generateBody
    } >"$LOG_FILE"
    echo "✅ チェック完了: $LOG_FILE"
}

main "$@"
