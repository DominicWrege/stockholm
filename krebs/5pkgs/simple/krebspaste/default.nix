{ writeDashBin, bepasty-client-cli }:

# TODO use `pkgs.exec` instead?
writeDashBin "krebspaste" ''
  exec ${bepasty-client-cli}/bin/bepasty-cli -L 1m --url http://paste.r "$@" | sed '$ s/$/\/+inline/g'
''
