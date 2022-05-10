from libqtile.config import Group, Key, Match
from libqtile.lazy import lazy


groups = [
    # browsing
    Group("1", label="", ),
    # school
    Group("2", label=""),
    # dev
    Group("3", label=""),
    # sysadmin
    Group("4", label=""),
    # gaming
    Group("5", label=""),
    # movie
    Group("6", label=""),
    # social
    Group("7", label="", matches=[
        Match(wm_class="Element"),
        Match(wm_class="Signal"),
        Match(wm_class="Bitwarden"),
        Match(wm_class="Discord"),
    ]),
    Group("8"),
    Group("9"),
    Group("0", label="10"),
]
