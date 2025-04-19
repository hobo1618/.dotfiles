{ config, ... }:

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

  programs.optimus-manager.enable = true;

}
