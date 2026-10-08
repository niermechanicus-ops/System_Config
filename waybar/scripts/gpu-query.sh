# Sourced by gpu-usage.sh and gpu-temp.sh — not run directly.
#
# Both chips refresh every 5s and both need nvidia-smi, which is the slowest
# thing either does. So one nvidia-smi call fetches every field either chip
# needs, and the result is cached for a few seconds: whichever chip runs
# first pays for the query, the other reads the cache.
#
# flock makes the second chip wait for the first's query instead of starting
# its own when waybar launches both at the same moment.
#
# Sets: gpu_util gpu_temp gpu_mem_used gpu_mem_total gpu_power
# (left empty if nvidia-smi fails; callers check gpu_util / gpu_temp).

GPU_CACHE="${XDG_RUNTIME_DIR:-/tmp}/waybar-gpu.csv"
GPU_CACHE_MAX_AGE=3   # seconds; under the 5s interval so every tick is fresh

gpu_query() {
    local line
    exec {lock}>"$GPU_CACHE.lock"
    flock "$lock"
    if [ -f "$GPU_CACHE" ] && (( $(date +%s) - $(stat -c %Y "$GPU_CACHE") < GPU_CACHE_MAX_AGE )); then
        line=$(<"$GPU_CACHE")
    else
        line=$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total,power.draw \
                   --format=csv,noheader,nounits 2>/dev/null | head -n1)
        # Don't cache a failure — let the next tick retry.
        [ -n "$line" ] && printf '%s\n' "$line" > "$GPU_CACHE"
    fi
    exec {lock}>&-
    IFS=', ' read -r gpu_util gpu_temp gpu_mem_used gpu_mem_total gpu_power <<< "$line"
}
