{ config, lib, pkgs, ... }:
let
  isVM = lib.any (mod: mod == "xen-blkfront" || mod == "virtio_console") config.boot.initrd.kernelModules;
in {

  krebs.iptables.tables.filter.INPUT.rules = [
    { predicate = "-i retiolum -p tcp --dport 9273"; target = "ACCEPT"; }
  ];

  systemd.services.telegraf.path = [ pkgs.nvme-cli ];

  services.telegraf = {
    enable = true;
    extraConfig = {
      agent.interval = "60s";
      inputs = {
        http_response = [
          { urls = [
              "http://localhost:8080/about/health/"
          ]; }
        ];
        prometheus.metric_version = 2;
        kernel_vmstat = { };
        # smart = lib.mkIf (!isVM) {
        #   path = pkgs.writeShellScript "smartctl" ''
        #     exec /run/wrappers/bin/sudo ${pkgs.smartmontools}/bin/smartctl "$@"
        #   '';
        # };
        system = { };
        mem = { };
        file = [{
          data_format = "influx";
          file_tag = "name";
          files = [ "/var/log/telegraf/*" ];
        }] ++ lib.optional (lib.any (fs: fs == "ext4") config.boot.supportedFilesystems) {
          name_override = "ext4_errors";
          files = [ "/sys/fs/ext4/*/errors_count" ];
          data_format = "value";
        };
        exec = lib.optionalAttrs (lib.any (fs: fs == "zfs") config.boot.supportedFilesystems) {
          ## Commands array
          commands = [
            (pkgs.writeScript "zpool-health" ''
              #!${pkgs.gawk}/bin/awk -f
              BEGIN {
                while ("${pkgs.zfs}/bin/zpool status" | getline) {
                  if ($1 ~ /pool:/) { printf "zpool_status,name=%s ", $2 }
                  if ($1 ~ /state:/) { printf " state=\"%s\",", $2 }
                  if ($1 ~ /errors:/) {
                    if (index($2, "No")) printf "errors=0i\n"; else printf "errors=%di\n", $2
                  }
                }
              }
            '')
          ];
          data_format = "influx";
        };
        systemd_units = { };
        swap = { };
        disk.tagdrop = {
          fstype = [ "tmpfs" "ramfs" "devtmpfs" "devfs" "iso9660" "overlay" "aufs" "squashfs" ];
          device = [ "rpc_pipefs" "lxcfs" "nsfs" "borgfs" ];
        };
        diskio = { };
      };
      outputs.prometheus_client = {
        listen = ":9273";
        metric_version = 2;
      };
    };
  };
}
