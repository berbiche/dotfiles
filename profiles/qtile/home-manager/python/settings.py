import os

from libqtile import qtile


IS_WAYLAND = qtile.core.name == "wayland"
IS_X11 = not IS_WAYLAND
IS_XEPHYR = bool(os.environ.get("QTILE_XEPHYR", 0))


mod = "mod1" if IS_XEPHYR else "mod4"

### Global settings
dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = True
cursor_warp = False

auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing focus
auto_minimize = False

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

wmname = "LG3D"

binaries = {}

if IS_XEPHYR:
    binaries["terminal"] = "alacritty"
else:
    binaries["terminal"] = "@terminal@"

binaries["floating-term"] = "@floating-term@"
binaries["explorer"] = "@explorer@"
binaries["browser"] = "@browser@"
binaries["browser-private"] = "@browser-private@"
binaries["audiocontrol"] = "@pavucontrol@"
binaries["launcher"] = "@launcher@"
binaries["menu"] = "@menu@"
binaries["logout"] = "@logout@"
binaries["locker"] = "@locker@"
binaries["screenshot"] = "@screenshot@"
binaries["volume"] = "@volume@"

binaries["brightnessctl"] = "@brightnessctl@"
binaries["playerctl"] = "@playerctl@"

binaries["emacsclient"] = "@emacsclient@"
binaries["element-desktop"] = "@element-desktop@"
binaries["spotify"] = "@spotify@"
binaries["unclutter"] = "@unclutter@"

