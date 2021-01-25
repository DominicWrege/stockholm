{ config, lib, pkgs, ... }:

{
  imports = [
    <stockholm/krebs>
    <stockholm/krebs/2configs>

    <stockholm/krebs/2configs/ircd.nix>
    <stockholm/krebs/2configs/go.nix>

    #### NEWS ####
    <stockholm/krebs/2configs/ircd.nix>
    <stockholm/krebs/2configs/news.nix>
  ];

  krebs.build.host = config.krebs.hosts.news;

  boot.isContainer = true;
  networking.useDHCP = false;
  krebs.bindfs = {
    "/var/lib/htgen-go" = {
      source = "/var/state/htgen-go";
      options = [
        "-m ${toString config.users.users.htgen-go.uid}"
      ];
      clearTarget = true;
    };
    "/var/lib/brockman" = {
      source = "/var/state/brockman";
      options = [
        "-m ${toString config.users.users.brockman.uid}:${toString config.users.users.nginx.uid}"
      ];
      clearTarget = true;
    };
  };
}
