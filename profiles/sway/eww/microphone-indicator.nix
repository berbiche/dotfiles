{ lib, pkgs, ... }:

let
  # binPath = lib.makeBinPath [ pkgs.pulseaudio pkgs.gnugrep pkgs.coreutils ];
  # getSource = ''source="$(pactl info | grep "Default Source" | cut -d" " -f3)'';
in
{
  xdg.configFile."eww/microphone-indicator.xml".force = true;
  xdg.configFile."eww/microphone-indicator.xml".text = ''
    <eww>
      <variables>
        <script-var name="mic_mute" interval="1s">
          ${pkgs.writeShellScript "eww-mic-mute" ''
             ${pkgs.pamixer}/bin/pamixer --source '@DEFAULT_SOURCE@' --get-mute

          ''}
        </script-var>
        <script-var name="mic_volume" interval="1s">
          ${pkgs.writeShellScript "eww-mic-volume" ''
             ${pkgs.pamixer}/bin/pamixer --source '@DEFAULT_SOURCE@' --get-volume
          ''}
        </script-var>
      </variables>
      <definitions>
        <def name="slider-mic">
          <box orientation="h" space-evenly="false" spacing="10" halign="start"
            valign="start" vexpand="false" hexpand="false">
            <label class="label-vol" text="{{if mic_mute then '' else ''}}"></label>
            <scale orientation="h" min="0" max="100" valign="center" flipped="false" value="{{mic_volume}}"/>
          </box>
        </def>
      </definitions>
      <windows>
        <window name="microphone" stacking="ov" focusable="false">
          <geometry anchor="bottom center" x="0" y="10%" width="300px" height="60px"/>
          <widget>
            <slider-mic />
          </widget>
        </window>
      </windows>
    </eww>
  '';
}
