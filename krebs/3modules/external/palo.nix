with import <stockholm/lib>;
{ config, ... }: let

  hostDefaults = hostName: host: flip recursiveUpdate host ({
    ci = false;
    external = true;
    monitoring = false;
  } // optionalAttrs (host.nets?retiolum) {
    nets.retiolum.ip6.addr =
      (krebs.genipv6 "retiolum" "external" { inherit hostName; }).address;
  } // optionalAttrs (host.nets?wiregrill) {
    nets.wiregrill.ip6.addr =
      (krebs.genipv6 "wiregrill" "external" { inherit hostName; }).address;
  });
  ssh-for = name: builtins.readFile (./ssh + "/${name}.pub");
  tinc-for = name: builtins.readFile (./tinc + "/${name}.pub");

in {
  hosts = mapAttrs hostDefaults {
    pepe = {
      owner = config.krebs.users.palo;
      nets = {
        retiolum = {
          ip4.addr = "10.243.23.1";
          tinc.port = 720;
          aliases = [ "pepe.r" ];
          tinc.pubkey = tinc-for "palo";
        };
      };
    };
    schasch = {
      owner = config.krebs.users.palo;
      nets = {
        retiolum = {
          ip4.addr = "10.243.23.2";
          tinc.port = 720;
          aliases = [ "schasch.r" ];
          tinc.pubkey = tinc-for "palo";
        };
      };
      syncthing.id = "FLY7DHI-TJLEQBJ-JZNC4YV-NBX53Z2-ZBRWADL-BKSFXYZ-L4FMDVH-MOSEVAQ";
    };
    sterni = {
      owner = config.krebs.users.palo;
      nets = {
        retiolum = {
          ip4.addr = "10.243.23.3";
          tinc.port = 720;
          aliases = [
            "sterni.r"
          ];
          tinc.pubkey = tinc-for "palo";
        };
      };
    };
    workhorse = {
      owner = config.krebs.users.palo;
      nets = {
        retiolum = {
          ip4.addr = "10.243.23.5";
          tinc.port = 720;
          aliases = [ "workhorse.r" ];
          tinc.pubkey = tinc-for "palo";
        };
      };
    };
    workout = {
      owner = config.krebs.users.palo;
      nets = {
        retiolum = {
          ip4.addr = "10.243.23.4";
          tinc.port = 720;
          aliases = [ "workout.r" ];
          tinc.pubkey = tinc-for "palo";
        };
      };
    };
  };
  users = {
    palo = {
      pubkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6uza62+Go9sBFs3XZE2OkugBv9PJ7Yv8ebCskE5WYPcahMZIKkQw+zkGI8EGzOPJhQEv2xk+XBf2VOzj0Fto4nh8X5+Llb1nM+YxQPk1SVlwbNAlhh24L1w2vKtBtMy277MF4EP+caGceYP6gki5+DzlPUSdFSAEFFWgN1WPkiyUii15Xi3QuCMR8F18dbwVUYbT11vwNhdiAXWphrQG+yPguALBGR+21JM6fffOln3BhoDUp2poVc5Qe2EBuUbRUV3/fOU4HwWVKZ7KCFvLZBSVFutXCj5HuNWJ5T3RuuxJSmY5lYuFZx9gD+n+DAEJt30iXWcaJlmUqQB5awcB1S2d9pJ141V4vjiCMKUJHIdspFrI23rFNYD9k2ZXDA8VOnQE33BzmgF9xOVh6qr4G0oEpsNqJoKybVTUeSyl4+ifzdQANouvySgLJV/pcqaxX1srSDIUlcM2vDMWAs3ryCa0aAlmAVZIHgRhh6wa+IXW8gIYt+5biPWUuihJ4zGBEwkyVXXf2xsecMWCAGPWPDL0/fBfY9krNfC5M2sqxey2ShFIq+R/wMdaI7yVjUCF2QIUNiIdFbJL6bDrDyHnEXJJN+rAo23jUoTZZRv7Jq3DB/A5H7a73VCcblZyUmwMSlpg3wos7pdw5Ctta3zQPoxoAKGS1uZ+yTeZbPMmdbw==";
    };
  };
}

