#!/usr/bin/env python3
# One pixel tile for the centre of the bar: `workspace.py N` draws workspace N.
#
# Why not waybar's own hyprland/workspaces module: its click handler sends the
# old `dispatch workspace N` command, which this Lua-config Hyprland rejects,
# so tiles would show but never switch. Each tile is instead its own custom
# module, whose on-click runs the Lua dispatcher (see config.jsonc).
#
# Runs forever: listens on Hyprland's event socket and prints a new line only
# when this tile's state actually changes. State comes from the request socket
# directly, so no hyprctl/jq processes are spawned per event.
#
# Each tile is just its number; the state is shown by colour (style.css):
#   empty     nothing open there          dim plum
#   occupied  has windows                 cream
#   visible   on screen on the 4K, but focus is on the other monitor
#                                         pink
#   active    the workspace you're in     dark on a pink block
import json, os, socket, sys

N = int(sys.argv[1])
SOCK = os.path.join(os.environ["XDG_RUNTIME_DIR"], "hypr",
                    os.environ["HYPRLAND_INSTANCE_SIGNATURE"])
# Events that can change which workspace exists, has windows, or has focus.
WATCH = (b"workspace>>", b"focusedmon>>", b"createworkspace>>",
         b"destroyworkspace>>", b"openwindow>>", b"closewindow>>",
         b"movewindow>>", b"moveworkspace>>")


def ask(cmd):
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
        s.connect(SOCK + "/.socket.sock")
        s.sendall(b"j/" + cmd)
        data = b""
        while chunk := s.recv(65536):
            data += chunk
    return json.loads(data)


def state():
    ws = {w["id"]: w for w in ask(b"workspaces")}
    for m in ask(b"monitors"):
        if m["activeWorkspace"]["id"] == N:
            return "active" if m["focused"] else "visible"
    return "occupied" if ws.get(N, {}).get("windows", 0) else "empty"


last = None
def emit():
    global last
    st = state()
    if st != last:
        last = st
        print(json.dumps({"text": str(N), "class": st,
                          "tooltip": f"Workspace {N}"}, ensure_ascii=False), flush=True)


emit()
with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as ev:
    ev.connect(SOCK + "/.socket2.sock")
    buf = b""
    while chunk := ev.recv(4096):
        buf += chunk
        *lines, buf = buf.split(b"\n")
        if any(l.startswith(WATCH) for l in lines):
            emit()
