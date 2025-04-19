{ pkgs, config, ... }:
let
  autoGpuSwitch = ''
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
  services.xserver.videoDrivers = [ "nvidia" "displaylink" ];

  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;

  hardware.nvidia =
    {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = true;
      nvidiaSettings = true;
      open = false;
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      prime = {
        offload.enable = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };

  hardware.nvidia-container-toolkit.enable = true;

  services.supergfxd.enable = true; # << built‑in service

  # helper script (same as before but calls supergfxctl)
  ############  make the file appear at *exactly* /etc/auto-gpu-switch.sh
  environment.etc."auto-gpu-switch.sh" = {
    text = autoGpuSwitch;
    mode = "0755"; # <- executable!
  };

  ############  udev rule that calls it
  services.udev.extraRules = ''
    ACTION=="change", SUBSYSTEM=="drm", ENV{HOTPLUG}=="1", \
      RUN+="/etc/auto-gpu-switch.sh"
  '';
}
