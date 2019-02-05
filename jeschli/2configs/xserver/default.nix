{ config, pkgs, ... }@args:
with import <stockholm/lib>;
let
  cfg = {
    cacheDir = cfg.dataDir;
    configDir = "/var/empty";
    dataDir = "/run/xdg/${cfg.user.name}/xmonad";
    user = config.krebs.users.jeschli;
  };
in {

  environment.systemPackages = [
    pkgs.font-size
    pkgs.gitAndTools.qgit
    pkgs.mpv
    pkgs.sxiv
    pkgs.xdotool
    pkgs.xsel
    pkgs.zathura
  ];

  fonts.fonts = [
    pkgs.xlibs.fontschumachermisc
  ];

  # TODO dedicated group, i.e. with a single user [per-user-setuid]
  # TODO krebs.setuid.slock.path vs /run/wrappers/bin
  krebs.setuid.slock = {
    filename = "${pkgs.slock}/bin/slock";
    group = "wheel";
    envp = {
      DISPLAY = ":${toString config.services.xserver.display}";
      USER = cfg.user.name;
    };
  };

  systemd.services.display-manager.enable = false;

  systemd.services.xmonad = {
    wantedBy = [ "multi-user.target" ];
    requires = [ "xserver.service" ];
    environment = {
      DISPLAY = ":${toString config.services.xserver.display}";

      XMONAD_CACHE_DIR = cfg.cacheDir;
      XMONAD_CONFIG_DIR = cfg.configDir;
      XMONAD_DATA_DIR = cfg.dataDir;

      XMONAD_STARTUP_HOOK = pkgs.writeDash "xmonad-startup-hook" ''
        ${pkgs.xorg.xhost}/bin/xhost +LOCAL: &
        ${pkgs.xorg.xmodmap}/bin/xmodmap ${import ./Xmodmap.nix args} &
        ${pkgs.xorg.xrdb}/bin/xrdb ${import ./Xresources.nix args} &
        ${pkgs.xorg.xsetroot}/bin/xsetroot -solid '#1c1c1c' &
        ${config.services.xserver.displayManager.sessionCommands}
        if test -z "$DBUS_SESSION_BUS_ADDRESS"; then
          exec ${pkgs.dbus.dbus-launch} --exit-with-session "$0" ""
        fi
        export DBUS_SESSION_BUS_ADDRESS
        ${config.systemd.package}/bin/systemctl --user import-environment DISPLAY DBUS_SESSION_BUS_ADDRESS
        wait
      '';

      # XXX JSON is close enough :)
      XMONAD_WORKSPACES0_FILE = pkgs.writeText "xmonad.workspaces0" (toJSON [
        "dashboard" # we start here
        "stockholm"
        "pycharm"
        "chromium"
        "iRC"
        "git"
        "hipbird"
      ]);
    };
    serviceConfig = {
      SyslogIdentifier = "xmonad";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${toString [
        "\${XMONAD_CACHE_DIR}"
        "\${XMONAD_CONFIG_DIR}"
        "\${XMONAD_DATA_DIR}"
      ]}";
      ExecStart = "${pkgs.xmonad-jeschli}/bin/xmonad";
      ExecStop = "${pkgs.xmonad-jeschli}/bin/xmonad --shutdown";
      User = cfg.user.name;
      WorkingDirectory = cfg.user.home;
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
      ExecReload = "${pkgs.coreutils}/bin/echo NOP";
      ExecStart = toString [
        "${pkgs.xorg.xorgserver}/bin/X"
        ":${toString config.services.xserver.display}"
        "vt${toString config.services.xserver.tty}"
        "-config ${import ./xserver.conf.nix args}"
        "-logfile /dev/null -logverbose 0 -verbose 3"
        "-nolisten tcp"
        "-xkbdir ${pkgs.xkeyboard_config}/etc/X11/xkb"
      ];
    };
  };

  systemd.services.urxvtd = {
    wantedBy = [ "multi-user.target" ];
    reloadIfChanged = true;
    serviceConfig = {
      SyslogIdentifier = "urxvtd";
      ExecReload = "${pkgs.coreutils}/bin/echo NOP";
      ExecStart = "${pkgs.rxvt_unicode}/bin/urxvtd";
      Restart = "always";
      RestartSec = "2s";
      StartLimitBurst = 0;
      User = cfg.user.name;
    };
  };
}
