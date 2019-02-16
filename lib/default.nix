let
  nixpkgs-lib = import <nixpkgs/lib>;
  lib = with lib; nixpkgs-lib // builtins // {

    evalSource = import ./eval-source.nix;

    git = import ./git.nix { inherit lib; };
    krebs = import ./krebs lib;
    krops = import ../submodules/krops/lib;
    shell = import ./shell.nix { inherit lib; };
    types = nixpkgs-lib.types // import ./types.nix { inherit lib; };
    xml = import ./xml.nix { inherit lib; };

    eq = x: y: x == y;
    ne = x: y: x != y;
    mod = x: y: x - y * (x / y);

    genid = lib.genid_uint32; # TODO remove
    genid_uint31 = x: ((lib.genid_uint32 x) + 16777216) / 2;
    genid_uint32 = import ./genid.nix { inherit lib; };

    lpad = n: c: s:
      if lib.stringLength s < n
        then lib.lpad n c (c + s)
        else s;

    genAttrs' = names: f: listToAttrs (map f names);

    getAttrs = names: set:
      listToAttrs (map (name: nameValuePair name set.${name})
                       (filter (flip hasAttr set) names));

    test = re: x: isString x && testString re x;

    testString = re: x: match re x != null;

    toC = x: let
      type = typeOf x;
      reject = throw "cannot convert ${type}";
    in {
      list = "{ ${concatStringsSep ", " (map toC x)} }";
      null = "NULL";
      set = if isDerivation x then toJSON x else reject;
      string = toJSON x; # close enough
    }.${type} or reject;

    indent = replaceChars ["\n"] ["\n  "];

    mapNixDir = f: x: {
      list = foldl' mergeAttrs {} (map (mapNixDir1 f) x);
      path = mapNixDir1 f x;
    }.${typeOf x};

    mapNixDir1 = f: dirPath:
      listToAttrs
        (map
          (relPath: let
            name = removeSuffix ".nix" relPath;
            path = dirPath + "/${relPath}";
          in
            nameValuePair name (f path))
          (filter
            (name: name != "default.nix" && !hasPrefix "." name)
            (attrNames (readDir dirPath))));

    # https://tools.ietf.org/html/rfc5952
    normalize-ip6-addr =
      let
        max-run-0 =
          let
            both = v: { off = v; pos = v; };
            gt = a: b: a.pos - a.off > b.pos - b.off;

            chkmax = ctx: {
              cur = both (ctx.cur.pos + 1);
              max = if gt ctx.cur ctx.max then ctx.cur else ctx.max;
            };

            incpos = ctx: recursiveUpdate ctx {
              cur.pos = ctx.cur.pos + 1;
            };

            f = ctx: blk: (if blk == "0" then incpos else chkmax) ctx;
            z = { cur = both 0; max = both 0; };
          in
            blks: (chkmax (foldl' f z blks)).max;

        group-zeros = a:
          let
            blks = splitString ":" a;
            max = max-run-0 blks;
            lhs = take max.off blks;
            rhs = drop max.pos blks;
          in
            if max.pos == 0
              then a
              else let
                sep =
                  if 8 - (length lhs + length rhs) == 1
                    then ":0:"
                    else "::";
              in
                "${concatStringsSep ":" lhs}${sep}${concatStringsSep ":" rhs}";

        drop-leading-zeros =
          let
            f = block:
              let
                res = match "0*(.+)" block;
              in
                if res == null
                  then block # empty block
                  else elemAt res 0;
          in
            a: concatStringsSep ":" (map f (splitString ":" a));
      in
        a:
          toLower
            (if test ".*::.*" a
              then a
              else group-zeros (drop-leading-zeros a));

    hashToLength = n: s: substring 0 n (hashString "sha256" s);

    dropLast = n: xs: reverseList (drop n (reverseList xs));
    takeLast = n: xs: reverseList (take n (reverseList xs));

    # Split string into list of chunks where each chunk is at most n chars long.
    # The leftmost chunk might shorter.
    # Example: stringToGroupsOf "123456" -> ["12" "3456"]
    stringToGroupsOf = n: s: let
      acc =
        foldl'
          (acc: c: if stringLength acc.chunk < n then {
            chunk = acc.chunk + c;
            chunks = acc.chunks;
          } else {
            chunk = c;
            chunks = acc.chunks ++ [acc.chunk];
          })
          {
            chunk = "";
            chunks = [];
          }
          (stringToCharacters s);
    in
      filter (x: x != []) ([acc.chunk] ++ acc.chunks);

    warnOldVersion = oldName: newName:
      if compareVersions oldName newName != -1 then
        trace "Upstream `${oldName}' gets overridden by `${newName}'." newName
      else
        newName;
  };
in

lib
