{ pkgs }:
pkgs.symlinkJoin {
  name = "cyberlocker-tools";
  paths = [
    (pkgs.writers.writeDashBin "cput" ''
      set -efu
      path=''${1:-$(hostname)}

      ${pkgs.curl}/bin/curl -fSs --data-binary @- "http://c.r/$path"
      echo "http://c.r/$path"
    '')
    (pkgs.writers.writeDashBin "cdel" ''
      set -efu
      path=$1

      ${pkgs.curl}/bin/curl -f -X DELETE "http://c.r/$path"
    '')
  ];
}
