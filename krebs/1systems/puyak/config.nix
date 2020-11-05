{ config, pkgs, ... }:

{
  imports = [
    <stockholm/krebs>
    <stockholm/krebs/2configs>
    <stockholm/krebs/2configs/secret-passwords.nix>
    <stockholm/krebs/2configs/hw/x220.nix>


    ## initrd unlocking
    # (brain hosts/puyak/luks-ssd;echo)  | ssh root@$(brain krebs-secrets/puyak/initrd/hostname) 'cat > /crypt-ramfs/passphrase'
    <stockholm/krebs/2configs/tor/initrd.nix>

    <stockholm/krebs/2configs/binary-cache/nixos.nix>
    <stockholm/krebs/2configs/binary-cache/prism.nix>
    <stockholm/krebs/2configs/go.nix>
    <stockholm/krebs/2configs/ircd.nix>
    <stockholm/krebs/2configs/news.nix>
    <stockholm/krebs/2configs/news-spam.nix>

    ###   shackspace
    # handle the worlddomination map via coap
    <stockholm/krebs/2configs/shack/worlddomination.nix>
    <stockholm/krebs/2configs/shack/ssh-keys.nix>

    # drivedroid.shack for shackphone
    <stockholm/krebs/2configs/shack/drivedroid.nix>
    # <stockholm/krebs/2configs/shack/nix-cacher.nix>
    # Say if muell will be collected
    <stockholm/krebs/2configs/shack/muell_caller.nix>
    # provide muellshack api
    <stockholm/krebs/2configs/shack/muellshack.nix>
    # provide light control api
    <stockholm/krebs/2configs/shack/node-light.nix>
    # light.shack web-ui
    <stockholm/krebs/2configs/shack/light.shack.nix>
    # send mail if muell was not handled
    <stockholm/krebs/2configs/shack/muell_mail.nix>
    # send mail if muell was not handled
    <stockholm/krebs/2configs/shack/s3-power.nix>
    # powerraw usb serial to mqtt and raw socket
    <stockholm/krebs/2configs/shack/powerraw.nix>

    { # do not log to /var/spool/log
      services.nginx.appendHttpConfig = ''
          map $request_method $loggable {
            default 1;
            GET 0;
          }
          log_format vhost '$host $remote_addr - $remote_user '
                     '[$time_local] "$request" $status '
                     '$body_bytes_sent "$http_referer" '
                     '"$http_user_agent"';
          error_log stderr;
          access_log syslog:server=unix:/dev/log vhost;
      '';
      services.journald.rateLimitBurst = 10000;
    }

    # create samba share for anonymous usage with the laser and 3d printer pc
    <stockholm/krebs/2configs/shack/share.nix>

    # mobile.lounge.mpd.shack
    <stockholm/krebs/2configs/shack/mobile.mpd.nix>

    # hass.shack
    <stockholm/krebs/2configs/shack/glados>

    # connect to git.shackspace.de as group runner for rz
    <stockholm/krebs/2configs/shack/gitlab-runner.nix>

    # Statistics collection and visualization
    # <stockholm/krebs/2configs/shack/graphite.nix> # graphiteApi is broken and unused(hopefully)
    ## Collect data from mqtt.shack and store in graphite database
    <stockholm/krebs/2configs/shack/mqtt_sub.nix>
    ## Collect radioactive data and put into graphite
    <stockholm/krebs/2configs/shack/radioactive.nix>
    ## mqtt.shack
    <stockholm/krebs/2configs/shack/mqtt.nix>
    ## influx.shack
    <stockholm/krebs/2configs/shack/influx.nix>

    ## Collect local statistics via collectd and send to collectd
    <stockholm/krebs/2configs/stats/shack-client.nix>
    <stockholm/krebs/2configs/stats/shack-debugging.nix>

    ## netbox.shack: Netbox is disabled as nobody seems to be using it anyway
    # <stockholm/krebs/2configs/shack/netbox.nix>

    # grafana.shack
    <stockholm/krebs/2configs/shack/grafana.nix>

    # shackdns.shack
    # replacement for leases.shack and shackles.shack
    <stockholm/krebs/2configs/shack/shackDNS.nix>

    # monitoring: prometheus.shack
    <stockholm/krebs/2configs/shack/prometheus/node.nix>
    <stockholm/krebs/2configs/shack/prometheus/server.nix>
    <stockholm/krebs/2configs/shack/prometheus/blackbox.nix>
    <stockholm/krebs/2configs/shack/prometheus/unifi.nix>
    <stockholm/krebs/2configs/shack/prometheus/alertmanager-telegram.nix>

    ## Collect local statistics via collectd and send to collectd
    <stockholm/krebs/2configs/stats/shack-client.nix>
    <stockholm/krebs/2configs/stats/shack-debugging.nix>
  ];

  krebs.build.host = config.krebs.hosts.puyak;
  sound.enable = false;

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    initrd.luks.devices.luksroot.device = "/dev/sda3";
    initrd.luks.cryptoModules = [ "aes" "sha512" "sha1" "xts" ];
    initrd.availableKernelModules = [ "xhci_hcd" "ehci_pci" "ahci" "usb_storage" ];

    kernelModules = [ "kvm-intel" ];
    extraModprobeConfig = ''
      options thinkpad_acpi fan_control=1
    '';
  };

  fileSystems = {
    "/" = {
      device = "/dev/mapper/pool-root";
      fsType = "btrfs";
      options = ["defaults" "noatime" "ssd" "compress=lzo"];
    };
    "/boot" = {
      device = "/dev/sda2";
    };
    "/bku" = {
      device = "/dev/mapper/pool-bku";
      fsType = "btrfs";
      options = ["defaults" "noatime" "ssd" "compress=lzo"];
    };
    "/home" = {
      device = "/dev/mapper/pool-home";
      fsType = "btrfs";
      options = ["defaults" "noatime" "ssd" "compress=lzo"];
    };
    "/tmp" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = ["nosuid" "nodev" "noatime"];
    };
  };

  services.logind.lidSwitch = "ignore";
  services.logind.lidSwitchExternalPower = "ignore";


  services.udev.extraRules = ''
    SUBSYSTEM=="net", ATTR{address}=="8c:70:5a:b2:84:58", NAME="wl0"
    SUBSYSTEM=="net", ATTR{address}=="3c:97:0e:07:b9:14", NAME="et0"
  '';

  environment.systemPackages = [ pkgs.zsh ];

  system.activationScripts."disengage fancontrol" = ''
    echo level disengaged > /proc/acpi/ibm/fan
  '';

  users.users.joerg = {
    openssh.authorizedKeys.keys = [ config.krebs.users.mic92.pubkey ];
    isNormalUser = true;
    shell = "/run/current-system/sw/bin/zsh";
  };
  networking.firewall.allowedTCPPorts = [ 5901 ];
}
