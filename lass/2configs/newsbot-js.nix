{ config, pkgs, ... }:

let
  newsfile = pkgs.writeText "feeds" ''
    aje|http://www.aljazeera.com/Services/Rss/?PostingId=2007731105943979989|#news
    aktuelle_themen|http://bundestag.de/service/rss/Bundestag_Aktuelle_Themen.rss|#news #bundestag
    allafrica|http://allafrica.com/tools/headlines/rdf/latest/headlines.rdf|#news
    anon|http://anoninsiders.net/feed/|#news
    antirez|http://antirez.com/rss|#news
    arbor|http://feeds2.feedburner.com/asert/|#news
    archlinux|http://www.archlinux.org/feeds/news/|#news
    ars|http://feeds.arstechnica.com/arstechnica/index?format=xml|#news
    asiaone_asia|http://news.asiaone.com/rss/asia|#news
    asiaone_business|http://business.asiaone.com/rss.xml|#news
    asiaone_sci|http://news.asiaone.com/rss/science-and-tech|#news
    asiaone_world|http://news.asiaone.com/rss/world|#news
    augustl|http://augustl.com/atom.xml|#news
    bbc|http://feeds.bbci.co.uk/news/rss.xml|#news
    bdt_drucksachen|http://www.bundestag.de/dip21rss/bundestag_drucksachen.rss|#news #bundestag
    bdt_plenarproto|http://www.bundestag.de/rss_feeds/plenarprotokolle.rss|#news #bundestag
    bdt_pressemitteilungen|http://bundestag.de/service/rss/Bundestag_Presse.rss|#news #bundestag
    bdt_wd|http://bundestag.de/service/rss/Bundestag_WD.rss|#news #bundestag
    bitcoinpakistan|https://bitcoinspakistan.com/feed/|#news #financial
    c|http://www.tempolimit-lichtgeschwindigkeit.de/news.xml|#news
    cancer|http://feeds.feedburner.com/ncinewsreleases?format=xml|#news
    carta|http://feeds2.feedburner.com/carta-standard-rss|#news
    catholic_news|http://feeds.feedburner.com/catholicnewsagency/dailynews|#news
    cbc_busi|http://rss.cbc.ca/lineup/business.xml|#news
    cbc_offbeat|http://www.cbc.ca/cmlink/rss-offbeat|#news
    cbc_pol|http://rss.cbc.ca/lineup/politics.xml|#news
    cbc_tech|http://rss.cbc.ca/lineup/technology.xml|#news
    cbc_top|http://rss.cbc.ca/lineup/topstories.xml|#news
    ccc|http://www.ccc.de/rss/updates.rdf|#news
    chan_b|https://boards.4chan.org/b/index.rss|#brainfuck
    chan_biz|https://boards.4chan.org/biz/index.rss|#news #brainfuck
    chan_int|https://boards.4chan.org/int/index.rss|#news #brainfuck
    cna|http://www.channelnewsasia.com/starterkit/servlet/cna/rss/home.xml|#news
    coinspotting|http://coinspotting.com/rss|#news #financial
    cryptanalysis|https://cryptanalys.is/rss.php|#news
    cryptocoinsnews|http://www.cryptocoinsnews.com/feed/|#news #financial
    cryptogon|http://www.cryptogon.com/?feed=rss2|#news
    csm|http://rss.csmonitor.com/feeds/csm|#news
    csm_world|http://rss.csmonitor.com/feeds/world|#news
    danisch|http://www.danisch.de/blog/feed/|#news
    dod|http://www.defense.gov/news/afps2.xml|#news
    dwn|http://deutsche-wirtschafts-nachrichten.de/feed/customfeed/|#news
    ecat|http://ecat.com/feed|#news
    eia_press|http://www.eia.gov/rss/press_rss.xml|#news
    eia_today|http://www.eia.gov/rss/todayinenergy.xml|#news
    embargowatch|https://embargowatch.wordpress.com/feed/|#news
    ethereum-comments|http://blog.ethereum.org/comments/feed|#news
    ethereum|http://blog.ethereum.org/feed|#news
    europa_ric|http://ec.europa.eu/research/infocentre/rss/infocentre-rss.xml|#news
    eu_survei|http://www.eurosurveillance.org/public/RSSFeed/RSS.aspx|#news
    exploitdb|http://www.exploit-db.com/rss.xml|#news
    fars|http://www.farsnews.com/rss.php|#news #test
    faz_feui|http://www.faz.net/rss/aktuell/feuilleton/|#news
    faz_politik|http://www.faz.net/rss/aktuell/politik/|#news
    faz_wirtschaft|http://www.faz.net/rss/aktuell/wirtschaft/|#news #financial
    fbi|http://www.fbi.gov/homepage/RSS|#news #bullerei
    fbi_news|http://www.fbi.gov/news/news_blog/rss.xml|#news
    fbi_press|http://www.fbi.gov/news/current/rss.xml|#news #bullerei
    fbi_stories|http://www.fbi.gov/news/stories/all-stories/rss.xml|#news #bullerei
    fedreserve|http://www.federalreserve.gov/feeds/press_all.xml|#news #financial
    fefe|http://blog.fefe.de/rss.xml|#news
    forbes|http://www.forbes.com/forbes/feed2/|#news
    forbes_realtime|http://www.forbes.com/real-time/feed2/|#news
    fox|http://feeds.foxnews.com/foxnews/latest|#news
    geheimorganisation|http://geheimorganisation.org/feed/|#news
    GerForPol|http://www.german-foreign-policy.com/de/news/rss-2.0|#news
    gmanet|http://www.gmanetwork.com/news/rss/news|#news
    golem|http://www.golem.de/rss.php?feed=RSS1.0|#news
    google|http://news.google.com/?output=rss|#news
    greenpeace|http://feeds.feedburner.com/GreenpeaceNews|#news
    guardian_uk|http://feeds.theguardian.com/theguardian/uk-news/rss|#news
    gulli|http://ticker.gulli.com/rss/|#news
    handelsblatt|http://www.handelsblatt.com/contentexport/feed/schlagzeilen|#news #financial
    heise|http://heise.de.feedsportal.com/c/35207/f/653902/index.rss|#news
    hindu_business|http://www.thehindubusinessline.com/?service=rss|#news #financial
    hindu|http://www.thehindu.com/?service=rss|#news
    hintergrund|http://www.hintergrund.de/index.php?option=com_bca-rss-syndicator&feed_id=8|#news
    ign|http://feeds.ign.com/ign/all|#news
    independent|http://www.independent.com/rss/headlines/|#news
    indymedia|http://de.indymedia.org/RSS/newswire.xml|#news
    info_libera|http://www.informationliberation.com/rss.xml|#news
    klagen-gegen-rundfuckbeitrag|http://klagen-gegen-rundfunkbeitrag.blogspot.com/feeds/posts/default|#news
    korea_herald|http://www.koreaherald.com/rss_xml.php|#news
    linuxinsider|http://www.linuxinsider.com/perl/syndication/rssfull.pl|#news
    lisp|http://planet.lisp.org/rss20.xml|#news
    liveleak|http://www.liveleak.com/rss|#news
    lolmythesis|http://lolmythesis.com/rss|#news
    LtU|http://lambda-the-ultimate.org/rss.xml|#news
    lukepalmer|http://lukepalmer.wordpress.com/feed/|#news
    mit|http://web.mit.edu/newsoffice/rss-feeds.feed?type=rss|#news
    mongrel2_master|https://github.com/zedshaw/mongrel2/commits/master.atom|#news
    nds|http://www.nachdenkseiten.de/?feed=atom|#news
    netzpolitik|https://netzpolitik.org/feed/|#news
    newsbtc|http://newsbtc.com/feed/|#news #financial
    nnewsg|http://www.net-news-global.net/rss/rssfeed.xml|#news
    npr_busi|http://www.npr.org/rss/rss.php?id=1006|#news
    npr_headlines|http://www.npr.org/rss/rss.php?id=1001|#news
    npr_pol|http://www.npr.org/rss/rss.php?id=1012|#news
    npr_world|http://www.npr.org/rss/rss.php?id=1004|#news
    nsa|https://www.nsa.gov/rss.xml|#news #bullerei
    nytimes|http://rss.nytimes.com/services/xml/rss/nyt/World.xml|#news
    painload|https://github.com/krebscode/painload/commits/master.atom|#news
    phys|http://phys.org/rss-feed/|#news
    piraten|https://www.piratenpartei.de/feed/|#news
    polizei_berlin|http://www.berlin.de/polizei/presse-fahndung/_rss_presse.xml|#news #bullerei
    presse_polizei|http://www.presseportal.de/rss/polizei.rss2|#news #bullerei
    presseportal|http://www.presseportal.de/rss/presseportal.rss2|#news
    prisonplanet|http://prisonplanet.com/feed.rss|#news
    proofmarket|https://proofmarket.org/feed_problem|#news
    rawstory|http://www.rawstory.com/rs/feed/|#news
    reddit_4chan|http://www.reddit.com/r/4chan/new/.rss|#news #brainfuck
    reddit_anticonsum|http://www.reddit.com/r/Anticonsumption/new/.rss|#news
    reddit_btc|http://www.reddit.com/r/Bitcoin/new/.rss|#news #financial
    reddit_prog|http://www.reddit.com/r/programming/new/.rss|#news
    reddit_tpp|http://www.reddit.com/r/twitchplayspokemon/.rss|#news #tpp
    reddit_world|http://www.reddit.com/r/worldnews/.rss|#news
    r-ethereum|http://www.reddit.com/r/ethereum/.rss|#news
    reuters|http://feeds.reuters.com/Reuters/worldNews|#news
    reuters-odd|http://feeds.reuters.com/reuters/oddlyEnoughNews?format=xml|#news
    rt|http://rt.com/rss/news/|#news
    schallurauch|http://feeds.feedburner.com/SchallUndRauch|#news
    sciencemag|http://news.sciencemag.org/rss/current.xml|#news
    scmp|http://www.scmp.com/rss/91/feed|#news
    sec-db|http://feeds.security-database.com/SecurityDatabaseToolsWatch|#news
    shackspace|http://shackspace.de/?feed=rss2|#news
    shz_news|http://www.shz.de/nachrichten/newsticker/rss|#news
    sky_busi|http://news.sky.com/feeds/rss/business.xml|#news
    sky_pol|http://news.sky.com/feeds/rss/politics.xml|#news
    sky_strange|http://news.sky.com/feeds/rss/strange.xml|#news
    sky_tech|http://news.sky.com/feeds/rss/technology.xml|#news
    sky_world|http://news.sky.com/feeds/rss/world.xml|#news
    slashdot|http://rss.slashdot.org/Slashdot/slashdot|#news
    slate|http://feeds.slate.com/slate|#news
    spiegel_eil|http://www.spiegel.de/schlagzeilen/eilmeldungen/index.rss|#news
    spiegelfechter|http://feeds.feedburner.com/DerSpiegelfechter?format=xml|#news
    spiegel_top|http://www.spiegel.de/schlagzeilen/tops/index.rss|#news
    standardmedia_ke|http://www.standardmedia.co.ke/rss/headlines.php|#news
    stern|http://www.stern.de/feed/standard/all/|#news
    stz|http://www.stuttgarter-zeitung.de/rss/topthemen.rss.feed|#news
    sz_politik|http://rss.sueddeutsche.de/rss/Politik|#news
    sz_wirtschaft|http://rss.sueddeutsche.de/rss/Wirtschaft|#news #financial
    sz_wissen|http://suche.sueddeutsche.de/rss/Wissen|#news
    tagesschau|http://www.tagesschau.de/newsticker.rdf|#news
    taz|http://taz.de/Themen-des-Tages/!p15;rss/|#news
    telegraph_finance|http://www.telegraph.co.uk/finance/rss|#news #financial
    telegraph_pol|http://www.telegraph.co.uk/news/politics/rss|#news
    telegraph_uk|http://www.telegraph.co.uk/news/uknews/rss|#news
    telegraph_world|http://www.telegraph.co.uk/news/worldnews/rss|#news
    telepolis|http://www.heise.de/tp/rss/news-atom.xml|#news
    the_insider|http://www.theinsider.org/rss/news/headlines-xml.asp|#news
    tigsource|http://www.tigsource.com/feed/|#news
    tinc|http://tinc-vpn.org/news/index.rss|#news
    topix_b|http://www.topix.com/rss/wire/de/berlin|#news
    torr_bits|http://feeds.feedburner.com/TorrentfreakBits|#news
    torrentfreak|http://feeds.feedburner.com/Torrentfreak|#news
    torr_news|http://feed.torrentfreak.com/Torrentfreak/|#news
    travel_warnings|http://feeds.travel.state.gov/ca/travelwarnings-alerts|#news
    un_afr|http://www.un.org/apps/news/rss/rss_africa.asp|#news
    un_am|http://www.un.org/apps/news/rss/rss_americas.asp|#news
    un_eu|http://www.un.org/apps/news/rss/rss_europe.asp|#news
    un_me|http://www.un.org/apps/news/rss/rss_mideast.asp|#news
    un_pac|http://www.un.org/apps/news/rss/rss_asiapac.asp|#news
    un_top|http://www.un.org/apps/news/rss/rss_top.asp|#news
    us_math_society|http://www.ams.org/cgi-bin/content/news_items.cgi?rss=1|#news
    vimperator|https://sites.google.com/a/vimperator.org/www/blog/posts.xml|#news
    weechat|http://dev.weechat.org/feed/atom|#news
    wired_sci|http://www.wired.com/category/science/feed/|#news
    wp_world|http://feeds.washingtonpost.com/rss/rss_blogpost|#news
    xkcd|https://xkcd.com/rss.xml|#news
    zdnet|http://www.zdnet.com/news/rss.xml|#news

    chan_g|https://boards.4chan.org/g/index.rss|#news
    chan_x|https://boards.4chan.org/x/index.rss|#news
    chan_sci|https://boards.4chan.org/sci/index.rss|#news
    reddit_consp|http://reddit.com/r/conspiracy/.rss|#news
    reddit_sci|http://www.reddit.com/r/science/.rss|#news
    reddit_tech|http://www.reddit.com/r/technology/.rss|#news
    reddit_nix|http://www.reddit.com/r/nixos/.rss|#news
    reddit_haskell|http://www.reddit.com/r/haskell/.rss|#news
    hackernews|https://news.ycombinator.com/rss|#news
  '';
in {
  environment.systemPackages = [
    pkgs.newsbot-js
  ];
  krebs.newsbot-js = {
    enable = true;
    ircServer = "localhost";
    feeds = newsfile;
    urlShortenerHost = "go";
    urlShortenerPort = "80";
  };
}
