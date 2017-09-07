{ config, lib, pkgs, ... }:

with import <stockholm/lib>;

let

  cfg = config.krebs.newsbot-js;

  out = {
    options.krebs.newsbot-js = api;
    config = mkIf cfg.enable imp;
  };

  api = {
    enable = mkEnableOption "Enable krebs newsbot";
    package = mkOption {
      type = types.package;
      default = pkgs.newsbot-js;
      description = "newsbot package to use";
    };
    ircServer = mkOption {
      type = types.str;
      default = "echelon.retiolum";
      description = "to which server the bot should connect";
    };
    channel = mkOption {
      type = types.str;
      default = "#news";
      description = "post the news in this channel";
    };
    masterNick = mkOption {
      type = types.str;
      default = "knews";
      description = "nickname of the master bot";
    };
    feeds = mkOption {
      type = types.path;
      description = ''
        file with feeds to post
        format:
        $nick|$feedURI
      '';
    };
    urlShortenerHost = mkOption {
      type = types.str;
      default = "echelon";
      description = "what server to use for url shortening, host";
    };
    urlShortenerPort = mkOption {
      type = types.str;
      default = "80";
      description = "what server to use for url shortening, port";
    };
  };

  imp = {
    users.extraUsers.newsbot-js = {
      name = "newsbot-js";
      uid = genid "newsbot-js";
      description = "newsbot-js user";
      home = "/var/empty";
    };

    systemd.services.newsbot-js = {
      description = "krebs newsbot";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      path = with pkgs; [
        newsbot-js
      ];

      environment = {
        irc_server = cfg.ircServer;
        master_nick = cfg.masterNick;
        news_channel = cfg.channel;
        feeds_file = cfg.feeds;
        url_shortener_host = cfg.urlShortenerHost;
        url_shortener_port = cfg.urlShortenerPort;
      };

      restartIfChanged = true;

      serviceConfig = {
        User = "newsbot-js";
        Restart = "always";
        ExecStart = "${cfg.package}/bin/newsbot";
      };
    };
  };

in out
