#!/usr/bin/env python3
import asyncio
import importlib
import sys

from libqtile import bar, hook, layout, qtile, widget
from libqtile.config import Match, Screen
from libqtile.log_utils import logger


def reload(modules):
    for module in modules:
        if module in sys.modules:
            importlib.reload(sys.modules[module])

reload(["settings", "traverse", "groups", "keybindings"])
from settings import *
from groups import groups
from keybindings import keys

# keys = keys
# groups = groups

default_layout_config = {
    'margin': 5,
}

layouts = [
    layout.Max(**default_layout_config),
    layout.MonadThreeCol(**default_layout_config),
    layout.Matrix(**default_layout_config),
]

widget_defaults = dict(
    font="sans",
    fontsize=12,
    padding=3,
)
extension_defaults = widget_defaults.copy()

screens = [
    Screen(
        wallpaper="~/.background-image",
        wallpaper_mode="fill",
        bottom=bar.Bar(
            [
                widget.CurrentLayout(),
                widget.GroupBox(),
                widget.Prompt(),
                widget.WindowName(),
                widget.Chord(
                    chords_colors={
                        "launch": ("#ff0000", "#ffffff"),
                    },
                    name_transform=lambda name: name.upper(),
                ),
                widget.TextBox("default config", name="default"),
                widget.TextBox("Press &lt;M-r&gt; to spawn", foreground="#d75f5f"),
                # NB Systray is incompatible with Wayland, consider using StatusNotifier instead
                # widget.StatusNotifier(),
                widget.Systray(),
                widget.Clock(format="%Y-%m-%d %a %I:%M %p"),
                widget.QuickExit(),
            ],
            24,
            # border_width=[2, 0, 2, 0],  # Draw top and bottom borders
            # border_color=["ff00ff", "000000", "ff00ff", "000000"]  # Borders are magenta
        ),
    ),
]

floating_layout = layout.Floating(
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(title="pinentry"),  # GPG key password entry
        Match(wm_class="notification"),
        Match(wm_class="pavucontrol"),
        Match(wm_class="gnome-panel", title="Calendar"),
        Match(wm_class="gnome-control-center"),
        Match(wm_class="avizo-service"),
        Match(wm_class="xfce4-appfinder"),
        Match(wm_instance_class="floating-term"),
        Match(func=lambda c: c.has_fixed_size() or bool(c.is_transient_for())),
    ]
)

if IS_XEPHYR:
    @hook.subscribe.startup_once
    async def _():
        await asyncio.sleep(0.5)
        qtile.cmd_reconfigure_screens()
