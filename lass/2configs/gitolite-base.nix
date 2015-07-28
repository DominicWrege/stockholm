{ config, ... }:

{
  services.gitolite = {
    mutable = false;
    keys = {
      lass = config.sshKeys.lass.pub;
      uriel = config.sshKeys.uriel.pub;
    };
    rc = ''
      %RC = (
          UMASK                           =>  0077,
          GIT_CONFIG_KEYS                 =>  "",
          LOG_EXTRA                       =>  1,
          ROLES => {
              READERS                     =>  1,
              WRITERS                     =>  1,
          },
          LOCAL_CODE                =>  "$ENV{HOME}/.gitolite",
          ENABLE => [
                  'help',
                  'desc',
                  'info',
                  'perms',
                  'writable',
                  'ssh-authkeys',
                  'git-config',
                  'daemon',
                  'gitweb',
                  'repo-specific-hooks',
          ],
      );
      1;
    '';

    repoSpecificHooks = {
      irc-announce = ''
        #! /bin/sh
        set -euf

        config_file="$GL_ADMIN_BASE/conf/irc-announce.conf"
        if test -f "$config_file"; then
          . "$config_file"
        fi

        # XXX when changing IRC_CHANNEL or IRC_SERVER/_PORT, don't forget to update
        #     any relevant gitolite LOCAL_CODE!
        # CAVEAT we hope that IRC_NICK is unique
        IRC_NICK="''${IRC_NICK-gl$GL_TID}"
        IRC_CHANNEL="''${IRC_CHANNEL-#retiolum}"
        IRC_SERVER="''${IRC_SERVER-ire.retiolum}"
        IRC_PORT="''${IRC_PORT-6667}"

        # for privmsg_cat below
        export IRC_CHANNEL

        # collect users that are mentioned in the gitolite configuration
        interested_users="$(perl -e '
          do "gl-conf";
          print join(" ", keys%{ $one_repo{$ENV{"GL_REPO"}} });
        ')"

        # CAVEAT beware of real TABs in grep pattern!
        # CAVEAT there will never be more than 42 relevant log entries!
        tab=$(printf '\x09')
        log="$(tail -n 42 "$GL_LOGFILE" | grep "^[^$tab]*$tab$GL_TID$tab" || :)"

        update_log="$(echo "$log" | grep "^[^$tab]*$tab$GL_TID''${tab}update")"

        # (debug output)
        env | sed 's/^/env: /'
        echo "$log" | sed 's/^/log: /'

        # see http://gitolite.com/gitolite/dev-notes.html#lff
        reponame=$(echo "$update_log" | cut -f 4)
        username=$(echo "$update_log" | cut -f 5)
        ref_name=$(echo "$update_log" | cut -f 7 | sed 's|^refs/heads/||')
        old_sha=$(echo "$update_log" | cut -f 8)
        new_sha=$(echo "$update_log" | cut -f 9)

        # check if new branch is created
        if test $old_sha = 0000000000000000000000000000000000000000; then
          # TODO what should we really show?
          old_sha=$new_sha^
        fi

        #
        git_log="$(git log $old_sha..$new_sha --pretty=oneline --abbrev-commit)"
        commit_count=$(echo "$git_log" | wc -l)

        # echo2 and cat2 are used output to both, stdout and stderr
        # This is used to see what we send to the irc server. (debug output)
        echo2() { echo "$*"; echo "$*" >&2; }
        cat2() { tee /dev/stderr; }

        # privmsg_cat transforms stdin to a privmsg
        privmsg_cat() { awk '{ print "PRIVMSG "ENVIRON["IRC_CHANNEL"]" :"$0 }'; }

        # ircin is used to feed the output of netcat back to the "irc client"
        # so we can implement expect-like behavior with sed^_^
        # XXX mkselfdestructingtmpfifo would be nice instead of this cruft
        tmpdir="$(mktemp -d irc-announce_XXXXXXXX)"
        cd "$tmpdir"
        mkfifo ircin
        trap "
          rm ircin
          cd '$OLDPWD'
          rmdir '$tmpdir'
          trap - EXIT INT QUIT
        " EXIT INT QUIT

        #
        #
        #
        {
          echo2 "USER $LOGNAME 0 * :$LOGNAME@$(hostname)"
          echo2 "NICK $IRC_NICK"

          # wait for MODE message
          sed -n '/^:[^ ]* MODE /q'

          echo2 "JOIN $IRC_CHANNEL"

          echo "$interested_users" \
            | tr ' ' '\n' \
            | grep -v "^$GL_USER" \
            | sed 's/$/: poke/' \
            | privmsg_cat \
            | cat2

          printf '[\x0313%s\x03] %s pushed %s new commit%s to \x036%s %s\x03\n' \
              "$reponame" \
              "$username" \
              "$commit_count" \
              "$(test $commit_count = 1 || echo s)" \
              "$(hostname)" \
              "$ref_name" \
            | privmsg_cat \
            | cat2

          echo "$git_log" \
            | sed 's/^/\x0314/;s/ /\x03 /' \
            | privmsg_cat \
            | cat2

          echo2 "PART $IRC_CHANNEL"

          # wait for PART confirmation
          sed -n '/:'"$IRC_NICK"'![^ ]* PART /q'

          echo2 'QUIT :Gone to have lunch'
        } < ircin \
          | nc "$IRC_SERVER" "$IRC_PORT" | tee -a ircin
      '';
    };
    customFiles = [
      {
        path = ".gitolite/conf/irc-announce.conf";
        file = ''
          IRC_NICK="$(hostname)$GL_TID"
          case "$GL_REPO" in
            brain|painload|services|load-env|config)
              IRC_CHANNEL='#retiolum'
            ;;
            *)
              IRC_CHANNEL='&testing'
            ;;
          esac
        '';
      }
    ];
  };
}
