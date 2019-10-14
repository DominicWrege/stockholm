{ config, pkgs, ... }:
{
  imports = [
    <stockholm/lass>

    <stockholm/lass/2configs/retiolum.nix>
    <stockholm/lass/2configs/baseX.nix>
    <stockholm/lass/2configs/browsers.nix>
    <stockholm/lass/2configs/programs.nix>
    <stockholm/lass/2configs/network-manager.nix>
    <stockholm/lass/2configs/mail.nix>
    <stockholm/lass/2configs/syncthing.nix>
  ];

  krebs.build.host = config.krebs.hosts.hilum;

  boot.loader.grub = {
    extraEntries = ''
      submenu isos {
        source /grub/autoiso.cfg
      }
    '';
    extraFiles."/grub/autoiso.cfg" = (pkgs.stdenv.mkDerivation {
      name = "autoiso.cfg";
      src = pkgs.grub2.src;
      phases = [ "unpackPhase" "installPhase" ];
      installPhase = ''
        cp docs/autoiso.cfg $out
      '';
    });
  };
}
