# suite-despair-nixos-podman-service-template

Small `NixOS` example for adding one stateful `Podman` service to a rebuildable base host.

This repo is deliberately narrow. It shows one real app, `linkding`, with one persistent data directory, one env file, and one `NixOS` module using `virtualisation.oci-containers`.

It is not copied from a live homelab. All hostnames, paths, URLs, and credentials are placeholders.

## What It Includes

- one flake target: `example-host`
- one reusable module: `modules/linkding.nix`
- one env-file example for `linkding`
- one minimal validation checklist
- one service-intake note for the decisions around state, routing, and backup scope

## What It Does Not Include

- a full homelab platform
- a reverse proxy implementation
- `OIDC`, auth proxy, or secrets management
- a second database container
- copied private service config
- claims that `Podman` is universally better than `Docker`

## Why This Uses Podman On NixOS

This template uses `Podman` because it follows the built-in `NixOS` `virtualisation.oci-containers` path that the companion article is teaching.

`NixOS` can also drive OCI containers with a `Docker` backend, but that is a different runtime choice. Adding that here would create a second implementation story before the reader has even finished one boring working path.

The point of this repo is not "Podman wins." The point is "here is a small service pattern that fits cleanly on top of the A3-style base host."

## File Tree

```text
.
├── .gitignore
├── docs/
│   ├── privacy-notes.md
│   ├── service-intake.md
│   └── validation.md
├── examples/
│   └── linkding.env.example
├── flake.lock
├── flake.nix
└── modules/
    └── linkding.nix
```

## File Responsibilities

| File | Purpose |
| --- | --- |
| `.gitignore` | Keeps local Nix build outputs and direnv files out of Git. |
| `flake.nix` | Pins `nixpkgs`, exports the module, and defines one evaluation target, `example-host`. |
| `flake.lock` | Records the exact pinned `nixpkgs` revision. |
| `modules/linkding.nix` | Defines a small `linkding` module with explicit state path, env-file path, and public base URL settings. |
| `examples/linkding.env.example` | Placeholder env file for first-user setup and reverse-proxy-safe origin settings. |
| `docs/service-intake.md` | Lists the decisions to make before treating a service as part of the homelab. |
| `docs/validation.md` | Lists static checks and first-start checks. |
| `docs/privacy-notes.md` | States what the repo deliberately leaves out. |

## Before Using It

Replace these values first:

- `suiteDespair.services.linkding.dataDir`
- `suiteDespair.services.linkding.envFile`
- `suiteDespair.services.linkding.publicBaseUrl`
- `examples/linkding.env.example` contents before using them anywhere real

The default `listenAddress` is `127.0.0.1`. That is deliberate. It assumes you will either:

- keep the service local-only, or
- place a reverse proxy in front of it later

If you bind it to a non-loopback address, review firewall scope before pretending that was an innocuous little change.

## Linkding Notes

The example uses:

- `ghcr.io/sissbruecker/linkding:latest`
- the default SQLite-backed single-container model
- `/etc/linkding/data` inside the container as the durable data path

Per the official `linkding` docs, that data directory holds the SQLite database plus bookmark assets, favicons, and preview files. That is the thing you must back up if this stops being a disposable experiment.

## Validation

With `Nix` installed:

```bash
nix flake check
```

If your `Nix` install has flakes disabled by default:

```bash
nix --extra-experimental-features "nix-command flakes" flake check
```

If you are on a Linux machine, or you have a Linux remote builder available, you can also build the example host closure:

```bash
nix build .#nixosConfigurations.example-host.config.system.build.toplevel
```

On macOS or another non-Linux machine, use an eval check instead:

```bash
nix eval .#nixosConfigurations.example-host.config.system.build.toplevel.drvPath
```

After deployment on a real host:

```bash
systemctl status podman-linkding.service --no-pager
podman ps --format 'table {{.Names}}\t{{.Status}}'
curl -fsSI http://127.0.0.1:9090/
podman logs --tail=50 linkding
```

See [docs/validation.md](docs/validation.md) for the fuller checklist.

## Related Article

This repo supports the Suite Despair article draft:

- `A6 - Adding Homelab Services Declaratively with NixOS and Podman`
