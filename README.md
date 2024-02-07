# nether network

this is a flake which exports some functions to join the nether network

## join with clan

If you are already using clan, you can just import this flake and configure it like this:

flake.nix:
```nix
{
  inputs = {
    # Add this input for nether
    nether.url = "github:Lassulus/nether";
  }
}
```

configuration.nix:
```nix
{inputs, ...}: {
  imports = [
    inputs.nether.nixosModules.hosts
  ];
  clan.networking.zerotier = {
    networkId = "ccc5da5295c853d4";
    name = "nether";
  };
}
```

## join without clan

if you don't use clan or don't want this network as your primary. you can import our zerotier module:

```nix
{inputs, ...}: {
  imports = [
    inputs.nether.nixosModules.hosts
    inputs.nether.nixosModules.zerotier
  ];
}
```

## Adding host to network
First `git clone` this repository. Then
for your host to be accepted into the network the id needs to be whitelisted.

```
sudo zerotier-cli info -j | jq -c '{"address": .address}' > hosts/"$(hostname)".json
```

Add multiple hosts via ssh:

```
for i in host1 host2; do ssh "root@$i.r" zerotier-cli info -j | jq -c '{"address": .address}' > hosts/"$i".json; done
```

then create a PR with your host file
