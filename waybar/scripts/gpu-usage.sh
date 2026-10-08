#!/usr/bin/env bash
# GPU utilisation chip for waybar. Styling lives in waybar/style.css
# (.normal / .busy). Same two-state scheme as cpu-usage.sh: 100% in a game or
# a render is the GPU doing its job, so busy is orange and never red.
#
# utilization.gpu is nvidia-smi's own sampled figure (the share of the last
# sample period a kernel was running), so no delta bookkeeping is needed here.
set -uo pipefail

BUSY=85

IFS=', ' read -r pct mem_used mem_total power < <(
    nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total,power.draw \
        --format=csv,noheader,nounits 2>/dev/null
)

if ! [[ "${pct:-}" =~ ^[0-9]+$ ]]; then
    printf '{"text":"--%%","tooltip":"GPU: nvidia-smi unavailable","class":"normal"}\n'
    exit 0
fi

(( pct >= BUSY )) && class=busy || class=normal

printf '{"text":"%d%%","tooltip":"GPU %d%%\\nVRAM %.1f / %.1f GiB\\npower %.0f W","class":"%s"}\n' \
    "$pct" "$pct" "$(awk "BEGIN{print $mem_used/1024}")" "$(awk "BEGIN{print $mem_total/1024}")" "${power:-0}" "$class"
