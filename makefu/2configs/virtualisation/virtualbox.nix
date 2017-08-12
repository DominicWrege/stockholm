{ config, lib, pkgs, ... }:

let
  mainUser = config.krebs.build.user;
  vboxguestpkg =  lib.stdenv.mkDerivation rec {
    name = "Virtualbox-Extensions-${version}-${rev}";
    version = "5.0.20";
    rev = "106931";
    src = pkgs.fetchurl {
        url = "http://download.virtualbox.org/virtualbox/${version}/Oracle_VM_VirtualBox_Extension_Pack-${version}-${rev}.vbox-extpack";
        sha256 = "1dc70x2m7x266zzw5vw36mxqj7xykkbk357fc77f9zrv4lylzvaf";
      };
  };
in {
  virtualisation.virtualbox.host.enable = true;
  nixpkgs.config.virtualbox.enableExtensionPack = true;
  virtualisation.virtualbox.host.enableHardening = false;

  users.extraGroups.vboxusers.members = [ "${mainUser.name}" ];
  nixpkgs.config.packageOverrides = super: {
    boot.kernelPackages.virtualbox = super.boot.kernelPackages.virtualbox.override {
      buildInputs = super.boot.kernelPackages.virtualBox.buildInputs
        ++ [ vboxguestpkg ];
    };
  };
}