{ r6, w6, ... }:
{
  nets = rec {
    retiolum = {
      ip4.addr = "10.243.133.115";
      ip6.addr = r6 "daed";
      aliases = [
        "daedalus.r"
      ];
      tinc = {
        pubkey = ''
          -----BEGIN RSA PUBLIC KEY-----
          MIICCgKCAgEA5SYx0hfmZ25mFzlnzdeoB46nMfJcyEuiJvMqNjRaeTRGe1UYFMOV
          KdLYRqioMBbvIwU+7+1jslI3Tjfs9kWtt57p4ZqTUmfKZYkhA6onvKZUtQrv8M9c
          sMOUhrY4p/QRvON4b9o9bZGdzDAX43EsAfDMW8YZvS6P+SQNeGORX3pimQ5ODY5N
          P0rnFuYjGt3wAWcwyzmfKFedxcB/eDyYSjmhnkIwrODdS5rQyaCDKALSGBQ6bF4S
          rvgy7PbwP71o8jVlhndOGyvZJPyx4yjwENrRWh6Wgwy/i2GYXWuc0+/Lvjq/X2k5
          C2LPGTfZ4rJaRdaS8EvOAy7uADemSymIGn3EM7qgLb2ogcQOFVtBHwWXYepLmbQi
          lnGiE83eDcXKUs8lmnZQTP8C+Ho/SQCVXpgOg29BdwIZJ26Gv1ueVlhOKIvF7Pay
          huRbQywgo7jnvNKk5TEGAX3bhUctT+UBJ+7JDHUJdqgJYKilYWwrK0jBVLSRqGTa
          UHPCyM5zLdX6G8CXK7v+CbH66GsZxSkfxYjv049CWdbQ/BAW5hWUW77xTnP81/yi
          3a2XxtxxmCiGxl3+eqtXh5q2bOB/JKffGYfblHXJ3NK6HH5qVpcjT7CHKO21gqsb
          hdPbKKD5aB2EJm+DYOnxS1UYsj7R/SmKGmNuQVfBm6jsBmjc4XmZQWECAwEAAQ==
          -----END RSA PUBLIC KEY-----
        '';
        pubkey_ed25519 = "+xM97iA8eIB58bfsEjMfK7aqv+Emzajx5CYqSGjRR/K";
      };
    };
    wiregrill = {
      ip6.addr = w6 "daed";
      aliases = [
        "daedalus.w"
      ];
      wireguard.pubkey = "1/ZN/YvIBpWJGIwf0EE5NpxnQVCsde8f5WR3LExRW0M=";
    };
  };
  ssh.pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAjmN3oUAj/3AFH0t4JdCjWn+AzyYyr8Dhp0oqq9Nzbu";
}
