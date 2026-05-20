{ config, lib, ... }:
let
  cfg = config.suiteDespair.services.linkding;
in
{
  options.suiteDespair.services.linkding = {
    enable = lib.mkEnableOption "Linkding example service";

    image = lib.mkOption {
      type = lib.types.str;
      default = "ghcr.io/sissbruecker/linkding:latest";
      description = "OCI image reference for the Linkding container.";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/srv/linkding";
      description = "Host directory that stores Linkding state.";
    };

    envFile = lib.mkOption {
      type = lib.types.str;
      default = "/etc/linkding/linkding.env";
      description = "Environment file passed to the Linkding container.";
    };

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address on the host to bind Linkding to.";
    };

    listenPort = lib.mkOption {
      type = lib.types.port;
      default = 9090;
      description = "Host port to bind Linkding to.";
    };

    publicBaseUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://bookmarks.example.test";
      description = "Public URL used for CSRF trusted origins when a reverse proxy sits in front.";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.containers.enable = true;
    virtualisation.podman.enable = true;
    virtualisation.oci-containers.backend = "podman";

    # Create the host-side state path before the service starts so the bind
    # mount lands on a deliberate directory, not an accidental placeholder.
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 root root -"
    ];

    virtualisation.oci-containers.containers.linkding = {
      image = cfg.image;
      autoStart = true;
      ports = [ "${cfg.listenAddress}:${toString cfg.listenPort}:9090" ];
      environmentFiles = [ cfg.envFile ];
      environment = {
        LD_CSRF_TRUSTED_ORIGINS = cfg.publicBaseUrl;
      };
      volumes = [ "${cfg.dataDir}:/etc/linkding/data" ];
    };
  };
}
