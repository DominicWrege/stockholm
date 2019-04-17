with import <stockholm/lib>;
{ config, pkgs, ... }:

{
  imports = [
    <stockholm/lass>

    <stockholm/lass/2configs/retiolum.nix>
    <stockholm/lass/2configs/backup.nix>
    <stockholm/lass/2configs/nfs-dl.nix>
    {
      # bubsy config
      users.users.bubsy = {
        uid = genid "bubsy";
        home = "/home/bubsy";
        group = "users";
        createHome = true;
        extraGroups = [
          "audio"
          "networkmanager"
        ];
        useDefaultShell = true;
      };
      networking.networkmanager.enable = true;
      networking.wireless.enable = mkForce false;
      hardware.pulseaudio = {
        enable = true;
        systemWide = true;
      };
      programs.chromium = {
        enable = true;
        extensions = [
          "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
        ];
      };
      environment.systemPackages = with pkgs; [
        pavucontrol
        #firefox
        chromium
        hexchat
        networkmanagerapplet
        libreoffice
        audacity
        zathura
        skype
        wine
        geeqie
        vlc
        minecraft
        zsnes
      ];
      nixpkgs.config.firefox.enableAdobeFlash = true;
      services.xserver.enable = true;
      services.xserver.displayManager.lightdm.enable = true;
      services.xserver.desktopManager.plasma5.enable = true;
      services.xserver.layout = "de";
    }
    {
      krebs.per-user.bitcoin.packages = [
        pkgs.electrum
      ];
      users.extraUsers = {
        bitcoin = {
          name = "bitcoin";
          description = "user for bitcoin stuff";
          home = "/home/bitcoin";
          isNormalUser = true;
          useDefaultShell = true;
          createHome = true;
          extraGroups = [ "audio" ];
        };
      };
      security.sudo.extraConfig = ''
        bubsy ALL=(bitcoin) NOPASSWD: ALL
      '';
    }
    {
      #remote control
      environment.systemPackages = with pkgs; [
        x11vnc
        torbrowser
      ];
      krebs.iptables.tables.filter.INPUT.rules = [
        { predicate = "-p tcp -i retiolum --dport 5900"; target = "ACCEPT"; }
      ];
    }
  ];

  time.timeZone = "Europe/Berlin";

  hardware.trackpoint = {
    enable = true;
    sensitivity = 220;
    speed = 0;
    emulateWheel = true;
  };

  services.logind.extraConfig = ''
    HandleLidSwitch=ignore
  '';

  krebs.build.host = config.krebs.hosts.daedalus;
}
