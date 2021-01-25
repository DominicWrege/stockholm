{ config, pkgs, ... }:

with import <stockholm/lib>;

let
  name = "radio";
  mainUser = config.users.extraUsers.mainUser;

  music_dir = "/home/radio/music";

  add_random = pkgs.writeDashBin "add_random" ''
    ${pkgs.mpc_cli}/bin/mpc add "$(${pkgs.findutils}/bin/find "${music_dir}/the_playlist" \
      | grep -Ev '/other/|/.graveyard/' \
      | grep '\.ogg$' \
      | shuf -n1 \
      | sed 's,${music_dir}/,,' \
    )"
  '';

  get_current_track_position = pkgs.writeDash "get_current_track_position" ''
    ${pkgs.mpc_cli}/bin/mpc status | ${pkgs.gawk}/bin/awk '/^\[playing\]/ { sub(/\/.+/,"",$3); split($3,a,/:/); print a[1]*60+a[2] }'
  '';

  skip_track = pkgs.writeBashBin "skip_track" ''
    set -eu

    ${add_random}/bin/add_random
    music_dir=${escapeShellArg music_dir}
    current_track=$(${pkgs.mpc_cli}/bin/mpc current -f %file%)
    track_infos=$(${print_current}/bin/print_current)
    skip_count=$(${pkgs.attr}/bin/getfattr -n user.skip_count --only-values "$music_dir"/"$current_track" || echo 0)
    if [[ "$current_track" =~ ^the_playlist/music/.* ]] && [ "$skip_count" -le 2 ]; then
      skip_count=$((skip_count+1))
      ${pkgs.attr}/bin/setfattr -n user.skip_count -v "$skip_count" "$music_dir"/"$current_track"
      echo skipping: "$track_infos" skip_count: "$skip_count"
    else
      mkdir -p "$music_dir"/the_playlist/.graveyard/
      mv "$music_dir"/"$current_track" "$music_dir"/the_playlist/.graveyard/
      echo killing: "$track_infos"
    fi
    ${pkgs.mpc_cli}/bin/mpc -q next
  '';

  good_track = pkgs.writeBashBin "good_track" ''
    set -eu

    music_dir=${escapeShellArg music_dir}
    current_track=$(${pkgs.mpc_cli}/bin/mpc current -f %file%)
    track_infos=$(${print_current}/bin/print_current)
    if [[ "$current_track" =~ ^the_playlist/music/.* ]]; then
      ${pkgs.attr}/bin/setfattr -n user.skip_count -v 0 "$music_dir"/"$current_track"
    else
      mv "$music_dir"/"$current_track" "$music_dir"/the_playlist/music/ || :
    fi
    echo good: "$track_infos"
  '';

  track_youtube_link = pkgs.writeDash "track_youtube_link" ''
    ${pkgs.mpc_cli}/bin/mpc current -f %file% \
      | ${pkgs.gnused}/bin/sed 's@.*\(.\{11\}\)\.ogg@https://www.youtube.com/watch?v=\1@'
  '';

  print_current = pkgs.writeDashBin "print_current" ''
    echo "$(${pkgs.mpc_cli}/bin/mpc current -f %file%) \
    $(${track_youtube_link})"
  '';

  print_current_json = pkgs.writeDashBin "print_current_json" ''
    ${pkgs.jq}/bin/jq -n -c \
      --arg name "$(${pkgs.mpc_cli}/bin/mpc current)" \
      --arg artist "$(${pkgs.mpc_cli}/bin/mpc current -f %artist%)" \
      --arg title "$(${pkgs.mpc_cli}/bin/mpc current -f %title%)" \
      --arg filename "$(${pkgs.mpc_cli}/bin/mpc current -f %file%)" \
      --arg position "$(${get_current_track_position})" \
      --arg length "$(${pkgs.mpc_cli}/bin/mpc current -f %time%)" \
      --arg youtube "$(${track_youtube_link})" '{
        name: $name,
        artist: $artist,
        title: $title,
        filename: $filename,
        position: $position,
        length: $length,
        youtube: $youtube
      }'
  '';

  write_to_irc = pkgs.writeDash "write_to_irc" ''
    ${pkgs.curl}/bin/curl -fsSv --unix-socket /home/radio/reaktor.sock http://z/ \
      -H content-type:application/json \
      -d "$(${pkgs.jq}/bin/jq -n \
        --arg text "$1" '{
          command:"PRIVMSG",
          params:["#the_playlist",$text]
        }'
      )"
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
    good_track
    skip_track
    print_current
    print_current_json
    ncmpcpp
    mpc_cli
  ];

  services.mpd = {
    enable = true;
    group = "radio";
    musicDirectory = "${music_dir}";
    extraConfig = ''
      log_level "default"
      auto_update "yes"

      audio_output {
        type "httpd"
        name "lassulus radio"
        encoder "vorbis" # optional
        port "8000"
        quality "5.0" # do not define if bitrate is defined
        # bitrate "128" # do not define if quality is defined
        format "44100:16:2"
        always_on "yes" # prevent MPD from disconnecting all listeners when playback is stopped.
        tags "yes" # httpd supports sending tags to listening streams.
      }
    '';
  };

  krebs.iptables = {
    tables = {
      filter.INPUT.rules = [
        { predicate = "-p tcp --dport 8000"; target = "ACCEPT"; }
        { predicate = "-i retiolum -p tcp --dport 8001"; target = "ACCEPT"; }
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
      LIMIT=$1 #in seconds

      timeLeft () {
        playlistDuration=$(${pkgs.mpc_cli}/bin/mpc --format '%time%' playlist | ${pkgs.gawk}/bin/awk -F ':' 'BEGIN{t=0} {t+=$1*60+$2} END{print t}')
        currentTime=$(${get_current_track_position})
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
        listeners=$(${pkgs.iproute}/bin/ss -Hno state established 'sport = :8000' | wc -l)
        echo "$(date -Is)" "$track" | tee -a "$HISTORY_FILE"
        echo "$(tail -$LIMIT "$HISTORY_FILE")" > "$HISTORY_FILE"
        ${write_to_irc} "playing: $track listeners: $listeners"
      done
    '';
  in {
    description = "radio recently played";
    after = [ "mpd.service" "network.target" ];
    wantedBy = [ "multi-user.target" ];

    restartIfChanged = true;

    serviceConfig = {
      ExecStart = recentlyPlayed;
      User = "radio";
    };
  };

  # allow reaktor2 to modify files
  systemd.services."reaktor2-the_playlist".serviceConfig.DynamicUser = mkForce false;

  krebs.reaktor2.the_playlist = {
    hostname = "irc.freenode.org";
    port = "6697";
    useTLS = true;
    nick = "the_playlist";
    username = "radio";
    API.listen = "unix:/home/radio/reaktor.sock";
    plugins = [
      {
        plugin = "register";
        config = {
          channels = [
            "#the_playlist"
            "#krebs"
          ];
        };
      }
      {
        plugin = "system";
        config = {
          workdir = config.krebs.reaktor2.the_playlist.stateDir;
          hooks.PRIVMSG = [
            {
              activate = "match";
              pattern = "^(?:.*\\s)?\\s*the_playlist:\\s*([0-9A-Za-z._][0-9A-Za-z._-]*)(?:\\s+(.*\\S))?\\s*$";
              command = 1;
              arguments = [2];
              commands = {
                skip.filename = "${skip_track}/bin/skip_track";
                next.filename = "${skip_track}/bin/skip_track";
                bad.filename = "${skip_track}/bin/skip_track";

                good.filename = "${good_track}/bin/good_track";
                nice.filename = "${good_track}/bin/good_track";
                like.filename = "${good_track}/bin/good_track";

                current.filename = "${print_current}/bin/print_current";
                suggest.filename = pkgs.writeDash "suggest" ''
                  echo "$@" >> playlist_suggest
                '';
              };
            }
          ];
        };
      }
    ];
  };

  krebs.htgen.radio = {
    port = 8001;
    user = {
      name = "radio";
    };
    script = ''. ${pkgs.writeDash "radio" ''
      case "$Method $Request_URI" in
        "GET /current")
          printf 'HTTP/1.1 200 OK\r\n'
          printf 'Connection: close\r\n'
          printf '\r\n'
          ${print_current_json}/bin/print_current_json
          exit
        ;;
        "POST /skip")
          printf 'HTTP/1.1 200 OK\r\n'
          printf 'Connection: close\r\n'
          printf '\r\n'
          msg=$(${skip_track}/bin/skip_track)
          ${write_to_irc} "$msg"
          echo "$msg"
          exit
        ;;
        "POST /good")
          printf 'HTTP/1.1 200 OK\r\n'
          printf 'Connection: close\r\n'
          printf '\r\n'
          msg=$(${good_track}/bin/good_track)
          ${write_to_irc} "$msg"
          echo "$msg"
          exit
        ;;
      esac
    ''}'';
  };

  services.nginx = {
    enable = true;
    virtualHosts."radio.lassul.us" = {
      forceSSL = true;
      enableACME = true;
      locations."/".extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Server $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_pass http://localhost:8000;
      '';
      locations."= /recent".extraConfig = ''
        alias /tmp/played;
      '';
    };
    virtualHosts."lassul.us".locations."= /the_playlist".extraConfig = let
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
  services.syncthing.declarative.folders."the_playlist" = {
    path = "/home/radio/music/the_playlist";
    devices = [ "mors" "phone" "prism" "xerxes" ];
  };
  krebs.permown."/home/radio/music/the_playlist" = {
    owner = "radio";
    group = "syncthing";
    umask = "0002";
  };
}
