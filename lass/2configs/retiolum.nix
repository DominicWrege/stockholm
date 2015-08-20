{ ... }:

{
  imports = [
    ../3modules/iptables.nix
  ];

  lass.iptables = {
    tables = {
      filter.INPUT.rules = [
        { predicate = "-p tcp --dport smtp"; target = "ACCEPT"; }
        { predicate = "-p tcp --dport tinc"; target = "ACCEPT"; }
        { predicate = "-p udp --dport tinc"; target = "ACCEPT"; }
      ];
    };
  };

  krebs.retiolum = {
    enable = true;
    hosts = ../../Zhosts;
    connectTo = [
      "fastpoke"
      "cloudkrebs"
      "pigstarter"
      "gum"
      "flap"
    ];
  };
}
