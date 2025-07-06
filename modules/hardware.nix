{ pkgs, config, ... }:
{
  # services.xserver.videoDrivers = [ "nvidia" "displaylink" ];
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;

  # DEDICATED GPU
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = {
      enable = true;
      # finegrained = true; # DELETE?
    };
    prime = {
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    open = false;
  };

  # HYRBID
  # hardware.nvidia = {
  #   modesetting.enable = true;
  #   powerManagement = {
  #     enable = true;
  #     finegrained = true;
  #   };
  #   prime = {
  #     offload.enable = true;
  #     intelBusId = "PCI:0:2:0";
  #     nvidiaBusId = "PCI:1:0:0";
  #   };
  #   nvidiaSettings = true;
  #   package = config.boot.kernelPackages.nvidiaPackages.stable;
  # };

}
