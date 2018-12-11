with import <stockholm/lib>;
{ config, ... }: let

  hostDefaults = hostName: host: flip recursiveUpdate host ({
    owner = config.krebs.users.krebs;
  } // optionalAttrs (host.nets?retiolum) {
    nets.retiolum.ip6.addr =
      (krebs.genipv6 "retiolum" "krebs" { inherit hostName; }).address;
  });

  testHosts = genAttrs [
    "test-arch"
    "test-centos6"
    "test-centos7"
    "test-all-krebs-modules"
  ] (name: {
    inherit name;
    cores = 1;
    nets = {
      retiolum = {
        ip4.addr = "10.243.73.57";
        tinc.pubkey = ''
          -----BEGIN RSA PUBLIC KEY-----
          MIIBCgKCAQEAy41YKF/wpHLnN370MSdnAo63QUW30aw+6O79cnaJyxoL6ZQkk4Nd
          mrX2tBIfb2hhhgm4Jecy33WVymoEL7EiRZ6gshJaYwte51Jnrac6IFQyiRGMqHY5
          TG/6IzzTOkeQrT1fw3Yfh0NRfqLBZLr0nAFoqgzIVRxvy+QO1gCU2UDKkQ/y5df1
          K+YsMipxU08dsOkPkmLdC/+vDaZiEdYljIS3Omd+ED5JmLM3MSs/ZPQ8xjkjEAy8
          QqD9/67bDoeXyg1ZxED2n0+aRKtU/CK/66Li//yev6yv38OQSEM4t/V0dr9sjLcY
          VIdkxKf96F9r3vcDf/9xw2HrqVoy+D5XYQIDAQAB
          -----END RSA PUBLIC KEY-----
        '';
      };
    };
  });
