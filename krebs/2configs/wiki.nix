{ config, pkgs, ... }:
with import <stockholm/lib>;
let

  setupGit = ''
    export PATH=${makeBinPath [ pkgs.git ]}
    export GIT_SSH_COMMAND='${pkgs.openssh}/bin/ssh -i ${config.krebs.gollum.stateDir}/.ssh/id_ed25519'
    repo='git@localhost:wiki'
    cd ${config.krebs.gollum.stateDir}
    if ! url=$(git config remote.origin.url); then
      git remote add origin "$repo"
    elif test "$url" != "$repo"; then
      git remote set-url origin "$repo"
    fi
  '';

  pushGollum = pkgs.writeDash "push_gollum" ''
    ${setupGit}
    git fetch origin
    git merge --ff-only origin/master
  '';

  pushCgit = pkgs.writeDash "push_cgit" ''
    ${setupGit}
    git push origin master
  '';

in
{
  services.gollum = {
    enable = true;
    extraConfig = ''
      Gollum::Hook.register(:post_commit, :hook_id) do |committer, sha1|
        system('${pushCgit}')
      end
    '';
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
  services.nginx = {
    enable = true;
    virtualHosts.wiki = {
      serverAliases = [ "wiki.r" "wiki.${config.networking.hostName}.r" ];
      locations."/".extraConfig = ''
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_pass http://127.0.0.1:${toString config.services.gollum.port};
      '';
    };
  };

  krebs.git = {
    enable = true;
    cgit.settings = {
      root-title = "krebs repos";
    };
    rules = with git; [
      {
        user = [
          {
            name = "gollum";
            pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMXbjDnQWg8EECsNRZZWezocMIiuENhCSQFcFUXcsOQ6";
          }
        ] ++ (attrValues config.krebs.users);
        repo = [ config.krebs.git.repos.wiki ];
        perm = push ''refs/heads/master'' [ create merge ];
      }
    ];
    repos.wiki = {
      public = true;
      name = "wiki";
      hooks = {
        post-receive = ''
          ${pkgs.git-hooks.irc-announce {
            channel = "#xxx";
            refs = [
              "refs/heads/master"
            ];
            nick = config.networking.hostName;
            server = "irc.r";
            verbose = true;
          }}
          /run/wrappers/bin/sudo -S -u gollum ${pushGollum}
        '';
      };
    };
  };

  krebs.secret.files.gollum = {
    path = "${config.krebs.gollum.stateDir}/.ssh/id_ed25519";
    owner = { name = "gollum"; };
    source-path = "${<secrets/gollum.id_ed25519>}";
  };

  security.sudo.extraConfig = ''
    git ALL=(gollum) NOPASSWD: ${pushGollum}
  '';
}
