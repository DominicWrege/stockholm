with import <stockholm/lib>;
{ config, pkgs, ... }:
let
  out = {
    options.krebs.tinc = api;
    config = imp;
  };

  api = mkOption {
    default = {};
    description = ''
      define a tinc network
    '';
    type = types.attrsOf (types.submodule (tinc: {
      options = let
        netname = tinc.config._module.args.name;
      in {

        enable = mkEnableOption "krebs.tinc.${netname}" // { default = true; };
        enableLegacy = mkEnableOption "/etc/tinc/${netname}";

        confDir = mkOption {
          type = types.package;
          default = pkgs.linkFarm "${netname}-etc-tinc"
            (mapAttrsToList (name: path: { inherit name path; }) {
              "hosts" = tinc.config.hostsPackage;
              "tinc.conf" = pkgs.writeText "${netname}-tinc.conf" ''
                Name = ${tinc.config.host.name}
                Interface = ${netname}
                Broadcast = no
                ${concatMapStrings (c: "ConnectTo = ${c}\n") tinc.config.connectTo}
                PrivateKeyFile = ${tinc.config.privkey.path}
                Port = ${toString tinc.config.host.nets.${netname}.tinc.port}
                ${tinc.config.extraConfig}
              '';
              "tinc-up" = pkgs.writeDash "${netname}-tinc-up" ''
                ${tinc.config.iproutePackage}/sbin/ip link set ${netname} up
                ${tinc.config.tincUp}
              '';
            });
        };

        host = mkOption {
          type = types.host;
          default = config.krebs.build.host;
        };

        netname = mkOption {
          type = types.enum (attrNames tinc.config.host.nets);
          default = netname;
          description = ''
            The tinc network name.
            It is used to name the TUN device and to generate the default value for
            <literal>config.krebs.tinc.retiolum.hosts</literal>.
          '';
        };

        extraConfig = mkOption {
          type = types.str;
          default = "";
          description = ''
            Extra Configuration to be appended to tinc.conf
          '';
        };
        tincUp = mkOption {
          type = types.str;
          default = let
            net = tinc.config.host.nets.${netname};
            iproute = tinc.config.iproutePackage;
          in ''
            ${optionalString (net.ip4 != null) /* sh */ ''
              ${iproute}/sbin/ip -4 addr add ${net.ip4.addr} dev ${netname}
              ${iproute}/sbin/ip -4 route add ${net.ip4.prefix} dev ${netname}
            ''}
            ${optionalString (net.ip6 != null) /* sh */ ''
              ${iproute}/sbin/ip -6 addr add ${net.ip6.addr} dev ${netname}
              ${iproute}/sbin/ip -6 route add ${net.ip6.prefix} dev ${netname}
            ''}
            ${tinc.config.tincUpExtra}
          '';
          description = ''
            tinc-up script to be used. Defaults to setting the
            krebs.host.nets.<netname>.ip4 and ip6 for the new ips and
            configures forwarding of the respecitive netmask as subnet.
          '';
        };

        tincUpExtra = mkOption {
          type = types.str;
          default = "";
        };

        tincPackage = mkOption {
          type = types.package;
          default = pkgs.tinc;
          description = "Tincd package to use.";
        };

        hosts = mkOption {
          type = with types; attrsOf host;
          default =
            filterAttrs (_: h: hasAttr tinc.config.netname h.nets) config.krebs.hosts;
          description = ''
            Hosts to generate <literal>config.krebs.tinc.retiolum.hostsPackage</literal>.
            Note that these hosts must have a network named
            <literal>config.krebs.tinc.retiolum.netname</literal>.
          '';
        };

        hostsArchive = mkOption {
          type = types.package;
          default = pkgs.runCommand "retiolum-hosts.tar.bz2" {} ''
            cp \
                --no-preserve=mode \
                --recursive \
                ${tinc.config.hostsPackage} \
                hosts
            ${pkgs.gnutar}/bin/tar -cjf $out hosts
          '';
          readOnly = true;
        };

        hostsPackage = mkOption {
          type = types.package;
          default = pkgs.stdenv.mkDerivation {
            name = "${tinc.config.netname}-tinc-hosts";
            phases = [ "installPhase" ];
            installPhase = ''
              mkdir $out
              ${concatStrings (mapAttrsToList (_: host: ''
                echo ${shell.escape host.nets."${tinc.config.netname}".tinc.config} \
                  > $out/${shell.escape host.name}
              '') tinc.config.hosts)}
            '';
          };
          description = ''
            Package of tinc host configuration files.  By default, a package will
            be generated from <literal>config.krebs.${tinc.config.netname}.hosts</literal>.  This
            option's main purpose is to expose the generated hosts package to other
            modules, like <literal>config.krebs.tinc_graphs</literal>.  But it can
            also be used to provide a custom hosts directory.
          '';
          example = literalExample ''
            (pkgs.stdenv.mkDerivation {
              name = "my-tinc-hosts";
              src = /home/tv/my-tinc-hosts;
              installPhase = "cp -R . $out";
            })
          '';
        };

        iproutePackage = mkOption {
          type = types.package;
          default = pkgs.iproute;
          description = "Iproute2 package to use.";
        };

        privkey = mkOption {
          type = types.secret-file;
          default = {
            name = "${tinc.config.netname}.rsa_key.priv";
            path = "${tinc.config.user.home}/tinc.rsa_key.priv";
            owner = tinc.config.user;
            source-path = toString <secrets> + "/${tinc.config.netname}.rsa_key.priv";
          };
        };

        connectTo = mkOption {
          type = types.listOf types.str;
          ${if tinc.config.netname == "retiolum" then "default" else null} = [
            "gum"
            "ni"
            "prism"
          ];
          description = ''
            The list of hosts in the network which the client will try to connect
            to.  These hosts should have an 'Address' configured which points to a
            routeable IPv4 or IPv6 address.

            In stockholm this can be done by configuring:
              krebs.hosts.${connect-host}.nets.${netname?"retiolum"}.via.ip4.addr = external-ip
              krebs.hosts.${connect-host}.nets.${netname?"retiolum"}.tinc.port = 1655;
          '';
        };

        user = mkOption {
          type = types.user;
          default = {
            name = tinc.config.netname;
            home = "/var/lib/${tinc.config.user.name}";
          };
        };
      };
    }));
  };

  imp = {
    # TODO `environment.systemPackages = [ cfg.tincPackage cfg.iproutePackage ]` for each network,
    # avoid conflicts in environment if the packages differ

    krebs.secret.files = mapAttrs' (netname: cfg:
      nameValuePair "${netname}.rsa_key.priv" cfg.privkey ) config.krebs.tinc;

    users.users = mapAttrs' (netname: cfg:
      nameValuePair "${netname}" {
        inherit (cfg.user) home name uid;
        createHome = true;
      }
    ) config.krebs.tinc;

    environment.etc = mapAttrs' (netname: cfg:
      nameValuePair "tinc/${netname}" (mkIf cfg.enableLegacy {
        source = cfg.confDir;
      })
    ) config.krebs.tinc;

    systemd.services = mapAttrs (netname: cfg:
      let
        tinc = cfg.tincPackage;
        iproute = cfg.iproutePackage;
      in {
        description = "Tinc daemon for ${netname}";
        after = [
          config.krebs.secret.files."${netname}.rsa_key.priv".service
          "network.target"
        ];
        partOf = [
          config.krebs.secret.files."${netname}.rsa_key.priv".service
        ];
        wantedBy = [ "multi-user.target" ];
        path = [ tinc iproute ];
        serviceConfig = rec {
          Restart = "always";
          ExecStart = "${tinc}/sbin/tincd -c ${cfg.confDir} -d 0 -U ${cfg.user.name} -D --pidfile=/var/run/tinc.${SyslogIdentifier}.pid";
          SyslogIdentifier = netname;
        };
      }
    ) config.krebs.tinc;
  };
in out
