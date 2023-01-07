{ r6, w6, ... }:
{
  nets = {
    retiolum = {
      ip4.addr = "10.243.0.11";
      ip6.addr = r6 "4d10";
      aliases = [
        "radio.r"
        "radio-news.r"
      ];
      tinc.pubkey = ''
        -----BEGIN RSA PUBLIC KEY-----
        MIICCgKCAgEAx08urv4sl22+pLchD6W6kprJ1JZBiG9/MVA50PqYAJmvTpYyDUCR
        Dwgt7pR8n/zbbof98QS5D67J5rZPcrLI6PY2bBzlXFFKHZEj2AVwUjUbyvEvQqtf
        yJM+AxFy1/CaXmDvYM9UF/Wh6rb/ZeUxFtbaIVfMPox0Zln0THEsOmCWvNzxMvjZ
        rjouZGzrH+er3yxJVovxD/JT32COmK0R20DLDoofBdtBkFlB/VkrbxYfX/cWXX1K
        WQVJuQ/H1xP9m4c4S8g/nM63rLUBOIkn06TcXyI/mEgRecEUDgC02PNXc5BDgB4A
        seXx+BiLC/f6+64KOWODHEEm/iHjCyrOSZtdA2EbPCATfOHrj0EG5Y4V6d1Iw4WP
        kiOIQByHMbOzRwm91yd/gM1DTxdy3j5nqaMhCzrM/QeOhSf5FXkWpARawUsChwh+
        eCuSZDg218u/NkzCrTvCPTdY1q+MZ5d5qgID4VQrenjBJq4AZxsw74Zd2G2uRWlF
        paZ2pSCyAey19A/or2iG10tqNpXJzZy0HNhh7q/gKhQKKTh+ggzgOrRe2ZaxlbEy
        P45JQKcR9/WJAohnYQ8uZJ6oin5EsEdVkapdYu60aReRGeyTmq3RLnu3Zn5MR5RH
        1r+W03KQcQzmmpE5YrxKSZL6OriXQYEPTa9/mSZT6TEUIvRT8W5jGQ0CAwEAAQ==
        -----END RSA PUBLIC KEY-----
      '';
      tinc.pubkey_ed25519 = "DmiyfmRsWd8Qg6M/ZsAd5lFM+vnkwRTfnMH/jCFwWFF";
    };
    wiregrill = {
      ip6.addr = w6 "4d10";
      aliases = [
        "radio.w"
      ];
      wireguard.pubkey = ''
        iCe1O9qeziw18AlGuFt5tIxm6SIBtNpwO/6OZm9Bn30=
      '';
    };
  };
  ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHsvyWrMN2lupBmjI8nW+NUSJIDPkr8c90Z4BcuZ7Myi";
  syncthing.id = "KMDPLE5-7FBYYXH-PF5LEET-G2AWR33-7XAPZJU-5S3VOB7-ZX5Q74V-PZKI6QN";
}
