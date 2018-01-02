{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
{
  networking.wireless.enable = lib.mkDefault true;

  hardware.enableRedistributableFirmware = true;

  hardware.cpu.intel.updateMicrocode = true;

  hardware.opengl.enable = true;

  services.tlp.enable = true;

  boot = {
    kernelModules = [ "kvm-intel" "acpi_call" "tpm-rng" ];
    extraModulePackages = [ config.boot.kernelPackages.tp_smapi ];
    kernelParams = [ "acpi_backlight=none" ];
  };

  hardware.opengl.extraPackages = [
    pkgs.vaapiIntel
    pkgs.vaapiVdpau
  ];

  security.rngd.enable = mkDefault true;

  services.xserver = {
    videoDriver = "intel";
  };
}
