{ config, lib, pkgs, ... }:

with builtins;
with lib;

let
  cfg = config.lass.telegraf;

  out = {
    options.lass.telegraf = api;
    config = mkIf cfg.enable imp;
  };

  api = {
    enable = mkEnableOption "telegraf";
    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/telegraf";
    };
    user = mkOption {
      type = types.str;
      default = "telegraf";
    };
    config = mkOption {
      type = types.str;
      #TODO: find a good default
      default = ''
        [agent]
            interval = "1s"

        [outputs]

        # Configuration to send data to InfluxDB.
        [outputs.influxdb]
            urls = ["http://localhost:8086"]
            database = "kapacitor_example"
            user_agent = "telegraf"

        # Collect metrics about cpu usage
        [cpu]
            percpu = false
            totalcpu = true
            drop = ["cpu_time"]
      '';
      description = "configuration telegraf is started with";
    };
  };

  configFile = pkgs.writeText "telegraf.conf" cfg.config;

  imp = {

    systemd.services.telegraf = {
      description = "telegraf";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      restartIfChanged = true;

      serviceConfig = {
        Restart = "always";
        ExecStart = "${pkgs.telegraf}/bin/telegraf -config ${configFile}";
      };
    };
  };

in out
