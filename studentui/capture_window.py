"""Capture only a named laboratory window for visual verification."""
import os
import re
import subprocess
import sys

os.environ["GDK_BACKEND"] = "x11"
import gi
gi.require_version("Gdk", "3.0")
gi.require_version("GdkX11", "3.0")
from gi.repository import Gdk, GdkX11

prefix, output = sys.argv[1:]
tree = subprocess.check_output(["xwininfo", "-root", "-tree"], text=True)
matches = [line for line in tree.splitlines()
           if f'"{prefix}' in line and '("Scilab" "Scilab")' in line]
if not matches:
    raise SystemExit(f"No laboratory window starts with {prefix!r}")
xid = int(re.search(r"0x[0-9a-fA-F]+", matches[0]).group(), 16)
display = Gdk.Display.get_default()
window = GdkX11.X11Window.foreign_new_for_display(display, xid)
pixbuf = Gdk.pixbuf_get_from_window(window, 0, 0, window.get_width(), window.get_height())
if pixbuf is None:
    raise SystemExit("The laboratory window could not be captured")
pixbuf.savev(output, "png", [], [])
print(output, pixbuf.get_width(), pixbuf.get_height())
