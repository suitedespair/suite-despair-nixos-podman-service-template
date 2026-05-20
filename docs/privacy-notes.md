# Privacy Notes

This repo uses a real app, but it still has a strict privacy boundary.

What is deliberately not included:

- private hostnames
- real domains or routes
- private mount paths
- private users
- secret names from the private homelab
- reverse-proxy config copied from the private estate
- auth-proxy or `OIDC` config copied from the private estate
- backup target names
- public-edge or tunnel details

What is included instead:

- `example.test` hostnames
- generic host paths
- fake credential placeholders
- one small stateful container pattern

This repo should be rebuilt from the private R&D logic, not sanitised by search-and-replace. If a detail only makes sense when you already know the private estate, it does not belong here.
