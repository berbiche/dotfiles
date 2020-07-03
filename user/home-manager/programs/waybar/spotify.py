#! /usr/bin/env nix-shell
#! nix-shell -i python3 -p playerctl gtk3 python3.pkgs.pygobject3 gobject-introspection
import gi
gi.require_version('Playerctl', '2.0')

from gi.repository import Playerctl, GLib


# def on_play(player, status, manager):
#     name = '{} {}'.format(player.props.)
#     status = '{}'.format(player.props.)
#     print('{name} {status}', name=name[:40].rstrip(), status=status)


def on_metadata(player, metadata, manager):
    keys = metadata.keys()

    status = '[{}]'.format(player.props.status.lower())
    if 'xesam:artist' in keys and 'xesam:title' in keys:
        name = '{artist} - {song}'.format(artist=metadata['xesam:artist'][0],
                                          song=metadata['xesam:title'])
        if len(name) > 50:
            name = name[:50] + '...'

        print('{} {}'.format(name, status))


def init_player(name):
    print(f'init_player({name})')
    player = Playerctl.Player.new_from_name(name)
    # player.connect('playback-status::playing', on_play, manager)
    player.connect('metadata', on_metadata, manager)
    manager.manage_player(player)


manager = Playerctl.PlayerManager()

manager.connect('name-appeared', lambda _, name: init_player(name))

for name in manager.props.player_names:
    if name.name == 'spotify':
        init_player(name)
        break

main = GLib.MainLoop()
main.run()
