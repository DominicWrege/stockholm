{ config, lib, pkgs, ... }:

{
  imports = [
    <stockholm/krebs>
    <stockholm/krebs/2configs>

    <stockholm/krebs/2configs/buildbot-stockholm.nix>
    <stockholm/krebs/2configs/binary-cache/nixos.nix>
    <stockholm/krebs/2configs/ircd.nix>
    <stockholm/krebs/2configs/reaktor2.nix>
    <stockholm/krebs/2configs/wiki.nix>
  ];

  krebs.build.host = config.krebs.hosts.hotdog;
  krebs.github-hosts-sync.enable = true;

  boot.isContainer = true;
  networking.useDHCP = false;
}
