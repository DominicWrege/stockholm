{ config, pkgs, ... }@args:
with config.krebs.lib;
let
  # TODO krebs.build.user
  user = config.users.users.tv;
in {

  environment.systemPackages = [
    pkgs.ff
    pkgs.gitAndTools.qgit
    pkgs.mpv
    pkgs.sxiv
    pkgs.xsel
    pkgs.zathura
  ];

  fonts.fonts = [
    pkgs.xlibs.fontschumachermisc
  ];

  # TODO dedicated group, i.e. with a single user
  # TODO krebs.setuid.slock.path vs /var/setuid-wrappers
  krebs.setuid.slock = {
    filename = "${pkgs.slock}/bin/slock";
    group = "wheel";
    envp = {
      DISPLAY = ":${toString config.services.xserver.display}";
      USER = user.name;
    };
  };

  services.xserver = {
    enable = true;
    display = 11;
    tty = 11;

    synaptics = {
      enable = true;
      twoFingerScroll = true;
      accelFactor = "0.035";
    };
  };

  systemd.services.display-manager.enable = false;

  systemd.services.xmonad = {
    wantedBy = [ "multi-user.target" ];
    requires = [ "xserver.service" ];
    environment = {
      DISPLAY = ":${toString config.services.xserver.display}";

      XMONAD_STARTUP_HOOK = pkgs.writeDash "xmonad-startup-hook" ''
        ${pkgs.xorg.xhost}/bin/xhost +LOCAL: &
        ${pkgs.xorg.xmodmap}/bin/xmodmap ${import ./Xmodmap.nix args} &
        ${pkgs.xorg.xrdb}/bin/xrdb -merge ${import ./Xresources.nix args} &
        ${pkgs.xorg.xsetroot}/bin/xsetroot -solid '#1c1c1c' &
        wait
      '';

      XMONAD_STATE = "/tmp/xmonad.state";

      # XXX JSON is close enough :)
      XMONAD_WORKSPACES0_FILE = pkgs.writeText "xmonad.workspaces0" (toJSON [
        "Dashboard" # we start here
        "23"
        "cr"
        "ff"
        "hack"
        "im"
        "mail"
        "stockholm"
        "za" "zh" "zj" "zs"
      ]);
    };
    serviceConfig = {
      ExecStart = "${pkgs.xmonad-tv}/bin/xmonad-tv";
      ExecStop = "${pkgs.xmonad-tv}/bin/xmonad-tv --shutdown";
      User = user.name;
      WorkingDirectory = user.home;
    };
  };

  systemd.services.xserver = {
    after = [
      "systemd-udev-settle.service"
      "local-fs.target"
      "acpid.service"
    ];
    reloadIfChanged = true;
    environment = {
      XKB_BINDIR = "${pkgs.xorg.xkbcomp}/bin"; # Needed for the Xkb extension.
      XORG_DRI_DRIVER_PATH = "/run/opengl-driver/lib/dri"; # !!! Depends on the driver selected at runtime.
      LD_LIBRARY_PATH = concatStringsSep ":" (
        [ "${pkgs.xorg.libX11}/lib" "${pkgs.xorg.libXext}/lib" ]
        ++ concatLists (catAttrs "libPath" config.services.xserver.drivers));
    };
    serviceConfig = {
      SyslogIdentifier = "xserver";
      ExecReload = "${pkgs.need-reload}/bin/need-reload xserver.service";
      ExecStart = toString [
        "${pkgs.xorg.xorgserver}/bin/X"
        ":${toString config.services.xserver.display}"
        "vt${toString config.services.xserver.tty}"
        "-config ${import ./xserver.conf.nix args}"
        "-logfile /var/log/X.${toString config.services.xserver.display}.log"
        "-nolisten tcp"
        "-xkbdir ${pkgs.xkeyboard_config}/etc/X11/xkb"
      ];
    };
  };

  systemd.services.urxvtd = {
    wantedBy = [ "multi-user.target" ];
    reloadIfChanged = true;
    serviceConfig = {
      ExecReload = "${pkgs.need-reload}/bin/need-reload urxvtd.service";
      ExecStart = "${pkgs.rxvt_unicode}/bin/urxvtd";
      Restart = "always";
      RestartSec = "2s";
      StartLimitBurst = 0;
      User = user.name;
    };
  };
}
