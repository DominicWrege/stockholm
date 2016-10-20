{ config, lib, pkgs, ... }:

with import <stockholm/lib>;

{
  krebs.tinc.retiolum = {
    enable = true;
    connectTo = filter (ne config.krebs.build.host.name) [
      "gum"
      "prism"
      "echelon"
      "cd"
      "ire"
    ];
    tincPackage = pkgs.tinc_pre;
  };
  tv.iptables.input-internet-accept-tcp = singleton "tinc";
  tv.iptables.input-internet-accept-udp = singleton "tinc";
}
