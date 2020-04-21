{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let
  cfg = config.krebs.realwallpaper;

  out = {
    options.krebs.realwallpaper = api;
    config = lib.mkIf cfg.enable imp;
  };

  api = {
    enable = mkEnableOption "realwallpaper";

    workingDir = mkOption {
      type = types.str;
      default = "/var/realwallpaper/";
    };

    marker = mkOption {
      type = types.str;
      default = "http://graph.r/marker.json";
    };

    timerConfig = mkOption {
      type = types.unspecified;
      default = {
        OnCalendar = "*:0/15";
      };
    };
  };

  imp = {
    systemd.timers.realwallpaper = {
      description = "real wallpaper generator timer";
      wantedBy = [ "timers.target" ];

      timerConfig = cfg.timerConfig;
    };

    systemd.services.realwallpaper = {
      description = "real wallpaper generator";
      after = [ "network.target" ];

      path = with pkgs; [
        xplanet
        imagemagick
        inkscape
        curl
        file
        jq
      ];

      environment = {
        working_dir = cfg.workingDir;
        marker_url = cfg.marker;
      };

      restartIfChanged = true;

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.realwallpaper}/bin/generate-wallpaper";
        User = "realwallpaper";
      };
    };

    users.extraUsers.realwallpaper = {
      uid = genid "realwallpaper";
      home = cfg.workingDir;
      createHome = true;
    };
  };

in
out

