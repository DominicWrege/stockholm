{ config, lib, pkgs, ... }:

with import <stockholm/lib>;

let
  cfg = config.tv.umts;

  out = {
    options.tv.umts = api;
    config = lib.mkIf cfg.enable imp;
  };

  api = {
    enable = mkEnableOption "umts";
    modem = mkOption {
      type = types.str;
      default = "/dev/ttyUSB0";
    };
    initstrings = mkOption {
      type = types.str;
      default = ''
        Init1 = ATZ
        Init2 = ATQ0 V1 E1 S0=0 &C1 &D2
      '';
    };
    username = mkOption {
      type = types.str;
      default = "default";
    };
    password = mkOption {
      type = types.str;
      default = "default";
    };
    pppDefaults = mkOption {
      type = types.str;
      default = ''
        noipdefault
        usepeerdns
        defaultroute
        persist
        noauth
      '';
    };
  };

  nixpkgs-1509 = import (pkgs.fetchFromGitHub {
    owner = "NixOS"; repo = "nixpkgs-channels";
    rev = "91371c2bb6e20fc0df7a812332d99c38b21a2bda";
    sha256 = "1as1i0j9d2n3iap9b471y4x01561r2s3vmjc5281qinirlr4al73";
  }) {};

  wvdial = nixpkgs-1509.wvdial; # https://github.com/NixOS/nixpkgs/issues/16113

  umts-bin = pkgs.writeScriptBin "umts" ''
    #!/bin/sh
    set -euf
    systemctl start umts
    trap "systemctl stop umts;trap - INT TERM EXIT;exit" INT TERM EXIT
    echo nameserver 8.8.8.8 | tee -a /etc/resolv.conf
    journalctl -xfu umts
  '';

  wvdial-defaults = ''
    [Dialer Defaults]
    Modem = ${cfg.modem}
    ${cfg.initstrings}
    Modem Type = Analog Modem
    Baud = 460800
    phone= *99#
    Username = ${cfg.username}
    Password = ${cfg.password}
    Stupid Mode = 1
    Idle Seconds = 0
    PPPD Path = ${pkgs.ppp}/bin/pppd
  '';

  imp = {
    environment.shellAliases = {
      umts = "sudo ${umts-bin}/bin/umts";
    };

    environment.systemPackages = [
      pkgs.ppp
    ];

    security.sudo.extraConfig = ''
      tv ALL= (root) NOPASSWD: ${umts-bin}/bin/umts
    '';

    environment.etc = [
      {
        source = pkgs.writeText "wvdial.conf" wvdial-defaults;
        target = "wvdial.conf";
      }
      {
        source = pkgs.writeText "wvdial" cfg.pppDefaults;
        target = "ppp/peers/wvdial";
      }
    ];

    systemd.services.umts = {
      description = "UMTS wvdial Service";
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "10s";
        ExecStart = "${wvdial}/bin/wvdial -n";
      };
    };
  };

in out
