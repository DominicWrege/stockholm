{ config, pkgs, ... }: with import <stockholm/lib>; let
  mk_peers = mapAttrs (n: v: { id = v.syncthing.id; });

  all_peers = filterAttrs (n: v: v.syncthing.id != null) config.krebs.hosts;
  used_peer_names = unique (flatten (mapAttrsToList (n: v: v.devices) config.services.syncthing.declarative.folders));
  used_peers = filterAttrs (n: v: elem n used_peer_names) all_peers;
in {
  services.syncthing = {
    enable = true;
    configDir = "/var/lib/syncthing";
    declarative = {
      devices = mk_peers used_peers;
    };
  };
}
