let
  defaultRepeatRate = "30";
  defaultRepeatDelay = "200";
in
{
  # thiccpad touch pad
  "2:7:SynPS/2_Synaptics_TouchPad" = {
    dwt = "enabled";
    tap = "enabled";
    natural_scroll = "enabled";
    middle_emulation = "enabled";
  };

  "1739:0:Synaptics_TM3276-031" = {
    dwt = "enabled";
    tap = "enabled";
    natural_scroll = "enabled";
    middle_emulation = "enabled";
  };

  # thiccpad integrated keyboard
  "1:1:AT_Translated_Set_2_keyboard" = {
    xkb_options = "ctrl:swapcaps,compose:ralt";
    xkb_layout = "us";
    repeat_rate = defaultRepeatRate;
    repeat_delay = defaultRepeatDelay;
  };

  "1008:3402:HP_USB_Keyboard" = {
    xkb_options = "ctrl:swapcaps,compose:ralt";
    xkb_layout = "us";
    repeat_rate = defaultRepeatRate;
    repeat_delay = defaultRepeatDelay;
  };

  # iKBC new Poker II
  "1241:521:USB-HID_Keyboard" = {
    xkb_options = "compose:ralt";
    xkb_layout = "us";
    repeat_rate = defaultRepeatRate;
    repeat_delay = defaultRepeatDelay;
  };

  # Logitech (home) Wireless Keyboard
  "1133:16501:Logitech_Wireless_Keyboard_PID:4075" = {
    xkb_options = "ctrl:swapcaps,compose:ralt";
    xkb_layout = "us";
    repeat_rate = defaultRepeatRate;
    repeat_delay = defaultRepeatDelay;
  };

  "1133:50484:Logitech_USB_Receiver" = {
    xkb_options = "ctrl:swapcaps,compose:ralt";
    xkb_layout = "us";
    repeat_rate = defaultRepeatRate;
    repeat_delay = defaultRepeatDelay;
  };

  #input * {
  #    xkb_options "ctrl:swapcaps"
  #    xkb_layout "us"
  #}
}
