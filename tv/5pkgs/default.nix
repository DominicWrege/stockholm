with import <stockholm/lib>;

self: super:

# Import files and subdirectories like they are overlays.
foldl' mergeAttrs {}
  (map
    (name: import (./. + "/${name}") self super)
    (filter
      (name: name != "default.nix" && !hasPrefix "." name)
      (attrNames (readDir ./.))))

//

{
  cr = self.writeDashBin "cr" ''
    set -efu
    if test -n "''${XDG_RUNTIME_DIR-}"; then
      cache_dir=$XDG_RUNTIME_DIR/chromium-disk-cache
    else
      cache_dir=/tmp/chromium-disk-cache_$LOGNAME
    fi
    export LC_TIME=de_DE.utf8
    exec ${self.chromium}/bin/chromium \
        --ssl-version-min=tls1 \
        --disk-cache-dir="$cache_dir" \
        --disk-cache-size=50000000 \
        "$@"
  '';

  dhcpcd = overrideDerivation super.dhcpcd (old: {
    configureFlags = old.configureFlags ++ [
      "--dbdir=/var/lib/dhcpcd"
    ];
  });

  gitAndTools = super.gitAndTools // {
    inherit (self) diff-so-fancy;
  };

  ff = self.writeDashBin "ff" ''
    exec ${self.firefoxWrapper}/bin/firefox "$@"
  '';

  gnupg = self.gnupg22;

}
