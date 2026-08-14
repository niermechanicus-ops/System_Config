#!/usr/bin/env bash
temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null)
printf '{"text":"%s°C","tooltip":"GPU (NVIDIA)"}\n' "${temp:-N/A}"
