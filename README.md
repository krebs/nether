# nether network

this is a flake which exports some functions to join the nether network

## join with clan

If you are already using clan, you can just import this flake and configure it like this:

```
...
imports = [
  self.nether.nixosModules.hosts
];
clan.networking.zerotier = {
  networkId = "ccc5da5295c853d4";
  name = "nether";
};
```

## join without clan

if you don't use clan or don't want this network as your primary. you can import our zerotier module:

```
imports = [
  self.nether.nixosModules.hosts
  self.nether.nixosModules.zerotier
];
```

## Adding host to network
First `git clone` this repository. Then
for your host to be accepted into the network the id needs to be whitelisted.

```
sudo zerotier-cli info -j | jq -c '{"address": .address}' > hosts/"$(hostname)".json
```

then create a PR with your host file
