{
  description = "nether network";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  inputs.clan-core.url = "git+https://git.clan.lol/clan/clan-core";
  inputs.clan-core.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, clan-core }:
  {
    inherit (clan-core.lib.buildClan {
      clanName = "nether";
      directory = self;
      machines.controller = {
        imports = [
          self.nixosModules.controller
          self.nixosModules.hosts
          ./machines/controller/configuration.nix
        ];
        clan.networking.zerotier = {
          controller = {
            enable = true;
            public = false;
          };
        };
        clan.networking.deploymentAddress = "root@157.90.232.92";
        services.openssh.enable = true;
        users.users.root.openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDIb3uuMqE/xSJ7WL/XpJ6QOj4aSmh0Ga+GtmJl3CDvljGuIeGCKh7YAoqZAi051k5j6ZWowDrcWYHIOU+h0eZCesgCf+CvunlXeUz6XShVMjyZo87f2JPs2Hpb+u/ieLx4wGQvo/Zw89pOly/vqpaX9ZwyIR+U81IAVrHIhqmrTitp+2FwggtaY4FtD6WIyf1hPtrrDecX8iDhnHHuGhATr8etMLwdwQ2kIBx5BBgCoiuW7wXnLUBBVYeO3II957XP/yU82c+DjSVJtejODmRAM/3rk+B7pdF5ShRVVFyB6JJR+Qd1g8iSH+2QXLUy3NM2LN5u5p2oTjUOzoEPWZo7lykZzmIWd/5hjTW9YiHC+A8xsCxQqs87D9HK9hLA6udZ6CGkq4hG/6wFwNjSMnv30IcHZzx6IBihNGbrisrJhLxEiKWpMKYgeemhIirefXA6UxVfiwHg3gJ8BlEBsj0tl/HVARifR2y336YINEn8AsHGhwrPTBFOnBTmfA/VnP1NlWHzXCfVimP6YVvdoGCCnAwvFuJ+ZuxmZ3UzBb2TenZZOzwzV0sUzZk0D1CaSBFJUU3oZNOkDIM6z5lIZgzsyKwb38S8Vs3HYE+Dqpkfsl4yeU5ldc6DwrlVwuSIa4vVus4eWD3gDGFrx98yaqOx17pc4CC9KXk/2TjtJY5xmQ== lass@yubikey"
        ];
      };
    }) clanInternals nixosConfigurations;
    lib = {
      hosts = nixpkgs.lib.mapAttrs' (file: _:
        let
          name = nixpkgs.lib.removeSuffix ".json" file;
        in
          nixpkgs.lib.nameValuePair name ((nixpkgs.lib.importJSON ./hosts/${file}) // { inherit name; })
      ) (builtins.readDir ./hosts);
      network-id = builtins.readFile ./machines/controller/facts/zerotier-network-id;
      ipForHost = nwid: id: builtins.concatStringsSep ":" (builtins.genList (p: builtins.substring (p * 4) 4 "fd${nwid}9993${id}") 8);
    };
    nixosModules = {
      hosts = {
        networking.extraHosts = nixpkgs.lib.concatMapStringsSep "\n" (host:
          "${self.lib.ipForHost self.lib.network-id host.address} ${host.name}.n"
        ) (nixpkgs.lib.attrValues self.lib.hosts);
      };
      zerotier = {
        # TODO get module from clan-core here
      };
      controller = { pkgs, ... }: {
        systemd.services.nether-autoaccept = {
          wantedBy = [ "multi-user.target" ];
          after = [ "zerotierone.service" ];
          path = [ clan-core.packages.x86_64-linux.zerotierone ];
          serviceConfig.ExecStart = pkgs.writeScript "nether-autoaccept" ''
            #!/bin/sh
            ${nixpkgs.lib.concatMapStringsSep "\n" (host: ''
              ${clan-core.packages.${pkgs.system}.zerotier-members}/bin/zerotier-members allow ${host.address}
            '') (nixpkgs.lib.attrValues self.lib.hosts)}
          '';
        };
      };
    };
  };
}
