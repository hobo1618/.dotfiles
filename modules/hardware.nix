{ pkgs, config, ... }:

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

      # prime = {
      #   offload.enable = true;
      #   intelBusId = "PCI:0:2:0";
      #   nvidiaBusId = "PCI:1:0:0";
      # };
    };

  hardware.nvidia-container-toolkit.enable = true;

  services.supergfxd.enable = true; # << built‑in service

  # helper script (same as before but calls supergfxctl)
  environment.etc."auto‑gpu‑switch.sh" = {
    mode = "0755";
    text = ''
      #!/usr/bin/env bash
      INTERNAL="eDP-1"
      EXTERNAL="DP-4"
      sleep 2
      if ${pkgs.xorg.xrandr}/bin/xrandr --query | grep -q "^$EXTERNAL connected"; then
          ${pkgs.supergfxctl}/bin/supergfxctl -m nvidia
      else
          ${pkgs.supergfxctl}/bin/supergfxctl -m hybrid   # intel primary
      fi
    '';
  };

  # udev rule
  services.udev.extraRules = ''
    ACTION=="change", SUBSYSTEM=="drm", ENV{HOTPLUG}=="1", \
      RUN+="/etc/auto-gpu-switch.sh"
  '';
}
