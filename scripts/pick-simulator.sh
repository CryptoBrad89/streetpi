#!/bin/bash
# Picks one available iPhone simulator so the snapshot job stays on a single destination.
set -euo pipefail

python3 - << 'PY'
import json
import subprocess
import sys

raw = subprocess.check_output(["xcrun", "simctl", "list", "devices", "available", "-j"], text=True)
data = json.loads(raw)
candidates = []
for runtime, devices in data.get("devices", {}).items():
    if "iOS" not in runtime:
        continue
    for device in devices:
        if device.get("isAvailable") is False:
            continue
        name = device.get("name", "")
        if name.startswith("iPhone"):
            candidates.append((runtime, name))

if not candidates:
    sys.exit("No available iPhone simulator")

candidates.sort()
runtime = candidates[-1][0]
names = [name for item_runtime, name in candidates if item_runtime == runtime]
preferred = [name for name in names if "Pro" in name]
chosen = preferred[-1] if preferred else names[-1]
print(f"platform=iOS Simulator,name={chosen},arch=arm64")
PY
