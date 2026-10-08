#!/usr/bin/env bash
# GPU utilisation chip for waybar. Styling lives in waybar/style.css
# (.normal / .busy). Same two-state scheme as cpu-usage.sh: 100% in a game or
# a render is the GPU doing its job, so busy is orange and never red.
#
# utilization.gpu is nvidia-smi's own sampled figure (the share of the last
# sample period a kernel was running), so no delta bookkeeping is needed here.
set -uo pipefail

BUSY=85

# One nvidia-smi call shared with gpu-temp.sh — see gpu-query.sh.
. "$(dirname "$0")/gpu-query.sh"
gpu_query
pct=$gpu_util mem_used=$gpu_mem_used mem_total=$gpu_mem_total power=$gpu_power

if ! [[ "${pct:-}" =~ ^[0-9]+$ ]]; then
    printf '{"text":"--%%","tooltip":"GPU: nvidia-smi unavailable","class":"normal"}\n'
    exit 0
fi

(( pct >= BUSY )) && class=busy || class=normal

printf '{"text":"%d%%","tooltip":"GPU %d%%\\nVRAM %.1f / %.1f GiB\\npower %.0f W","class":"%s"}\n' \
    "$pct" "$pct" "$(awk "BEGIN{print $mem_used/1024}")" "$(awk "BEGIN{print $mem_total/1024}")" "${power:-0}" "$class"
