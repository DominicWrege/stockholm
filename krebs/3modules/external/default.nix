with import <stockholm/lib>;
{ config, ... }: let

  hostDefaults = hostName: host: flip recursiveUpdate host ({
    ci = false;
    external = true;
    monitoring = false;
  } // optionalAttrs (host.nets?retiolum) {
    nets.retiolum.ip6.addr =
      (krebs.genipv6 "retiolum" "external" { inherit hostName; }).address;
  } // optionalAttrs (host.nets?wiregrill) {
    nets.wiregrill.ip6.addr =
      (krebs.genipv6 "wiregrill" "external" { inherit hostName; }).address;
  });
  ssh-for = name: builtins.readFile (./ssh + "/${name}.pub");
  tinc-for = name: builtins.readFile (./tinc + "/${name}.pub");

in {

  hosts = mapAttrs hostDefaults {
    catullus = {
      owner = config.krebs.users.kmein;
      nets = {
        retiolum = {
          ip4.addr = "10.243.2.3";
          aliases = [ "catullus.r" ];
          tinc.pubkey = ''
            -----BEGIN PUBLIC KEY-----
            MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA2tRtskPP6391+ZX9xzsx
            CUotXuqYucYmnUbrRSIlxASVqTmAf3nDOE5EDBBcTdSwnb02JcJW4Zh7+BGgMxjF
            GxDPs6ETI28mHK+6rp8TOkMnyDb5mtSGVZPvKJU9fFOt6aAX1J1BzTfwtHtVQq7K
            WBzdpeKXlw4dIQ6K6SGmPIPpEh9pE1Xb+GuVljCXKxGJFbW40dmh2ZdadO7umBDu
            vRk08jT9/BUnUP6KrZlvyePnG38z6srMrVU+XAHu5D2qZ9y+QIp3kw7Y5JUrNXc7
            9q9P9TYx15GiIz2mSJKcLVmkLRebsaqdV7dBibPbfdGE+NB+F1FYPGDdW4cnonon
            DzzjGm/FDfOCXEnSkYGQDBWpfd/8AWum1xGJxJCPNBJElGE2o5jDWo4Y1b9gHP0M
            vARm8AOK8R1pQ7BP+pNMO0gGw2NDrtWiWpTeZ7SqXmZAZ/Gmyen9X+/fowcbTyDH
            b9joIuMQeOtxbUV2JprZIdit9NBFSZq/7Re/GBUwjGBm3LabIXFNGKZovx/f9lf8
            r5tVs4SPauiKzZS0K1Gz1NSq+3OXaY5EwVrBUXptYqRT7uyhVloOPRUsqRFeB0Fn
            Y5xOpDJ0UiJxgFbdH5Vb81D/VjNO9Q4nZib8wSEuLrYLHGoceQPX4+Ov9IdhIL4B
            BMTCaF+VCWC5PCLr0e61KqMCAwEAAQ==
            -----END PUBLIC KEY-----
          '';
        };
      };
    };
    wilde = {
      owner = config.krebs.users.kmein;
      nets = {
        retiolum = {
          ip4.addr = "10.243.2.4";
          aliases = [ "wilde.r" ];
          tinc.pubkey = ''
            -----BEGIN PUBLIC KEY-----
            MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAtz/MY5OSxJqrEMv6Iwjk
            g/V58MATljj+2bmOuOuPui/AUYHEZX759lHW4MgLjYdNbZEoVq8UgkxNk0KPGlSg
            2lsJ7FneCU7jBSE2iLT1aHuNFFa56KzSThFUl6Nj6Vyg5ghSmDF2tikurtG2q+Ay
            uxf5/yEhFUPc1ZxmvJDqVHMeW5RZkuKXH00C7yN+gdcPuuFEFq+OtHNkBVmaxu7L
            a8Q6b/QbrwQJAR9FAcm5WSQIj2brv50qnD8pZrU4loVu8dseQIicWkRowC0bzjAo
            IHZTbF/S+CK0u0/q395sWRQJISkD+WAZKz5qOGHc4djJHBR3PWgHWBnRdkYqlQYM
            C9zA/n4I+Y2BEfTWtgkD2g0dDssNGP5dlgFScGmRclR9pJ/7dsIbIeo9C72c6q3q
            sg0EIWggQ8xyWrUTXIMoDXt37htlTSnTgjGsuwRzjotAEMJmgynWRf3br3yYChrq
            10Exq8Lej+iOuKbdAXlwjKEk0qwN7JWft3OzVc2DMtKf7rcZQkBoLfWKzaCTQ4xo
            1Y7d4OlcjbgrkLwHltTaShyosm8kbttdeinyBG1xqQcK11pMO43GFj8om+uKrz57
            lQUVipu6H3WIVGnvLmr0e9MQfThpC1em/7Aq2exn1JNUHhCdEho/mK2x/doiiI+0
            QAD64zPmuo9wsHnSMR2oKs0CAwEAAQ==
            -----END PUBLIC KEY-----
          '';
        };
      };
    };
    homeros = {
      owner = config.krebs.users.kmein;
      nets = {
        retiolum = {
          ip4.addr = "10.243.2.1";
          aliases = [
            "homeros.r"
          ];
          tinc.pubkey = ''
            -----BEGIN PUBLIC KEY-----
            MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAoZq6BwB6rV6EfTf8PWOd
            ZhEWig5VcK1FcH0qi7KgojAhGSHhWmtFlvRSoGpQrSFRN0g5eTnrrguuTiIs6djc
            6Al9HMqwSD1IOkqFm8jM4aG5NqjYg3in6blOFarBEOglfnsYHiUPt6T4fERxRZ9v
            RguEWrishNMSv+D4vclKwctTB/6dQNsTAfnplcyDZ9un/ql9BG2cgU9yqeYLDdXd
            vRvrWX9eZKGJvTrQmAiKONlSvspr1d28FxcUrUnCsdRLvP3Cc4JZiUhSA7ixFxn3
            +LgGIZiMKTnl8syrsHk5nvLi5EUER7xkVX8iBlKA4JD4XTZVyBxPB1mJnOCUShQc
            QK6nVr6auvJbRn7DHHKxDflSBgYt4qaf92+5A4xEsZtgMpmIFH5t6ifGQsQwgYsm
            fOexviy9gMyZrHjQDUs4smQxxYq3AJLdfOg2jQXeAbgZpCVw5l8YHk3ECoAk7Fvh
            VMJVPwukErGuVn2LpCHeVyFBXNft4bem1g0gtaf2SuGFEnl7ABetQ0bRwClRSLd7
            k7PGDbdcCImsWhqyuLpkNcm95DfBrXa12GETm48Wv9jV52C5tfWFmOnJ0mOnvtxX
            gpizJjFzHz275TVnJHhmIr2DkiGpaIVUL4FRkTslejSJQoUTZfDAvKF2gRyk+n6N
            mJ/hywVtvLxNkNimyztoKKMCAwEAAQ==
            -----END PUBLIC KEY-----
          '';
        };
      };
    };
    horisa = {
      cores = 2;
      owner = config.krebs.users.ulrich; # main laptop
      nets = {
        retiolum = {
          ip4.addr = "10.243.226.213";
          ip6.addr = "42:0:e644:9099:4f8:b9aa:3856:4e85";
          aliases = [
            "horisa.r"
          ];
          tinc.pubkey = tinc-for "horisa";
        };
      };
    };
    idontcare = {
      owner = config.krebs.users.Mic92;
      nets = rec {
        retiolum = {
          addrs = [
            config.krebs.hosts.idontcare.nets.retiolum.ip4.addr
            config.krebs.hosts.idontcare.nets.retiolum.ip6.addr
          ];
          ip4.addr = "10.243.29.177";
          aliases = [ "idontcare.r" ];
          tinc.pubkey = ''
            -----BEGIN RSA PUBLIC KEY-----
            MIIBCgKCAQEAxmmbQLVXcnCU9Vg9TCoJxfq/RyNfzaTj8XJsn4Kpo3CvQOwFzL6O
            qZnbG55WjPjPumuFgtUdHA/G8mgtrTVaIRbVE9ck2l2wWFzMWxORzuvDbMh5xP8A
            OW2Z2qjlH6O9GTBCzpYyHuyBWCjtiN4x9zEqxkIsBARKOylAoy3zQIiiQF0d72An
            lqKFi9vYUU90zo9rP8BTzx2ZsEWb28xhHUlwf1+vgaOHI1jI99gnr12dVYl/i/Hb
            O28gDUogfpP/5pWFAHJ+53ZscHo8/Y7imjiKgGXmOHywoXOsKQ67M6ROEU/0xPnw
            jKmq2p7zTJk2mDhphjePi5idd5yKNX5Q3wIDAQAB
            -----END RSA PUBLIC KEY-----
          '';
        };
      };
    };
    jongepad = {
      owner = config.krebs.users.jonge;
      nets = {
        retiolum = {
          ip4.addr = "10.243.5.6";
          aliases = [
            "jongepad.r"
          ];
          tinc.pubkey = ''
            -----BEGIN RSA PUBLIC KEY-----
            MIICCgKCAgEAtJsF5jL/M72PCptLFC5iIEt0qAL544H/VLijvZEG9gnoqbs94aNJ
            MM5Sr3yMB01WkcT1Lph3r4dxV0/QECu3Ca4xxuUntu42tFXhkikQGcZLuo2h4zr4
            +wReudCCc7VqMcJDxriyyoW3i7smZnQGzo36gpKHbZfil8dJo0QE8mnujqkQCA0G
            hjR7xdG+/usDgRUarfpNgoHKyZfLcomQLUuR8I3aHsdaCLgMJ8v5DjGymp2bIswT
            puPx3IEZSXH8y6MZoISvLn+hwcWat34Bj1PF7vfgldivqHaDFpifpXvjbCmxcel9
            WVZRSEvLSVT4FnpaJ7JkAaUpG+GOHVlPWARq9t9AZXKR1Zex9MIkHzWi/TIIkawj
            wJNvUwvBYJ1UCuCby4/3nKlY7zWjj23YM6dTJDGMhJKR5m2SHp9SC0m0QdfSjN5z
            8sJauCigGZ6rlmxkO4/2BBGshY8jWDl/z2oFiQfo7R2oZkJdWNHLGKtTZtqQQ3e6
            SAE/HQvipiv35rMzHw3E9AJBhhQqT3vTLLZvMTBS6BRFvpqDNhXik1aFenNV4tjZ
            XeYU1eXI4XzQqoW/avPTuLt8O0Ya/nziLXCaIy+hlx5Hd49hkGb+1saQ5yPUgoEt
            wE9sy5+9b5ebn8B+N0yw7wnUYN8V8dmPmRwLt71IuBwHn/aAoXyWwFsCAwEAAQ==
            -----END RSA PUBLIC KEY-----
          '';
        };
      };
    };
    justraute = {
      owner = config.krebs.users.raute; # laptop
      nets = {
        retiolum = {
          ip4.addr = "10.243.183.231";
          aliases = [
            "justraute.r"
          ];
          tinc.pubkey = tinc-for "justraute";
        };
      };
    };
    qubasa = {
      owner = config.krebs.users.qubasa;
      nets = {
        retiolum = {
          ip4.addr = "10.243.29.175";
          aliases = [ "qubasa.r" ];
          tinc.pubkey = ''
            -----BEGIN RSA PUBLIC KEY-----
            MIICCgKCAgEA65g1Xql+S+Dd90uDpSVxzGRTL8n4DHc1p9T8u9h7ioytC9B+e2dQ
            RU/y3gdJ0gXxrbth36MhTANuUonnqpHvsWwUDCQRbxLEFh8avlzLsecWvwrIt3zL
            102EaVurRySUa83D6TK8ZsDa2+ADY7tEzfFMJhT53g7MpBNIeOquB0rR6hVYBbHc
            3B+QtwdM8dx1gO/5+FsPYhJbR7ARczYHsj7Eyb8NbdzthEO0ICDgwzmcXTJfVHGR
            qfT7DUolXsu7uSPMLB+Pe/leI7XcQ2VFukpVGP0fZv0mSMxavFlcFVkLgdbAEd2H
            DPEBEcJpLR4Hw3HlO1kPPufaUdoeNhUmTkIp76mkCbanS1P/aFNFFcVB+a/+tpdK
            z5pG8K3qANg5txp6sAatPchvkeQelIg11lvT9luc+nFsTEW6Ky5nDLo60luZVFnn
            i1bdVeOojXR0u7M2gMqQZcSuscvy8APe48S8vPsqoiob1l/r77B7iNrWDwH8IutW
            u8fpC64CbhlR76Orp3xTZPmJQCRT8XYpKDDoq5Z7prdlAEz3U6wEfVckVv+f1dmU
            odG0zDTsmyKhkWWmZbPgPrOEUvAVoSpSLSQQxPR+UHArlgYe+2dAf8IHYqrgmhuO
            D4Lga4nNwTyVbCZ8vUu5b/lnGCLpNcVj22WVQTdAJzNsCVTdIM2V5hcCAwEAAQ==
            -----END RSA PUBLIC KEY-----
          '';
        };
      };
    };
    rilke = {
      owner = config.krebs.users.kmein;
      nets.wiregrill = {
        aliases = [ "rilke.w" ];
        wireguard.pubkey = "09yVPHL/ucvqc6V5n7vFQ2Oi1LBMdwQZDL+7jBwy+iQ=";
      };
    };
    rock = {
      owner = config.krebs.users.Mic92;
      nets = {
        retiolum = {
          ip4.addr = "10.243.29.171";
          aliases = [ "rock.r" ];
          tinc.pubkey = ''
            -----BEGIN RSA PUBLIC KEY-----
            MIICCgKCAgEAsMJbXDhkaLZcEzCIe8G+rHyLulWIqrUAmDT4Vbtv4r0QhPBsqwjM
            DuvRtX5SNHdjfZWnUZoOlmXrmIo07exPFQvyrnppm6DNx+IZ5mNMNVIFUoojRhF7
            HS2jubcjTEib56XEYWKly0olrVMbsJk5THJqRQyOQuTPCFToxXVRcT5t/UK6Dzgh
            mp+suJ7IcmmO80IwfZrQrQslkQ6TdOy1Vs908GacSQJyRxdRxLraU/98iMhFbAQf
            Ap+qVSUU88iCi+tcoSYzKhqU2N0AhRGcsE073B3Px8CAgPK/juwTrFElKEc17X9M
            Rh41DvUjrtG4ERPmbwKPtsLagmnZUlU8A5YC8wtV08RI5QBsbbOsKInareV1aLeD
            91ZVCBPFTz8IM6Mc6H435eMCMC2ynFCDyRGdcue3tBQoaTGe1dbduIZkPGn+7cg4
            fef1db6SQD4HCwDLv8CTFLACR/jmAapwZEgvJ3u3bpgMGzt+QNvL1cxUr3TBUWRv
            3f0R+Dj8DCUWTJUE7K5LO7bL4p9Ht0yIsVH+/DucyoMQqRwCwWSr7+H2MAsWviav
            ZRRfH0RqZPEzCxyLDBtkVrx+GRAUZxy1xlqmN16O/sRHiqq3bv8Jk3dwuRZlFu6q
            cOFu4g9XsamHkmCuVkvTGjnC2h21MjUUr3PGHzOMtiM/18LcfX730f8CAwEAAQ==
            -----END RSA PUBLIC KEY-----
          '';
        };
      };
    };
    scardanelli = {
      owner = config.krebs.users.kmein;
      nets = {
        retiolum = {
          ip4.addr = "10.243.2.2";
          aliases = [
            "scardanelli.r"
          ];
          tinc.pubkey = ''
            -----BEGIN PUBLIC KEY-----
            MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxM93+YgGhk5PtcOrE7E/
            MAOMF/c9c4Ps6m8xd4VZat3ru07yH8Yfox1yM6jwZBwIwK2AC9DK0/k3WIvZQUge
            UKSTiXpE4z/0ceaesugLQ9KTjUty1e/2vQ78bOqmd7EG3aPV2QsjlgpjJ6qQxeFi
            kjlHoFi9NNBLVkIyaAdlAhwvZuYFmAY/FQEmm6+XOb+Nmo+fccQlG6+NinA2GOg0
            gdY/dKYxa04Ns/yu7TK3sBQIt6cg/YUk9VpyC4yIIRPMdyVcAPz3Kd2mp23fhSvx
            we80prWXYtdct4vXaBZm9FUY5y4SL3c0TEScuM73VXtr2tPAxjD5W4XMWhrjnIiY
            QzoyAquVS9rR4fCaoP+hw3Tjy7Att3voa/YlHEDaendxjZ3nuO0m0vcgOa+SfCNm
            SqLsqb8to1y8yJ8LnR2og4MbtasxqSe1L9VLTsb4k/AGfmAdlqyG4Q1h5pCBh0GL
            2F6FbYHzwrwqBvVCz4DTPygPtta5o7THpP50PgojtzNLm1yKWpfdcWeMgGQJSI0f
            m3yenytM1u0jjw7KbBG79Z3etFNIYZy4Uq/dryEJnwpTFls+zZn9Q3tDEnO4a38Q
            FgzV0VLQpRM/uf1powSDzoWp+/JYgB9464OKcTsSlVJpi3crxF86xFqqc39U2/u5
            lM61fOMcVW1KREdWypiDtu8CAwEAAQ==
            -----END PUBLIC KEY-----
          '';
        };
      };
    };
    sokrateslaptop = {
      owner = config.krebs.users.sokratess;
      nets = {
        retiolum = {
          ip4.addr = "10.243.142.104";
          aliases = [
            "sokrateslaptop.r"
          ];
          tinc.pubkey = ''
            -----BEGIN RSA PUBLIC KEY-----
            MIIBCgKCAQEA0EMbBv5NCSns4V/VR/NJHhwe2qNLUYjWWtCDY4zDuoiJdm3JNZJ2
            t0iKNxFwd6Mmg3ahAlndsH4FOjOBGBQCgBG25VRnQgli1sypI/gYTsSgIWHVIRoZ
            rgrng0K3oyJ6FuTP+nH1rd7UAYkrOQolXQBY+LqAbxOVjiJl+DpbAXIxCIs5TBeW
            egtBiXZ1S53Lv5EGFXug716XlgZLHjw7PzRLJXSlvUAIRZj0Sjq4UD9VrhazM9s5
            aDuxJIdknccEEXm6NK7a51hU/o8L+T0IUpZxhaXOdi6fvO/y3TbffKb1yRTbN0/V
            VBjBh18Le7h0SmAEED5tz7NOCrAjMZQtJQIDAQAB
            -----END RSA PUBLIC KEY-----
          '';
        };
      };
    };
    toastbrot = {
      owner = config.krebs.users.jan;
      nets = {
        retiolum = {
          ip4.addr = "10.243.117.12";
          aliases = [
            "toastbrot.r"
          ];
          tinc.pubkey = ''
            -----BEGIN PUBLIC KEY-----
            MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA12VLPJMhGSh5fQgrB6bP
            2H1eew0/7t1xr3oJ3uaTZd7UIvPQ/aA5pB9xL5s+BIBvRa5P3QFWUAVhqchsPiRc
            yC4awLvo6zrUZB3pJBFiUuThx1xzmazTbRNyJ0E3Dwi2VSp3dAi5xEwHSVDSElGj
            DyRrdwyLe9lKghGHgNhB01QAt1/AO3A/TBs2RS/E0kuPhVQzpo5Ae5I530Cr0pf3
            r/de1TdArIcOfnTvW7WNrdBhwLq14cfdXkZwJ2bBE9Q22FAJp5k21PW5dQ41oDuT
            PYHZIH555sxifMThrUpuNHIrDtIQk6D+Km90WNf/lBGwZqQr/B5G6zSNX7d/0JbY
            Hi8Ltq++Sf0XgWNir9+evGNLCBqAXdvQFrj2l7BuNywE0L2nZThnxjTxP6QLFnqO
            IXY97x3p7AYcfmVFutfYqYM1HdyyehF711hhm30fdcXHsJ+GpQgGrj67+++N7g7g
            fjWBGNI9EL9CyTZ/N9U3TGeoxooc1BSaAiHmaPoYaAeI0Y/W6bNrixpL3aI5X8MH
            Flen2y2XEk2n+pXozPDbLAT+MZ3sWwODDYRc8zGbV2RlMvL94LHh95/JC0itdXa3
            uNRDtSnfbNe4eHw9/HMDkclhywuE+hbyq+JNNodqLwG/o1/r3GI+ggOyCdZHjF4B
            4R8QXUJiqUdcbR3WQDR5i10CAwEAAQ==
            -----END PUBLIC KEY-----
          '';
        };
      };
    };
    tpsw = {
      cores = 2;
      owner = config.krebs.users.ciko; # main laptop
      nets = {
        retiolum = {
          ip4.addr = "10.243.183.236";
          aliases = [
            "tpsw.r"
          ];
          tinc.pubkey = tinc-for "tpsw";
        };
      };
    };
    uppreisn = {
      owner = config.krebs.users.ilmu;
      nets = {
        retiolum = {
          ip4.addr = "10.243.42.13";
          aliases = [ "ilmu.r" ];
          tinc.pubkey = ''
            -----BEGIN PUBLIC KEY-----
            MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAweAz7KtgYVuAfqP7Zoax
            BrQ++qig30Aabnou5C62bYIf1Fn8Z9RbDROTmkGeF7No7mZ7wH0hNpRXo1N/sLNt
            gr4bX7fXAvQ3NeeoMmM6VcC+pExnE4NMMnu0Dm3Z/WcQkCsJukkcvpC1gWkjPXea
            gn3ODl2wbKMiRBhQDA2Ro0zDQ+gAIsgtS9fDA85Rb0AToLwifHHavz81SXF+9piv
            qIl3rJZVBo1kOiolv5BCh4/O+R5boiFfPGAiqEcob0cTcmSCXaMqis8UNorlm08j
            ytNG7kazeRQb9olJ/ovCA1b+6iAZ4251twuQkHfNdfC3VM32jbGq7skMyhX3qN/b
            WoHHeBZR8eH5MpTTIODI+r4cLswAJqlCk816bGMmg6MuZutTlQCRTy1S/wXY/8ei
            STAZ1IZH6dnwCJ9HXgMC6hcYuOs/KmvSdaa7F+yTEq83IAASewbRgn/YHsMksftI
            d8db17rEOT5uC1jOGKF98d7e30MX5saTJZLB6XmNDsql/lFoooGzTz/L80JUYiJ0
            fQFADznZpA+NE+teOH9aXsucDQkX6BOPSO4XKXV86RIejHUSEx5WdaqGOUfmhFUo
            9hZhr0qiiKNlXlP8noM9n+hPNKNkOlctQcpnatgdU3uQMtITPyKSLMUDoQIJlSgq
            lak5LCqzwU9qa9EQSU4nLZ0CAwEAAQ==
            -----END PUBLIC KEY-----
          '';
        };
      };
    };
    crustacea = {
      owner = config.krebs.users."0x4A6F";
      nets = {
        retiolum = {
          ip4.addr = "10.243.42.63";
          ip6.addr = "42:4a6f::4263";
          aliases = [
            "crustacea.r"
          ];
          tinc.pubkey = ''
            -----BEGIN RSA PUBLIC KEY-----
            MIICCgKCAgEA1dA67Uq6IcWTWVVcg5kO4OUcmYY/mUzERK6WwrU7m+Qq2ovA2Fh1
            VTxfNzJg8zgyrBbUwpaLE4LuRgyrYbPABwgNMXS6wnHdunbm0x5RUcih/IRNobV1
            uf2Q/rVcrXHZD5+YL09hTZnU7PVkZm6WX0fc79rEKYIEopPpomCs2mECPSmqZPaW
            L9wprtRTuQ3V0xxrCuUKX7SxANEursM8SvNfKydWdaUxjIV2iGVKuVUkAZHwx5jJ
            roKEriWsIJ6FHTMb1v5yWXrvngMgYlKrpF6/m/AHEkQoPsEJ+oBkn0fop9pfyZjM
            WzMhZHcKFYebSI4HqFRuQOc1scIzUdpC/sZYLYlddbwpJHj4xdJwIUN03Uga/KRQ
            n1SrJnhmXonHvJZFBYcNDR6aTtdN7mJVBv8bQ7DGt1q6Gp8QItQqvpdzq314+Pw6
            0EVKPaqdz6Cqpwn8RtJ9ZGb6BE3yUrpJkU25DyCSO86LmeCchApwssghWvPsbBDg
            iF4QCyrWJ2HFnl7jJDGbEajHaE/xko2dt1F5frTWxsmDHRKSRhaGDwp5qgFUpCa0
            2h+zZqkG4boV6CrMEjStb15EOXTUVfq0DPojFik6agCltslsJAwp+f1fb7NSee4d
            TNWb1CHfIQWLPnm1LFwphSqyHY/9ehcsX3PJ7oXI+/BnV8ivvoApWA0CAwEAAQ==
            -----END RSA PUBLIC KEY-----
            Ed25519PublicKey = DWfh6H8Qco+GURdVRhKhLBAsN5epsEYhOM2+88dTdTE
          '';
        };
      };
    };
    unnamed = {
      owner = config.krebs.users.pie_;
      nets = {
        retiolum = {
          ip4.addr = "10.243.3.14";
          aliases = [ "unnamed.r" ];
          tinc.pubkey = ''
            -----BEGIN PUBLIC KEY-----
            MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAvGXVl+WV/bDxFAnYnAhZ
            2rHCU5dqtBvSg0sywV1j++lEuELBx4Zq14qyjDRGkkIGdgzCZBLK2cCgxPJ3MRFx
            ZwiO3jPscTu3I7zju7ULO/LqGQG+Yf86estfGh394zFJ2rnFSwegeMNqCpOaurOH
            GuYtNdjkxn/2wj00s+JEJjCNRMg8bkTMT3czuTr2k+6ICI8SgLZMDH7TjRfePHEW
            X9/v4O3kMSZccT/wZWmezXuYlO7CJs7f4VV98z+sgubmIZz3uLfQFY8y9gmGp46y
            5n5QyD0iIqkLNGIldNnToVJPToRaW5OdNKtZFayU4pWZ296sEcJI0NWLYqy7yZfD
            PG2FlCQmebUxMYk+iK0cYRLFzOgnr14uXihXxhuHYJ8R1VIbWuto1YFGUv5J/Jct
            3vgjwOlHwZKC9FTqnRjgp58QtnKneXGNZ446eKHUCmSRDKl8fc/m9ePHrISnGROY
            gXMieAmOZtsQIxwRpBGCLjrr3sx8RRNY8ROycqPaQWp3upp61jAvvQW3SIvkp1+M
            jGvfebJOSkEZurwGcWUar9w9t/oDfsV+R9Nm9n2IkdkNlnvXD1rcj7KqbFPtGf1a
            MmB3AmwyIVv9Rk1Vpjkz4EtL4kPqiuhPrf1bHQhAdcwqwFGyo8HXsoMedb3Irhwm
            OxwCRYLtEweku7HLhUVTnDkCAwEAAQ==
            -----END PUBLIC KEY-----
            '';
        };
      };
    };
    miaoski = {
      owner = config.krebs.users.miaoski;
      nets = {
        wiregrill = {
          aliases = [ "miaoski.w" ];
          wireguard = {
            pubkey = "8haz9JX5nAMORzNy89VdHC1Z9XA94ogaZsY3d2Rfkl4=";
          };
        };
      };
    };
    ada = {
      owner = config.krebs.users.filly;
      nets = {
        wiregrill = {
          aliases = [ "ada.w" ];
          wireguard = {
            pubkey = "+t0j9j7TZqvSFPzgunnON/ArXVGpMS/L3DldpanLoUk=";
          };
        };
      };
    };
    domsen-backup = {
      owner = config.krebs.users.domsen;
      ci = false;
      external = true;
      syncthing.id = "22NLFY5-QMRM3BH-76QIBYI-OPMKVGM-DU4FNZI-3KN2POF-V4WIC6M-2SFFUAC";
      nets = {};
    };
  };
  users = {
    ciko = {
      mail = "wieczorek.stefan@googlemail.com";
    };
    exco = {
      mail = "dickbutt@excogitation.de";
      pubkey = ssh-for "exco";
    };
    ilmu = {
      mail = "ilmu@rishi.is";
    };
    jan = {
      mail = "jan.heidbrink@posteo.de";
    };
    jonge = {
      mail = "jacek.galowicz@gmail.com";
    };
    kmein = {
      mail = "kieran.meinhardt@gmail.com";
      pubkey = ssh-for "kmein";
    };
    Mic92 = {
      mail = "joerg@thalheim.io";
      pubkey = ssh-for "Mic92";
    };
    qubasa = {
      mail = "luis.nixos@gmail.com";
      pubkey = ssh-for "qubasa";
    };
    raute = {
      mail = "macxylo@gmail.com";
      pubkey = ssh-for "raute";
    };
    sokratess = {
    };
    ulrich = {
      mail = "shackspace.de@myvdr.de";
      pubkey = ssh-for "ulrich";
    };
    "0x4A6F" = {
      mail = "0x4a6f@shackspace.de";
      pubkey = ssh-for "0x4A6F";
    };
    xq = {
      mail = "xq@shackspace.de";
      pubkey = ssh-for "xq";
    };
    miaoski = {
    };
    filly = {
    };
    pie_ = {};
    domsen = {
    };
  };
}
