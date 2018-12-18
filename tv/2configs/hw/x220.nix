{ config, pkgs, ... }:
{
  imports = [
    ../smartd.nix
    {
      boot.extraModulePackages = [
        config.boot.kernelPackages.acpi_call
      ];

      boot.kernelModules = [
        "acpi_call"
      ];

      environment.systemPackages = [
        pkgs.tpacpi-bat
      ];
    }
  ];

  boot.extraModulePackages = [
    config.boot.kernelPackages.tp_smapi
  ];

  boot.kernelModules = [ "tp_smapi" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Required for Centrino.
  hardware.enableRedistributableFirmware = true;

  hardware.opengl.extraPackages = [ pkgs.vaapiIntel pkgs.vaapiVdpau ];

  hardware.trackpoint = {
    enable = true;
    sensitivity = 220;
    speed = 0;
    emulateWheel = true;
  };

  services.tlp.enable = true;
  services.tlp.extraConfig = ''
    START_CHARGE_THRESH_BAT0=80
  '';

  nix = {
    buildCores = 2;
    maxJobs = 2;
    daemonIONiceLevel = 1;
    daemonNiceLevel = 1;
  };

  services.logind.extraConfig = ''
    HandleHibernateKey=ignore
    HandleLidSwitch=ignore
    HandlePowerKey=ignore
    HandleSuspendKey=ignore
  '';

  services.xserver = {
    videoDriver = "intel";
  };
}
