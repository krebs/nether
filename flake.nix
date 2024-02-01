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
        ];
        services.getty.autologinUser = "root";
        clan.networking.zerotier = {
          controller = {
            enable = true;
            public = false;
          };
        };
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
      ipForHost = nwid: id: builtins.concatStringsSep ":" (builtins.genList (p: builtins.substring (p * 4) 4 "${nwid}9993${id}") 8);
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
          path = [ pkgs.zerotier ];
          serviceConfig.ExecStart = pkgs.writeScript "nether-autoaccept" (nixpkgs.lib.concatMapStringsSep "\n" (host: ''
            ${clan-core.packages.${pkgs.system}.zerotier-members}/bin/zerotier-members allow ${host.address}
          '') (nixpkgs.lib.attrValues self.lib.hosts));
        };
      };
    };
  };
}
