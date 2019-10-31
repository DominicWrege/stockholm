{ config, lib, pkgs, ... }:

let
  pkg = pkgs.callPackage (
    pkgs.fetchgit {
      url = "https://git.shackspace.de/rz/s3-power";
      rev = "0687ab64";
      sha256 = "1m8h4bwykv24bbgr5v51mam4wsbp5424xcrawhs4izv563jjf130";
    }) { mkYarnPackage = pkgs.yarn2nix-moretea.mkYarnPackage; };

    home = "/var/lib/s3-power";
    cfg = toString <secrets/shack/s3-power.json>;
in {
  users.users.s3_power = {
    inherit home;
    createHome = true;
  };
  systemd.services.s3-power = {
    startAt = "daily";
    description = "s3-power";
    environment.CONFIG = "${home}/s3-power.json";
    serviceConfig = {
      Type = "oneshot";
      User = "s3_power";
      ExecStartPre = pkgs.writeDash "s3-power-pre" ''
        install -D -os3_power -m700 ${cfg} ${home}/s3-power.json
      '';
      WorkingDirectory = home;
      PermissionsStartOnly = true;
      ExecStart = "${pkg}/bin/s3-power";
      PrivateTmp = true;
    };
  };
}
