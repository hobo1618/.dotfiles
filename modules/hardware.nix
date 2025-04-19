{ pkgs, config, ... }:

let
  # ①  Build the script inside the Nix store
  autoGpuSwitch = pkgs.writeShellScript "auto-gpu-switch" ''
    #!/usr/bin/env bash
    INTERNAL="eDP-1"
    EXTERNAL="DP-4"
    sleep 2
    if ${pkgs.xorg.xrandr}/bin/xrandr --query | grep -q "^$EXTERNAL connected"; then
        ${pkgs.supergfxctl}/bin/supergfxctl -m nvidia
    else
        ${pkgs.supergfxctl}/bin/supergfxctl -m hybrid
    fi
  '';
in
{
  ##############################################################################
  #  NVIDIA + hybrid  (unchanged)
  ##############################################################################
  services.xserver.videoDrivers = [ "nvidia" "displaylink" ];
  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    prime = {
      offload.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  services.supergfxd.enable = true;

  ##############################################################################
  #  ②  (optional) also copy the script to /etc so you can inspect it
  ##############################################################################
  environment.etc."auto-gpu-switch.sh".source = autoGpuSwitch;

  ##############################################################################
  #  ③  udev rule calls the *store* path, not /etc/…
  ##############################################################################
  services.udev.extraRules = ''
    ACTION=="change", SUBSYSTEM=="drm", ENV{HOTPLUG}=="1", \
      RUN+="${autoGpuSwitch}"
  '';
}
