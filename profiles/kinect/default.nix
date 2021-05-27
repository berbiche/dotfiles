{ config, lib, pkgs, ... }:

let
  firmwarePackage = pkgs.fetchurl {
    name = "UACFirmware";
    url = "http://download.microsoft.com/download/F/9/9/F99791F2-D5BE-478A-B77A-830AD14950C3/KinectSDK-v1.0-beta2-x86.msi";
    sha256 = "08a2vpgd061cmc6h3h8i6qj3sjvjr1fwcnwccwywqypz3icn8xw1";
  };
in
{
  # Kinect Camera udev rules
  # See https://openkinect.org/wiki/Getting_Started#Use_as_normal_user
  services.udev.extraRules = ''
    # Persist Kinect Firmnware SDK: ${firmwarePackage}
    ACTION=="add", SUBSYSTEMS=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02ae", MODE="0660", GROUP="video"
    ACTION=="add", SUBSYSTEMS=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02ad", MODE="0660", GROUP="video"
    ACTION=="add", SUBSYSTEMS=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02b0", MODE="0660", GROUP="video"
  '';

  # Kinect kernel module config
  # Enables Kinect to be used as a webcam (a very shitty one :DDD)
  environment.etc."modprobe.d/kinect.conf".text = ''
    options gspca-kinect depth_mode=0
  '';

  environment.systemPackages = [ pkgs.freenect ];

  # Not sure whether `builtins.seq` was required after fixing the hash of the firmware package
  services.udev.packages = [ (builtins.deepSeq "${firmwarePackage}" pkgs.my-nur.kinect-audio-setup) ];
}
