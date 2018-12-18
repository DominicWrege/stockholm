with import <stockholm/lib>;
{ config, pkgs, ... }: {

  imports = [
    <stockholm/tv>
    <stockholm/tv/2configs/br.nix>
    <stockholm/tv/2configs/exim-retiolum.nix>
    <stockholm/tv/2configs/hw/x220.nix>
    <stockholm/tv/2configs/retiolum.nix>
  ];

  krebs.build.host = config.krebs.hosts.mu;
  krebs.build.user = mkForce config.krebs.users.vv;

  tv.x0vncserver.enable = true;

  boot.initrd.luks.devices.muca.device = "/dev/sda2";
  boot.initrd.luks.cryptoModules = [ "aes" "sha512" "xts" ];
  boot.initrd.availableKernelModules = [ "ahci" ];
  boot.kernelModules = [ "fbcon" "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems = {
    "/" = {
      device = "/dev/mapper/muvga-root";
      fsType = "ext4";
      options = [ "defaults" "discard" ];
    };
    "/home" = {
      device = "/dev/mapper/muvga-home";
      fsType = "ext4";
      options = [ "defaults" "discard" ];
    };
    "/boot" = {
      device = "/dev/sda1";
      fsType = "vfat";
    };
  };

  nixpkgs.config.allowUnfree = true;
  hardware.opengl.driSupport32Bit = true;

  hardware.pulseaudio.enable = true;

  hardware.enableRedistributableFirmware = true;

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    chromium
    firefoxWrapper
    gimp
    iptables
    libreoffice
    plasma-pa
    (pkgs.pidgin-with-plugins.override {
      plugins = [ pkgs.pidginotr ];
    })
    skype
    slock
    tinc_pre
    vim
    xsane

    #foomatic_filters
    #gutenprint
    #cups_pdf_filter
    #ghostscript
  ];


  i18n.defaultLocale = "de_DE.UTF-8";

  programs.ssh.startAgent = false;

  security.wrappers = {
    slock.source = "${pkgs.slock}/bin/slock";
  };

  security.pam.loginLimits = [
    # for jack
    { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
    { domain = "@audio"; item = "rtprio"; type = "-"; value = "99"; }
  ];

  fonts.fonts = [
    pkgs.xlibs.fontschumachermisc
  ];

  services.xserver.enable = true;
  services.xserver.layout = "de";
  services.xserver.xkbOptions = "eurosign:e";

  # TODO this is host specific
  services.xserver.synaptics = {
    enable = true;
    twoFingerScroll = true;
  };

  services.xserver.desktopManager.plasma5 = {
    enable = true;
  };
  services.xserver.displayManager.auto = {
    enable = true;
    user = "vv";
  };

  users.users.vv = {
    inherit (config.krebs.users.vv) home uid;
    isNormalUser = true;
    extraGroups = [
      "audio"
      "video"
      "networkmanager"
    ];
  };
}
