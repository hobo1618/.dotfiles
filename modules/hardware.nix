{ pkgs, config, ... }:
{
  services.xserver.videoDrivers = [ "nvidia" "displaylink" ];
  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = {
      enable = true;
      # finegrained = true;
    };
    prime = {
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  systemd.services.nvidia-reset = {
    description = "Force NVIDIA GPU reset before resume";
    before = [ "suspend.target" ];
    wantedBy = [ "suspend.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      echo "Resetting NVIDIA before suspend"
      echo 1 > /sys/bus/pci/devices/0000:01:00.0/remove
      sleep 1
      echo 1 > /sys/bus/pci/rescan
    '';
  };

}
