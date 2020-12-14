from Xlib import X, display
from Xlib.error import DisplayNameError
from Xlib.ext import randr

from binascii import hexlify
from contextlib import closing, suppress
import json
import os
from pathlib import Path
import pprint
import sys
from typing import Any, Dict, List, NamedTuple, Tuple


property = Tuple[int, Any]


class Output(NamedTuple):
    name: str
    xid: Any
    data: Any


def log(*args, newline=True):
    print('[XSERVER-RANDR.py]', *args, end=os.linesep if newline else '')


def pp(object):
    pprint.pp(object, indent=4, compact=True, depth=4)


class Main():
    display: Any
    root: Any
    resources: Any
    outputs: Dict[str, Output]
    profiles: Dict[str, Dict[str, Any]]

    def __init__(self, display, profiles):
        self.display = display
        self.profiles = profiles
        self.root = display.screen().root

    def run(self):
        self.resources = self.root.xrandr_get_screen_resources()._data

        self.outputs = {}
        for xid in self.resources['outputs']:
            output = self.display.xrandr_get_output_info(xid, self.resources['config_timestamp'])._data
            properties = self.display.xrandr_list_output_properties(xid)._data
            self.properties = self.map_properties(xid, properties)
            edid = self.map_edids(self.properties)
            if edid is not None:
                self.outputs[edid] = Output(output['name'], xid, output)

        (profile_name, profile_config) = self.find_matching_profile() or (None, None)
        if profile_config is not None:
            log(f"found matching profile: {profile_name}")
            self.apply_profile(profile_config)
        else:
            log("no matching profile found")

    def map_properties(self, output, props: List[Any]) -> Dict[str, property]:
        result = {}
        for atom in props['atoms']:
            atomname = self.display.get_atom_name(atom)
            prop = self.display.xrandr_get_output_property(output, atom, X.AnyPropertyType, 0, 100)
            result[atomname] = (atom, prop._data['value'])
        return result

    def map_edids(self, props: Dict[str, property]) -> bytes:
        for (atomname, (_atom, prop)) in props.items():
            if atomname in [b"EDID", "EDID"]:
                return str(hexlify(bytearray(prop)), 'utf-8')

    def find_matching_profile(self):
        for profile in self.profiles.items():
            if all(any(monitor['edid'] == edid for edid in self.outputs.keys()) for monitor in profile[1]):
                return profile

    def apply_profile(self, profile):
        log("applying profile")
        pp(profile)
        for monitor in profile:
            if not monitor.get('status', True):
                (name, _xid, _) = self.outputs.get(monitor['edid'])
                log(f"<TODO> disabling monitor '{name}'")
                continue
            if monitor.get('primary'):
                (name, xid, _) = self.outputs.get(monitor['edid'])
                log(f"setting '{name}' as primary")
                self.root.xrandr_set_output_primary(xid)


file = Path(sys.argv[1])
log(f"Reading profile: {file}")
with file.open() as f:
    configFile = json.load(f)

# Any uncaught exception here will fail to start Sway :)
with suppress(DisplayNameError, Exception), closing(display.Display()) as display:
    version = display.xrandr_query_version()
    log(f"RANDR version {version.major_version} {version.minor_version}")

    Main(display, configFile).run()

    # Sync our changes
    display.sync()

log("configuration done, leaving")
