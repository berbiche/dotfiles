#!/usr/bin/env python3
"""
This Waybar module connects to mpris with Playerctl and continuously
monitors and output updated track status information from Spotify.
"""
import json
import sys
import gi
gi.require_version('Playerctl', '2.0')

from gi.repository import Playerctl, GLib


def eprint(*args, **kwargs):
    # print(*args, file=sys.stderr, flush=True, **kwargs)
    pass

def pprint(*args, **kwargs):
    print(*args, flush=True, **kwargs)

def extract_metadata(player, *args):
    metadata = player.props.metadata
    artist = metadata['xesam:artist'][0] if len(metadata['xesam:artist'] or []) > 0 else 'Unknown artist'
    return {
        'artist': artist,
        'title': metadata['xesam:title'] or 'Unknown title',
        'status': player.props.playback_status.value_nick
    }

def on_metadata(player, *args):
    m = extract_metadata(player)
    eprint(m)

    status = m['status'].lower()
    name = f"{m['artist']} - {m['title']}"
    if len(name) > 50:
        name = name[:47] + '...'
    text = f'{name} [{status}]'

    out = json.dumps({'text': text, 'tooltip': f'Listening on Spotify: {text}', 'class': status})
    eprint(out)
    pprint(out)

def on_disconnect(*args):
    nothing_playing()

def is_spotify(player):
    eprint("is_spotify()", player)
    return player.name.lower() == 'spotify'

def init_player(name):
    eprint("init_player(name)", name)
    player = Playerctl.Player.new_from_name(name)
    player.connect('playback-status', on_metadata, manager)
    player.connect('metadata', on_metadata, manager)
    manager.manage_player(player)
    return player

def nothing_playing():
    out = json.dumps({'text': 'Nothing', 'tooltip': 'Nothing playing on Spotify', 'class': 'nothing'})
    pprint(out)


manager = Playerctl.PlayerManager()

# Initial startup, no new player has been connected
if (playerName := next(filter(is_spotify, manager.props.player_names), None)) is not None:
    player = init_player(playerName)
    on_metadata(player)
else:
    nothing_playing()

manager.connect('name-appeared', lambda _, player: is_spotify(player) and init_player(player))
manager.connect('name-vanished', lambda _, player: is_spotify(player) and on_disconnect(manager))

main = GLib.MainLoop()
main.run()
