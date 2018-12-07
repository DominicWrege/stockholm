{ config, pkgs, ... }:

with import <stockholm/lib>;

let
  name = "radio";
  mainUser = config.users.extraUsers.mainUser;

  admin-password = import <secrets/icecast-admin-pw>;
  source-password = import <secrets/icecast-source-pw>;

  add_random = pkgs.writeDashBin "add_random" ''
    ${pkgs.mpc_cli}/bin/mpc add "$(${pkgs.mpc_cli}/bin/mpc ls | shuf -n1)"
  '';

  skip_track = pkgs.writeDashBin "skip_track" ''
    ${add_random}/bin/add_random
    echo skipping: "$(${print_current}/bin/print_current)"
    ${pkgs.mpc_cli}/bin/mpc -q next
  '';

  print_current = pkgs.writeDashBin "print_current" ''
    echo "$(${pkgs.mpc_cli}/bin/mpc current -f %file%) \
    $(${pkgs.mpc_cli}/bin/mpc current -f %file% \
      | ${pkgs.gnused}/bin/sed 's@.*\(.\{11\}\)\.ogg@http://www.youtube.com/watch?v=\1@')"
  '';

in {
  users.users = {
    "${name}" = rec {
      inherit name;
      group = name;
      uid = genid_uint31 name;
      description = "radio manager";
      home = "/home/${name}";
      useDefaultShell = true;
      createHome = true;
      openssh.authorizedKeys.keys = with config.krebs.users; [
        lass.pubkey
        lass-mors.pubkey
      ];
    };
  };

  users.groups = {
    "radio" = {};
  };

  krebs.per-user.${name}.packages = with pkgs; [
    add_random
    skip_track
    print_current
    ncmpcpp
    mpc_cli
  ];

  services.mpd = {
    enable = true;
    group = "radio";
    musicDirectory = "/home/radio/the_playlist/music";
    extraConfig = ''
      audio_output {
        type        "shout"
        encoding    "lame"
        name        "the_playlist_mp3"
        host        "localhost"
        port        "8000"
        mount       "/radio.mp3"
        password    "${source-password}"
        bitrate     "128"

        format      "44100:16:2"

        user        "source"
        genre       "good music"
      }
      audio_output {
        type        "shout"
        encoding    "ogg"
        name        "the_playlist_ogg"
        host        "localhost"
        port        "8000"
        mount       "/radio.ogg"
        password    "${source-password}"
        bitrate     "128"

        format      "44100:16:2"

        user        "source"
        genre       "good music"
      }
    '';
  };

  services.icecast = {
    enable = true;
    hostname =  "config.krebs.build.host.name";
    admin.password = admin-password;
    extraConf = ''
      <authentication>
        <source-password>${source-password}</source-password>
      </authentication>
    '';
  };

  krebs.iptables = {
    tables = {
      filter.INPUT.rules = [
        { predicate = "-p tcp --dport 8000"; target = "ACCEPT"; }
      ];
    };
  };

  systemd.timers.radio = {
    description = "radio autoadder timer";
    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnCalendar = "*:0/1";
    };
  };

  systemd.services.radio = let
    autoAdd = pkgs.writeDash "autoAdd" ''
      LIMIT=$1 #in secconds

      timeLeft () {
        playlistDuration=$(${pkgs.mpc_cli}/bin/mpc --format '%time%' playlist | ${pkgs.gawk}/bin/awk -F ':' 'BEGIN{t=0} {t+=$1*60+$2} END{print t}')
        currentTime=$(${pkgs.mpc_cli}/bin/mpc status | ${pkgs.gawk}/bin/awk '/^\[playing\]/ { sub(/\/.+/,"",$3); split($3,a,/:/); print a[1]*60+a[2] }')
        expr ''${playlistDuration:-0} - ''${currentTime:-0}
      }

      if test $(timeLeft) -le $LIMIT; then
        ${add_random}/bin/add_random
      fi
      ${pkgs.mpc_cli}/bin/mpc play > /dev/null
    '';
  in {
    description = "radio playlist autoadder";
    after = [ "network.target" ];

    restartIfChanged = true;

    serviceConfig = {
      ExecStart = "${autoAdd} 150";
    };
  };

  systemd.services.radio-recent = let
    recentlyPlayed = pkgs.writeDash "recentlyPlayed" ''
      LIMIT=1000 #how many tracks to keep in the history
      HISTORY_FILE=/tmp/played
      while :; do
        ${pkgs.mpc_cli}/bin/mpc idle player > /dev/null
        ${pkgs.mpc_cli}/bin/mpc current -f %file%
      done | while read track; do
        echo "$(date -Is)" "$track" | tee -a "$HISTORY_FILE"
        echo "$(tail -$LIMIT "$HISTORY_FILE")" > "$HISTORY_FILE"
      done
    '';
  in {
    description = "radio recently played";
    after = [ "mpd.service" "network.target" ];
    wantedBy = [ "multi-user.target" ];

    restartIfChanged = true;

    serviceConfig = {
      ExecStart = recentlyPlayed;
    };
  };

  krebs.Reaktor.playlist = {
    nickname = "the_playlist|r";
    channels = [
      "#the_playlist"
      "#krebs"
    ];
    extraEnviron = {
      REAKTOR_HOST = "irc.freenode.org";
    };
    plugins = with pkgs.ReaktorPlugins; [
      (buildSimpleReaktorPlugin "skip" {
        script = "${skip_track}/bin/skip_track";
        pattern = "^skip$";
      })
      (buildSimpleReaktorPlugin "current" {
        script = "${print_current}/bin/print_current";
        pattern = "^current$";
      })
      (buildSimpleReaktorPlugin "suggest" {
        script = "${pkgs.writeDash "suggest" ''
          echo "$@" >> $HOME/playlist_suggest
        ''}";
        pattern = "^suggest: (?P<args>.*)$";
      })
    ];
  };
  services.nginx = {
    enable = true;
    virtualHosts."radio.lassul.us" = {
      forceSSL = true;
      enableACME = true;
      locations."/".extraConfig = ''
        proxy_pass http://localhost:8000;
      '';
      locations."/recent".extraConfig = ''
        alias /tmp/played;
      '';
    };
    virtualHosts."lassul.us".locations."/the_playlist".extraConfig = let
      html = pkgs.writeText "index.html" ''
        <!DOCTYPE html>
        <html lang="en">
          <head>
            <meta charset="utf-8">
            <title>lassulus playlist</title>
          </head>
          <body>
            <div style="display:inline-block;margin:0px;padding:0px;overflow:hidden">
              <iframe src="https://kiwiirc.com/client/irc.freenode.org/?nick=kiwi_test|?&theme=cli#the_playlist" frameborder="0" style="overflow:hidden;overflow-x:hidden;overflow-y:hidden;height:95%;width:100%;position:absolute;top:0px;left:0px;right:0px;bottom:0px" height="95%" width="100%"></iframe>
            </div>
            <div style="position:absolute;bottom:1px;display:inline-block;background-color:red;">
              <audio controls autoplay="autoplay"><source src="http://lassul.us:8000/radio.ogg" type="audio/ogg">Your browser does not support the audio element.</audio>
            </div>
            <!-- page content -->
          </body>
        </html>
      '';
    in ''
      default_type "text/html";
      alias ${html};
    '';
  };
}
