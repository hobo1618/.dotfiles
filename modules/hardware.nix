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

  programs.optimus-manager.enable = true;


  programs.optimus-manager.settings = {
    optimus = {
      startup_mode = "hybrid"; # Intel primary after every boot
    };
  };

  environment.etc."optimus-auto-switch.sh" = {
    mode = "0755"; # make the file executable
    text = ''
      #!/usr/bin/env bash
      INTERNAL="eDP-1"     # laptop panel   (adjust with `xrandr --query`)
      EXTERNAL="DP-4"      # Dell monitor   (adjust too)

      # Give the kernel a moment to finish the hot‑plug event
      sleep 2

      if ${pkgs.xorg.xrandr}/bin/xrandr --query | grep -q "^$EXTERNAL connected"; then
          ${pkgs.optimus-manager}/bin/optimus-manager --switch nvidia  --no-confirm
      else
          ${pkgs.optimus-manager}/bin/optimus-manager --switch hybrid  --no-confirm
      fi
    '';
  };

  services.udev.extraRules = ''
    ACTION=="change", SUBSYSTEM=="drm", ENV{HOTPLUG}=="1", \
      RUN+="/etc/optimus-auto-switch.sh"
  '';
}
