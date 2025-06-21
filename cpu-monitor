#! /bin/bash
# CPU監視スクリプト

echo "1分間のCPU使用率を監視開始"

for i in {1..12}; do
   printf "\n---%d/12(%s)---\n" $i "$(date +%H:%M:%S)"
   ps aux | awk '$3 > 5.0 {printf "PID %6s CPU %4s%% %s\n", $2, $3, $11}' | head -n 10
   [ $i -lt 12 ] && sleep 5
done

echo "監視完了"

