{ config, lib, pkgs, ... }:

{
  # Kinect Camera udev rules
  # See https://openkinect.org/wiki/Getting_Started#Use_as_normal_user
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEMS=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02ae", MODE="0660", GROUP="video"
    ACTION=="add", SUBSYSTEMS=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02ad", MODE="0660", GROUP="video"
    ACTION=="add", SUBSYSTEMS=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02b0", MODE="0660", GROUP="video"
  '';

  # Kinect kernel module config
  # Enables Kinect to be used as a webcam (a very shitty one :DDD)
  environment.etc."modprobe.d/kinect.conf".text = ''
    options gspca-kinect depth_mode=0
  '';
}
