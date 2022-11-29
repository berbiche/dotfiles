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
      "1118:2054:Designer_Keyboard"
      # Logitech (home) Wireless Keyboard
      "1133:16501:Logitech_Wireless_Keyboard_PID:4075"
      "1133:50484:Logitech_USB_Receiver"
    ]);
in
shitty-keyboards // {
  # Thinkpad T580 touch pad
  "1739:0:Synaptics_TM3276-031" = {
    dwt = "enabled";
    tap = "enabled";
    natural_scroll = "enabled";
    middle_emulation = "enabled";
    pointer_accel = "0.25";
    scroll_factor = "0.5";
    scroll_method = "two_finger";
    # Number of fingers for each "button": 1: left; 2: right; 3: middle
    tap_button_map = "lrm";
  };

  # iKBC new Poker II
  "1241:521:USB-HID_Keyboard" = {
    xkb_options = "compose:ralt";
    xkb_layout = "us";
    repeat_rate = defaultRepeatRate;
    repeat_delay = defaultRepeatDelay;
  };
  "10730:866:Kinesis_Corporation_Adv360_Pro_Keyboard" = {
    xkb_options = "compose:paus";
    xkb_layout = "us";
    repeat_rate = defaultRepeatRate;
    repeat_delay = defaultRepeatDelay;
  };
  # My old Noppoo KB84M
  "1155:20736:CATEX_TECH._KB84M-S" = {
    xkb_options = "compose:ralt";
    xkb_layout = "us";
    repeat_rate = defaultRepeatRate;
    repeat_delay = defaultRepeatDelay;
  };
}
