{ config, lib, pkgs, ... }:

let
  pkg = pkgs.callPackage (
    pkgs.fetchgit {
      url = "https://git.shackspace.de/rz/muell_mail";
      rev = "c3e43687879f95e01a82ef176fa15678543b2eb8";
      sha256 = "0hgchwam5ma96s2v6mx2jfkh833psadmisjbm3k3153rlxp46frx";
    }) { mkYarnPackage = pkgs.yarn2nix-moretea.mkYarnPackage; };
    home = "/var/lib/muell_mail";
    cfg = toString <secrets/shack/muell_mail.js>;
in {
  users.users.muell_mail = {
    inherit home;
    createHome = true;
  };
  systemd.services.muell_mail = {
    description = "muell_mail";
    wantedBy = [ "multi-user.target" ];
    environment.CONFIG = "${home}/muell_mail.js";
    serviceConfig = {
      User = "muell_mail";
      ExecStartPre = pkgs.writeDash "muell_mail-pre" ''
        install -D -omuell_mail -m700 ${cfg} ${home}/muell_mail.js
      '';
      WorkingDirectory = home;
      PermissionsStartOnly = true;
      ExecStart = "${pkg}/bin/muell_mail";
      PrivateTmp = true;
      Restart = "always";
      RestartSec = "15";
    };
  };
}