in {
  hosts = mapAttrs hostDefaults {
    hotdog = {
      ci = true;
      nets = {
        retiolum = {
          ip4.addr = "10.243.77.3";
          aliases = [
            "hotdog.r"
            "build.r"
            "build.hotdog.r"
            "cgit.hotdog.r"
            "irc.r"
          ];
          tinc.pubkey = ''
            -----BEGIN RSA PUBLIC KEY-----
            MIIBCgKCAQEAs9+Au3oj29C5ol/YnkG9GjfCH5z53wxjH2iy8UPike8C7GASZKqc
            bZBrvxkIOyVs5oVtolPcaI0/nvtpIhSlmM6hg9qe1rZO6jXt53GVNvgdcUIfVHbX
            mQmp4oVXOjPIeDqLn32Mc0O73Kp6i66zQGAXi8ejczuO0h6oSvAnjolT4wM9jugk
            JBGCDlpl9mxAGDN5VOqbg2i0FxwtUk2UA9XghEaRcfBkVdsOrtW8sCwOg8YttQt9
            fs7JjezUtw7JBxN754ynaahSRODcjyJhwjE18tKx6P7wsNbgbmULFQz+7IxZ01/P
            h5ZUzfd1r1pTzQ0nYD5aRtlDd7zP7y5tUwIDAQAB
            -----END RSA PUBLIC KEY-----
          '';
        };
      };
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICxFkBln23wUxt4RhIHE3GvdKeBpJbjn++6maupHqUHp";
    };
    onebutton = {
      cores = 1;
      nets = {
        retiolum = {
          ip4.addr = "10.243.0.101";
          aliases = [
            "onebutton.r"
          ];
          tinc.pubkey = ''
            -----BEGIN PUBLIC KEY-----
            MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA11w6votRExwE0ZEiQmPa
            9WGNsMfNAZEd14iHaHCZH7UPQEH+cH/T6isGPpaysindroMnqFe9mUf/cdYChb6N
            aaFreApwGBQaJPUcdy4cfphrFpzmOClpOFuFbnV7ZvAk/wefBad3kUzsq/lK4HvB
            7nPKeOB9kljphLrkzuLL/h2yOenMpO2ZdvwxyWN8HKmUNgvpBQjIr+Hka6cgy7Gp
            pBVFHfSnad/eHeEvq91O/bHxrAxzH5N5DVagPDpkbiWYGl+0XVGP/h0CApr15Ael
            +j2pJYc0ZlaXIp4KmNRqbd/fLe52JLrWbnFX4rRuY/DhoMqK8kjECEZ7gLiNSpCC
            KlnlJ2LXX9c+d79ubzl5yLAJ3d6T4IJqkbAWJDuCrj821M9ZDk/qZwerayhrrvkF
            tMYkQoGSe8MvSOU0rTEoH5iSRwDC7M0XzUe4l8/yZLFyD4Prz/dq6coqANfk/tlE
            DnH3vDu9lmFvYrLcd6yDWzFfI3mWDJoUa6AKKoScCOaCkRfIM4Aew0i73+h1nJLO
            59AAbZIkDYyWs53QniIG4EQteI9y/9j/628nPAVj68V5oIN76RDXfFHWDWq4DxmU
            PpGVmoIKcKZmnl7RrDomRVpuGMdyQ+kCzIGH3XYe12v8Y5beHZBrd3OajgHZ/Tfp
            jP873cT6h0hsGm9glgOYho8CAwEAAQ==
            -----END PUBLIC KEY-----
          '';
        };
      };
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAcZg+iLaPZ0SpLM+nANxIjZC/RIsansjyutK0+gPhIe ";
    };
    puyak = {
      ci = true;
      nets = {
        retiolum = {
          ip4.addr = "10.243.77.2";
          aliases = [
            "puyak.r"
            "build.puyak.r"
            "cgit.puyak.r"
            "go.r"
          ];
          tinc.pubkey = ''
            -----BEGIN RSA PUBLIC KEY-----
            MIIBCgKCAQEAwwDvaVKSJmAi1fpbsmjLz1DQVTgqnx56GkHKbz5sHwAfPVQej955
            SwotAPBrOT5P3pZ52Pu326SR5nj9XWfN6GD0CkcDQddtRG5OOtUWlvkYzZraNh33
            p9l8TBgHJKogGe6umbs+4v7pWfbS0k708L2ttwY0ceju6RL6UqShIYB6qhDzwalU
            p8s7pypl7BwrsTwYkUGleIptiN78cYv/NHvXhvXBuVGz4J0tCH4GMvdTHCah1l1r
            zwEpKlAq0FD6bgYTJL94Tvxe2xzyr8c+xn1+XbJtMudGmrRjIHS6YupzO/Y2MO7w
            UkbMKDhYVhSPFEyk6PMm0SU9uAh4I1+8BQIDAQAB
            -----END RSA PUBLIC KEY-----
          '';
        };
      };
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPpVwKv9mQGfcn5oFwuitq+b6Dz4jBG9sGhVoCYFw5RY";
    };
    wolf = {
      ci = true;
      nets = {
        shack = {
          ip4.addr =  "10.42.2.150" ;
          aliases = [
            "wolf.shack"
            "graphite.shack"
            "acng.shack"
            "drivedroid.shack"
            "mobile.lounge.mpd.shack"
            "lounge.mpd.wolf.shack"
          ];
        };
        retiolum = {
          ip4.addr = "10.243.77.1";
          aliases = [
            "wolf.r"
            "build.wolf.r"
            "cgit.wolf.r"
            "lounge.mpd.wolf.r"
          ];
          tinc.pubkey = ''
            -----BEGIN RSA PUBLIC KEY-----
            MIIBCgKCAQEAzpXyEATt8+ElxPq650/fkboEC9RvTWqN6UIAl/R4Zu+uDhAZ2ekb
            HBjoSbRxu/0w2I37nwWUhEOemxGm4PXCgWrtO0jeRF4nVNYu3ZBppA3vuVALUWq7
            apxRUEL9FdsWQlXGo4PVd20dGaDTi8M/Ggo755MStVTY0rRLluxyPq6VAa015sNg
            4NOFuWm0NDn4e+qrahTCTiSjbCU8rWixm0GktV40kdg0QAiFbEcRhuXF1s9/yojk
            7JT/nFg6LELjWUSSNZnioj5oSfVbThDRelIld9VaAKBAZZ5/zy6T2XSeDfoepytH
            8aw6itEuTCy1M1DTiTG+12SPPw+ubG+NqQIDAQAB
            -----END RSA PUBLIC KEY-----
          '';
        };
      };
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
      ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKYMXMWZIK0jjnZDM9INiYAKcwjXs2241vew54K8veCR";
    };
  } // testHosts;
  users = {
    krebs = {
      pubkey = "lol"; # TODO krebs.users.krebs.pubkey should be unnecessary
    };
    hotdog-repo-sync = {
      name = "hotdog-repo-sync";
      mail = "spam@krebsco.de";
      pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILzTvaR3QqOD3oEEGHQzg/sRnNbKJnZYcV9htDvXmu53";
    };
    puyak-repo-sync = {
      name = "puyak-repo-sync";
      mail = "spam@krebsco.de";
      pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ+18mG/cV1YbR9PXzuu3ScyV9kENy08OXUntpmgh9H2";
    };
    wolf-repo-sync = {
      name = "wolf-repo-sync";
      mail = "spam@krebsco.de";
      pubkey = ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCwuAZB3wtAvBJFYh+gWdyGaZU4mtqM2dFXmh2rORlbXeh02msu1uv07ck1VKkQ4LgvCBcBsAOeVa1NTz99eLqutwgcqMCytvRNUCibcoEWwHObsK53KhDJj+zotwlFhnPPeK9+EpOP4ngh/tprJikttos5BwBwe2K+lfiid3fmVPZcTTYa77nCwijimMvWEx6CEjq1wiXMUc4+qcEn8Swbwomz/EEQdNE2hgoC3iMW9RqduTFdIJWnjVi0KaxenX9CvQRGbVK5SSu2gwzN59D/okQOCP6+p1gL5r3QRHSLSSRiEHctVQTkpKOifrtLZGSr5zArEmLd/cOVyssHQPCX repo-sync@wolf'';
    };
    buildbotSlave = {
      pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP7cre2crQMI6O4XtIfIiGl1GUqIi060fJlOQJgG0/NH";
    };
  };
}
