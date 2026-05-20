# Service Intake Notes

This repo is intentionally about one small service, not about pretending every app is the same.

Before adding a service to a rebuildable host, answer these questions:

## 1. Where Does The Durable State Live?

For `linkding`, the important container path is:

- `/etc/linkding/data`

That directory holds the SQLite database and related bookmark assets. If you do not bind-mount it to a deliberate host path, the service is effectively disposable no matter how declarative the container definition looks.

## 2. How Will The First User Be Created?

This template uses an env file for the first-user bootstrap placeholders.

That is convenient, but it also means:

- you should replace the placeholder values before first use
- you should decide whether that env file belongs in a secrets system later
- you should decide whether you prefer first-start env bootstrap or a one-time `createsuperuser` run

## 3. Will The Service Stay Local Or Sit Behind A Proxy?

The template binds to `127.0.0.1` by default.

That keeps the service narrow:

- local-only is fine for first validation
- later reverse-proxy exposure is a separate decision

If you do expose it through a proxy, the public URL and CSRF origin handling must stay aligned.

## 4. What Counts As A Healthy Service?

At minimum:

- the systemd unit starts cleanly
- `podman ps` shows the container as running
- the web UI answers on the expected local port
- the logs do not show immediate migration or permission failures

Do not confuse "container exists" with "service is usable."

## 5. What Is The Backup Boundary?

If the data directory matters, it needs a backup decision.

For the default single-container `linkding` setup, the backup boundary is the host directory mounted to `/etc/linkding/data`.

That is the decision the article is trying to teach: the hard part is not the image tag, it is deciding when state becomes real.
