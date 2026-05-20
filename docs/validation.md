# Validation

Use this in two passes: first static checks, then first-start checks on a real host.

## Static Checks

Run from the repo root:

```bash
nix flake check
```

If you are on Linux, or you have a Linux builder available:

```bash
nix build .#nixosConfigurations.example-host.config.system.build.toplevel
```

If your `Nix` install does not enable flakes by default:

```bash
nix --extra-experimental-features "nix-command flakes" flake check
```

Linux build with flakes enabled explicitly:

```bash
nix --extra-experimental-features "nix-command flakes" build .#nixosConfigurations.example-host.config.system.build.toplevel
```

On macOS or another non-Linux system, the useful static proof is evaluation rather than a full `NixOS` closure build:

```bash
nix eval .#nixosConfigurations.example-host.config.system.build.toplevel.drvPath
```

## First-Start Checks

After deploying to a real host:

```bash
systemctl status podman-linkding.service --no-pager
podman ps --format 'table {{.Names}}\t{{.Status}}'
curl -fsSI http://127.0.0.1:9090/
podman logs --tail=50 linkding
```

Expected:

- `podman-linkding.service` is active
- the `linkding` container is running
- the local HTTP check returns a normal response
- the logs do not show missing env file, migration failure, or permission failure

## First-User Checks

If you are not using the startup env variables for a first user, create one manually:

```bash
podman exec -it linkding python manage.py createsuperuser --username=replace-me --email=replace-me@example.test
```

Then verify:

- the login page loads
- the created user can authenticate
- adding a bookmark works

## Backup Checks

The official `linkding` backup docs describe a full backup command. For the default SQLite-backed single-container setup, validate that your mounted data directory is actually the thing being protected.

Example command inside the running container:

```bash
podman exec -it linkding python manage.py full_backup /etc/linkding/data/backup.zip
```

That command is useful only if you already made a deliberate decision about where `/etc/linkding/data` lands on the host and how that host path is backed up.
