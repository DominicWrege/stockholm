{ config, lib, pkgs, ... }:

with import <stockholm/lib>;

let

  out = {
    services.nginx.enable = true;
    krebs.git = {
      enable = true;
      cgit = {
        settings = {
          root-title = "public repositories at ${config.krebs.build.host.name}";
          root-desc = "keep calm and engage";
        };
      };
      repos = repos;
      rules = rules;
    };

    krebs.iptables.tables.filter.INPUT.rules = [
      { predicate = "-i retiolum -p tcp --dport 80"; target = "ACCEPT"; }
    ];
  };

  cgit-clear-cache = pkgs.cgit-clear-cache.override {
    inherit (config.krebs.git.cgit.settings) cache-root;
  };

  repos =
    public-repos //
    optionalAttrs config.krebs.build.host.secure restricted-repos;

  rules = concatMap make-rules (attrValues repos);

  public-repos = mapAttrs make-public-repo {
    Reaktor = {
      cgit.desc = "Reaktor IRC bot";
      cgit.section = "software";
    };
    buildbot-classic = {
      cgit.desc = "fork of buildbot";
      cgit.section = "software";
    };
    cholerab = {
      cgit.desc = "krebs thesauron & enterprise-patterns";
      cgit.section = "documentation";
    };
    disko = {
      cgit.desc = "take a description of your disk layout and produce a format script";
      cgit.section = "software";
    };
    krebspage = {
      cgit.desc = "homepage of krebs";
      cgit.section = "configuration";
    };
    news = {
      cgit.desc = "take a rss feed and a timeout and print it to stdout";
      cgit.section = "software";
    };
    nixpkgs = {
      cgit.desc = "nixpkgs fork";
      cgit.section = "configuration";
    };
    populate = {
      cgit.section = "software";
    };
    stockholm = {
      cgit.desc = "take all the computers hostage, they'll love you!";
      cgit.section = "configuration";
    };
    stockholm-issues = {
      cgit.desc = "stockholm issues";
      cgit.section = "issues";
    };
    the_playlist = {
      cgit.desc = "Good Music collection + tools";
      cgit.section  = "art";
    };
    nix-user-chroot = {
      cgit.desc = "Fork of nix-user-chroot by lethalman";
      cgit.section = "software";
    };
    krops = {
      cgit.desc = "krebs deployment";
      cgit.section = "software";
    };
    xmonad-stockholm = {
      cgit.desc = "krebs xmonad modules";
      cgit.section = "configuration";
    };
  } // mapAttrs make-public-repo-silent {
    nixos-aws = {
      collaborators = [ {
        name = "fabio";
        pubkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDFst8DvnfOu4pQJYxcwdf//jWTvP+jj0iSrOdt59c9Gbujm/8K1mBXhcSQhHj/GBRC1Qc1wipf9qZsWnEHMI+SRwq6tDr8gqlAcdWmHAs1bU96jJtc8EgmUKbXTFG/VmympMPi4cEbNUtH93v6NUjQKwq9szvDhhqSW4Y8zE32xLkySwobQapNaUrGAtQp3eTxu5Lkx+cEaaartaAspt8wSosXjUHUJktg0O5/XOP+CiWAx89AXxbQCy4XTQvUExoRGdw9sdu0lF0/A0dF4lFF/dDUS7+avY8MrKEcQ8Fwk8NcW1XrKMmCdNdpvou0whL9aHCdTJ+522dsSB1zZWh63Si4CrLKlc1TiGKCXdvzmCYrD+6WxbPJdRpMM4dFNtpAwhCm/dM+CBXfDkP0s5veFiYvp1ri+3hUqV/sep9r5/+d+5/R1gQs8WDNjWqcshveFbD5LxE6APEySB4QByGxIrw7gFbozE+PNxtlVP7bq4MyE6yIzL6ofQgO1e4THquPcqSCfCvyib5M2Q1phi5DETlMemWp84AsNkqbhRa4BGRycuOXXrBzE+RgQokcIY7t3xcu3q0xJo2+HxW/Lqi72zYU1NdT4nJMETEaG49FfIAnUuoVaQWWvOz8mQuVEmmdw2Yzo2ikILYSUdHTp1VPOeo6aNPvESkPw1eM0xDRlQ== ada";
      } ];
    };
  };

  restricted-repos = mapAttrs make-restricted-repo (
    {
      brain = {
        collaborators = with config.krebs.users; [ tv makefu ];
        announce = true;
      };
    } //
    import <secrets/repos.nix> { inherit config lib pkgs; }
  );

  make-public-repo = name: { cgit ? {}, collaborators ? [], ... }: {
    inherit cgit collaborators name;
    public = true;
    hooks = {
      post-receive = ''
        ${pkgs.git-hooks.irc-announce {
          # TODO make nick = config.krebs.build.host.name the default
          nick = config.krebs.build.host.name;
          channel = "#xxx";
          # TODO define refs in some kind of option per repo
          refs = [
            "refs/heads/master"
          ];
          server = "irc.r";
          verbose = config.krebs.build.host.name == "prism";
        }}
        ${cgit-clear-cache}/bin/cgit-clear-cache
      '';
    };
  };

  make-public-repo-silent = name: { cgit ? {}, ... }: {
    inherit cgit name;
    public = true;
  };

  make-restricted-repo = name: { admins ? [], collaborators ? [], announce ? false, hooks ? {}, ... }: {
    inherit admins collaborators name;
    public = false;
    hooks = {
      post-receive = ''
        ${optionalString announce (pkgs.git-hooks.irc-announce {
          # TODO make nick = config.krebs.build.host.name the default
          nick = config.krebs.build.host.name;
          channel = "#xxx";
          # TODO define refs in some kind of option per repo
          refs = [
            "refs/heads/master"
            "refs/heads/staging*"
          ];
          server = "irc.r";
          verbose = false;
        })}
        ${cgit-clear-cache}/bin/cgit-clear-cache
      '';
    } // hooks;
  };

  make-rules =
    with git // config.krebs.users;
    repo:
      singleton {
        user = [ lass lass-mors lass-shodan lass-icarus lass-blue ];
        repo = [ repo ];
        perm = push "refs/*" [ non-fast-forward create delete merge ];
      } ++
      optional (length (repo.admins or []) > 0) {
        user = repo.admins;
        repo = [ repo ];
        perm = push "refs/*" [ non-fast-forward create delete merge ];
      } ++
      optional (length (repo.collaborators or []) > 0) {
        user = repo.collaborators;
        repo = [ repo ];
        perm = fetch;
      } ++
      optional repo.public {
        user = attrValues config.krebs.users;
        repo = [ repo ];
        perm = fetch;
      };

in out
