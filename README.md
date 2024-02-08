# nether network

this is a flake which exports some functions to join the nether network

## join with clan

If you are already using clan, you can just import this flake and configure it like this:

```nix
...
imports = [
  self.nether.nixosModules.hosts
];
clan.networking.zerotier = {
  networkId = "ccc5da5295c853d4";
  name = "nether";
};
```

## Join with standalone flakes

If you don't use cLAN network or
don't want this network as your primary.
You can import our zerotier module:

```flake.nix
inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
inputs.nether.url = "github:lassulus/nether";
inputs.nether.inputs.nixpkgs.follows = "nixpkgs";

 outputs = { self, nixpkgs, nether }: {
    nixosConfigurations."mynixos" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit nether;
      };
      modules = [
       ./configuration.nix
       ./zerotier.nix
      ];
      ...
  }
```

```zerotier.nix
{ self, config, pkgs, nether, ... }:
{
  imports = [
        nether.nixosModules.hosts
        nether.nixosModules.zerotier
  ];

    networking.extraHosts = nether.nixosModules.hosts.networking.extraHosts;
}
```

## Adding host to network
First fork and then `git clone` the repository. Then
for your host to be accepted into the network the id needs to be whitelisted.

```
sudo zerotier-cli info -j | jq -c '{"address": .address}' > hosts/"$(hostname)".json
```

Add multiple hosts via ssh:

```
for i in host1 host2; do ssh "root@$i.r" zerotier-cli info -j | jq -c '{"address": .address}' > hosts/"$i".json; done
```

then create a PR with your host file
