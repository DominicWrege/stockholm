{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [
    ./config.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  networking.hostId = "e0c335ea";
  boot.zfs.requestEncryptionCredentials = true;
  boot.zfs.enableUnstable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    # device = "/dev/disk/by-id/nvme-WDC_PC_SN730_SDBQNTY-1T00-1001_205349800040";
    device = "nodev";
    efiSupport = true;
    # efiInstallAsRemovable = true;
  };

  services.xserver.videoDrivers = [
    "amdgpu"
  ];

  hardware.opengl.extraPackages = [ pkgs.amdvlk ];
  # is required for amd graphics support ( xorg wont boot otherwise )
  boot.kernelPackages = pkgs.linuxPackages_latest;
  environment.variables.VK_ICD_FILENAMES =
    "/run/opengl-driver/share/vulkan/icd.d/amd_icd64.json";

  boot.initrd.availableKernelModules = [ "nvme" "ehci_pci" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.kernelModules = [ "kvm-amd" ];

  fileSystems."/" = {
    device = "zpool/root/root";
    fsType = "zfs";
  };

  fileSystems."/home" = {
    device = "zpool/root/home";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/50A7-1889";
    fsType = "vfat";
  };

  services.logind.lidSwitch = "ignore";
  services.logind.lidSwitchDocked = "ignore";
  boot.extraModprobeConfig = ''
    options psmouse proto=imps
  '';
}
