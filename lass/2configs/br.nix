with import <stockholm/lib>;
{ config, pkgs, ... }: {

  imports = [
    <nixpkgs/nixos/modules/services/hardware/sane_extra_backends/brscan4.nix>
  ];

  krebs.nixpkgs.allowUnfreePredicate = pkg: any (flip hasPrefix pkg.name) [
    "brother-udev-rule-type1-"
    "brscan4-"
    "mfcl2700dnlpr-"
  ];

  hardware.sane = {
    enable = true;
    brscan4 = {
      enable = true;
      netDevices = {
        bra = {
          model = "MFCL2700DN";
          ip = "10.23.42.221";
        };
      };
    };
  };

  services.saned.enable = true;

  # usage: scanimage -d "$(find-scanner bra)" --batch --format=tiff --resolution 150  -x 211 -y 298
  environment.systemPackages = [
    (pkgs.writeDashBin "find-scanner" ''
      set -efu
      name=$1
      ${pkgs.sane-backends}/bin/scanimage -f '%m %d
      ' \
      | ${pkgs.gawk}/bin/awk -v dev="*$name" '$1 == dev { print $2; exit }' \
      | ${pkgs.gnugrep}/bin/grep .
    '')
  ];

  services.printing = {
    enable = true;
    drivers = [
      pkgs.mfcl2700dncupswrapper
    ];
  };

}
