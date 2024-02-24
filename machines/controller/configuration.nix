{ modulesPath, pkgs, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = [ "ata_piix" "virtio_pci" "xhci_pci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.loader.grub.devices = [ "/dev/sda" ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/84053adc-49bc-4e02-8a19-3838bf3a43fd";
    fsType = "ext4";
  };

  swapDevices = [ ];

  systemd.services.autoupdate = {
    startAt = "hourly";
    path = [ pkgs.nix ];
    serviceConfig.ExecStart = pkgs.writers.writeDash "autoupdate" ''
      set -efux
      toplevel=$(nix build --refresh 'github:nixos/nixpkgs-merge-bot#nixosConfigurations.nixpkgs-merge-bot.config.system.build.toplevel' --print-out-paths)
      "$toplevel"/bin/switch-to-configuration switch
    '';
  };
}
