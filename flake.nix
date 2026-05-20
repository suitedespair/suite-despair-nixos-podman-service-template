{
  description = "Linkding example service for a rebuildable NixOS homelab host";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }:
    let
      targetSystem = "x86_64-linux";
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f (import nixpkgs { inherit system; })
        );
      exampleHost = nixpkgs.lib.nixosSystem {
        system = targetSystem;
        modules = [
          self.nixosModules.default
          (
            { lib, ... }:
            {
              networking.hostName = "example-host";

              suiteDespair.services.linkding = {
                enable = true;
                dataDir = "/srv/linkding";
                envFile = "/etc/linkding/linkding.env";
                publicBaseUrl = "https://bookmarks.example.test";
              };

              boot.loader.grub.enable = lib.mkForce false;
              fileSystems."/" = lib.mkForce {
                device = "none";
                fsType = "tmpfs";
              };

              system.stateVersion = "25.11";
            }
          )
        ];
      };
    in
    {
      formatter = forAllSystems (pkgs: pkgs.nixfmt);

      nixosModules.default = import ./modules/linkding.nix;
      nixosModules.linkding = self.nixosModules.default;

      nixosConfigurations.example-host = exampleHost;

      checks = forAllSystems (
        pkgs: {
          module-eval = pkgs.writeText "linkding-module-eval"
            (builtins.toJSON {
              backend = exampleHost.config.virtualisation.oci-containers.backend;
              image = exampleHost.config.virtualisation.oci-containers.containers.linkding.image;
              ports = exampleHost.config.virtualisation.oci-containers.containers.linkding.ports;
              volumes = exampleHost.config.virtualisation.oci-containers.containers.linkding.volumes;
            });
        }
      );
    };
}
