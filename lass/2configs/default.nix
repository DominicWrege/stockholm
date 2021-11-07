with import <stockholm/lib>;
{ config, pkgs, ... }:
{
  imports = [
    ./binary-cache/client.nix
    ./gc.nix
    ./mc.nix
    ./vim.nix
    ./zsh.nix
    ./htop.nix
    ./security-workarounds.nix
    ./wiregrill.nix
    {
      users.extraUsers =
        mapAttrs (_: h: { hashedPassword = h; })
                 (import <secrets/hashedPasswords.nix>);
    }
    {
      users.extraUsers = {
        root = {
          openssh.authorizedKeys.keys = [
            config.krebs.users.lass.pubkey
            config.krebs.users.lass-blue.pubkey
            config.krebs.users.lass-green.pubkey
          ];
        };
        mainUser = {
          name = "lass";
          uid = 1337;
          home = "/home/lass";
          group = "users";
          createHome = true;
          useDefaultShell = true;
          isNormalUser = true;
          extraGroups = [
            "audio"
            "video"
            "fuse"
            "wheel"
          ];
          openssh.authorizedKeys.keys = [
            config.krebs.users.lass.pubkey
            config.krebs.users.lass-blue.pubkey
            config.krebs.users.lass-green.pubkey
          ];
        };
      };
    }
    {
      environment.variables = {
        NIX_PATH = mkForce "secrets=/var/src/stockholm/null:/var/src";
      };
    }
    (let ca-bundle = "/etc/ssl/certs/ca-bundle.crt"; in {
      environment.variables = {
        CURL_CA_BUNDLE = ca-bundle;
        GIT_SSL_CAINFO = ca-bundle;
        SSL_CERT_FILE = ca-bundle;
      };
    })
    {
      #for sshuttle
      environment.systemPackages = [
        pkgs.python3Packages.python
      ];
    }
  ];

  networking.hostName = config.krebs.build.host.name;
  nix.maxJobs = config.krebs.build.host.cores;

  krebs = {
    enable = true;
    build.user = config.krebs.users.lass;
  };

  nix.useSandbox = true;

  users.mutableUsers = false;

  services.timesyncd.enable = mkForce true;

  # multiple-definition-problem when defining environment.variables.EDITOR
  environment.extraInit = ''
    EDITOR=vim
  '';

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
  #stockholm
    deploy
    git
    git-preview
    gnumake
    jq

  #style
    rxvt_unicode.terminfo

  #monitoring tools
    htop
    iotop

  #network
    iptables
    iftop
    tcpdump
    mosh
    sshify

  #stuff for dl
    aria2

  #neat utils
    file
    hashPassword
    kpaste
    cyberlocker-tools
    pciutils
    pop
    q
    rs
    untilport
    usbutils
    logify
    goify

  #unpack stuff
    libarchive

    (pkgs.writeDashBin "sshn" ''
      ${pkgs.openssh}/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$@"
    '')
  ];

  environment.shellAliases = {
    ll = "ls -l";
    la = "ls -la";
    ls = "ls --color";
    ip = "ip -color=auto";
    grep = "grep --color=auto";
  };

  programs.bash = {
    enableCompletion = true;
    interactiveShellInit = ''
      HISTCONTROL='erasedups:ignorespace'
      HISTSIZE=65536
      HISTFILESIZE=$HISTSIZE

      shopt -s checkhash
      shopt -s histappend histreedit histverify
      shopt -s no_empty_cmd_completion
      complete -d cd
      LS_COLORS=$LS_COLORS:'di=1;31:' ; export LS_COLORS
    '';
    promptInit = ''
      if test $UID = 0; then
        PS1='\[\033[1;31m\]\w\[\033[0m\] '
        PROMPT_COMMAND='echo -ne "\033]0;$$ $USER@$PWD\007"'
      elif test $UID = 1337; then
        PS1='\[\033[1;32m\]\w\[\033[0m\] '
        PROMPT_COMMAND='echo -ne "\033]0;$$ $PWD\007"'
      else
        PS1='\[\033[1;33m\]\u@\w\[\033[0m\] '
        PROMPT_COMMAND='echo -ne "\033]0;$$ $USER@$PWD\007"'
      fi
      if test -n "$SSH_CLIENT"; then
        PS1='\[\033[35m\]\h'" $PS1"
        PROMPT_COMMAND='echo -ne "\033]0;$$ $HOSTNAME $USER@$PWD\007"'
      fi
    '';
  };

  services.openssh.enable = true;

  services.journald.extraConfig = ''
    SystemMaxUse=1G
    RuntimeMaxUse=128M
    Storage=persistent
  '';

  krebs.iptables = {
    enable = true;
    tables = {
      nat.PREROUTING.rules = [
        { predicate = "-i retiolum -p tcp -m tcp --dport 22"; target = "ACCEPT"; precedence = 101; }
        { predicate = "-i wiregrill -p tcp -m tcp --dport 22"; target = "ACCEPT"; precedence = 101; }
        { predicate = "-p tcp -m tcp --dport 22"; target = "REDIRECT --to-ports 0"; precedence = 100; }
        { predicate = "-p tcp -m tcp --dport 45621"; target = "REDIRECT --to-ports 22"; precedence = 99; }
      ];
      nat.OUTPUT.rules = [
        { predicate = "-o lo -p tcp -m tcp --dport 45621"; target = "REDIRECT --to-ports 22"; precedence = 100; }
      ];
      filter.INPUT.policy = "DROP";
      filter.FORWARD.policy = "DROP";
      filter.INPUT.rules = [
        { predicate = "-i retiolum -p udp --dport 60000:61000"; target = "ACCEPT";}
        { predicate = "-m conntrack --ctstate RELATED,ESTABLISHED"; target = "ACCEPT"; precedence = 10001; }
        { predicate = "-p icmp"; target = "ACCEPT"; precedence = 10000; }
        { predicate = "-p ipv6-icmp"; target = "ACCEPT"; v4 = false;  precedence = 10000; }
        { predicate = "-i lo"; target = "ACCEPT"; precedence = 9999; }
        { predicate = "-p tcp --dport 22"; target = "ACCEPT"; precedence = 9998; }
        { predicate = "-p tcp -i retiolum"; target = "REJECT --reject-with tcp-reset"; precedence = -10000; }
        { predicate = "-p udp -i retiolum"; target = "REJECT --reject-with icmp-port-unreachable"; v6 = false; precedence = -10000; }
        { predicate = "-i retiolum"; target = "REJECT --reject-with icmp-proto-unreachable"; v6 = false; precedence = -10000; }
        { predicate = "-i retiolum -p udp -m udp --dport 53"; target = "ACCEPT"; }
        { predicate = "-i retiolum -p tcp --dport 19999"; target = "ACCEPT"; }
      ];
    };
  };

  networking.dhcpcd.extraConfig = ''
    noipv4ll
  '';

  # use 24:00 time format, the default got sneakily changed around 20.03
  i18n.defaultLocale = mkDefault "C.UTF-8";
  time.timeZone = mkDefault"Europe/Berlin";

  system.stateVersion = mkDefault "20.03";
}
