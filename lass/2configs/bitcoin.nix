{ config, pkgs, ... }:

let
  mainUser = config.users.extraUsers.mainUser;
in {

  krebs.per-user.bch.packages = [
    pkgs.electron-cash
  ];
  krebs.per-user.bitcoin.packages = [
    pkgs.electrum
  ];
  users.extraUsers = {
    bch = {
      name = "bch";
      description = "user for bch stuff";
      home = "/home/bch";
      useDefaultShell = true;
      createHome = true;
    };
    bitcoin = {
      name = "bitcoin";
      description = "user for bitcoin stuff";
      home = "/home/bitcoin";
      useDefaultShell = true;
      createHome = true;
    };
  };
  security.sudo.extraConfig = ''
    ${mainUser.name} ALL=(bitcoin) NOPASSWD: ALL
    ${mainUser.name} ALL=(bch) NOPASSWD: ALL
  '';
}
