let
  defaultRepeatRate = "30";
  defaultRepeatDelay = "200";

  shitty-keyboards =
    builtins.listToAttrs (map (name: {
      inherit name;
      value = { 
        xkb_options = "ctrl:swapcaps,compose:ralt";
        xkb_layout = "us";
        repeat_rate = defaultRepeatRate;
        repeat_delay = defaultRepeatDelay;
      };
    }) [
      "1118:1874:Microsoft_Wired_Keyboard_400"
      "1:1:AT_Translated_Set_2_keyboard"
      "1008:3402:HP_USB_Keyboard"
      # Logitech (home) Wireless Keyboard
      "1133:16501:Logitech_Wireless_Keyboard_PID:4075"
      "1133:50484:Logitech_USB_Receiver"
    ]);
in
shitty-keyboards // {
  # thiccpad touch pad
  "1739:0:Synaptics_TM3276-031" = {
    dwt = "enabled";
    tap = "enabled";
    natural_scroll = "enabled";
    middle_emulation = "enabled";
  };

  # iKBC new Poker II
  "1241:521:USB-HID_Keyboard" = {
    xkb_options = "compose:ralt";
    xkb_layout = "us";
    repeat_rate = defaultRepeatRate;
    repeat_delay = defaultRepeatDelay;
  };
}
