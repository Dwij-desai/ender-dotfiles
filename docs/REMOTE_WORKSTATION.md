# EnderOS Remote Workstation

## Purpose

This architecture provides remote terminal and graphical access to an EnderOS Arch workstation from an untrusted or NATed network, such as a college network. It is designed for low maintenance, no inbound port forwarding, and independent recovery paths.

The terminal path is the operational baseline. RustDesk is the preferred graphical path, but loss of graphical access must never prevent administration or recovery through SSH.

## Goals

- Reach the workstation behind NAT without exposing home-router ports.
- Use SSH for concurrent terminal work, file review, and recovery.
- Use RustDesk to observe and operate the active Hyprland session while remote editors work.
- Keep all services independently understandable and reproducible on fresh Arch Linux.
- Avoid custom shell frameworks and repository-specific network daemons.

## Architecture Diagram

```text
College device
│
├── Tailscale client ───── encrypted tailnet ───── Tailscale client
│                                                │
│                                                ├── OpenSSH / Tailscale SSH
│                                                │   └── terminal administration
│                                                │
│                                                └── EnderOS workstation
│                                                    ├── Hyprland user session
│                                                    └── RustDesk host
│
└── RustDesk client ── outbound rendezvous/relay ── RustDesk host
                                                     └── active Hyprland session
```

Tailscale is the private management network. RustDesk uses its normal outbound rendezvous and relay flow for graphical sessions, attempting a direct connection first and relaying only when NAT traversal cannot establish one. No home-router port forwarding is required for either normal path.

## Component Responsibilities

### NetworkManager

Owns physical network connectivity on the workstation. It must be online before the remote services can establish outbound connectivity.

### Tailscale

Owns encrypted device-to-device reachability, device identity, and tailnet access policy. It is the preferred path for terminal access and must not be used to replace local network management.

### OpenSSH

Owns standard SSH compatibility and emergency terminal access. It supports normal SSH clients and remains available even when Tailscale SSH policy is not enabled.

### Tailscale SSH

Optionally owns tailnet-aware SSH authentication and authorization. It complements, rather than replaces, OpenSSH: access must be controlled by both tailnet network and SSH policy rules.

### RustDesk

Owns graphical remote access to the active user session. It is not an EnderOS Core dependency and must not be treated as an authentication or system-recovery replacement for SSH.

### Hyprland

Owns the active graphical session. RustDesk must attach only after a user session exists; remote access to the login screen or a locked Wayland session is not guaranteed.

## Required Packages

The terminal baseline requires standard Arch packages:

- `networkmanager`
- `openssh`
- `tailscale`

The EnderOS workstation must also include its normal Hyprland session dependencies.

## Optional Packages

- RustDesk client/host: preferred graphical remote-access layer. Its packaging source may be the official Arch package when available or an explicitly documented third-party package source; it must remain optional to EnderOS Core.
- A self-hosted RustDesk server: only when control over RustDesk rendezvous and relay infrastructure justifies its operational cost.
- Tailscale SSH: enable only after explicit tailnet ACL and SSH-policy design.
- `mosh`: optional resilient terminal transport; it does not replace SSH configuration or access control.

## Security Considerations

- Do not expose SSH or RustDesk service ports directly on the public internet.
- Use Tailscale device approval, multi-factor authentication, and least-privilege ACLs.
- Restrict SSH to key-based authentication; disable password login and direct root login during implementation.
- Limit SSH to the intended local account and, where appropriate, Tailscale addresses or interface.
- If Tailscale SSH is enabled, require both a tailnet network rule and a scoped SSH rule. Use `check` rules for sensitive access when reauthentication is appropriate.
- Protect RustDesk unattended access with a unique strong password and keep the host and client updated.
- Treat RustDesk relay infrastructure as transport, not as an authorization boundary. Prefer the official service initially; self-host only when its maintenance, firewall, patching, and key-management responsibilities are accepted.
- Keep a local login path and physical recovery method. Do not rely solely on remote software for lockout recovery.
- Review Tailscale machines and RustDesk authorized devices periodically; revoke lost devices immediately.

## Startup Services

Enable and verify these services during implementation:

1. `NetworkManager.service` — network connectivity.
2. `tailscaled.service` — tailnet connectivity after user authorization.
3. `sshd.service` — standard terminal recovery path.
4. RustDesk service — only if the selected RustDesk package provides and documents a host service suitable for unattended access.

RustDesk must also be tested within a running Hyprland user session. A package service alone does not prove it can capture or control that session on Wayland.

## Phase 1: OpenSSH and Tailscale Setup

Phase 1 implements terminal access only. It does not install or configure RustDesk.

1. Install `openssh` and `tailscale` using the standard Arch package manager.
2. Copy `config/ssh/sshd_config.d/99-enderos.conf` to `/etc/ssh/sshd_config.d/99-enderos.conf`.
3. Add the remote device's public key to the intended local account's `~/.ssh/authorized_keys` before enabling the hardened configuration.
4. Run `sudo scripts/remote/validate-sshd-config.sh` and keep the existing local terminal open until remote login is verified.
5. Enable and start OpenSSH with `sudo systemctl enable --now sshd.service`.
6. Enable and start Tailscale with `sudo systemctl enable --now tailscaled.service`.
7. Authenticate the workstation with `sudo tailscale up`; authenticate the remote device into the same tailnet.
8. Verify the workstation appears in the tailnet, then connect through its Tailscale hostname using key-based SSH.

The OpenSSH configuration is an Arch drop-in. It does not specify users, listen addresses, hostnames, or IP addresses. If an installation needs additional SSH behavior, add a separately reviewed drop-in rather than editing the EnderOS baseline.

### Reconnect Handling

`tailscaled.service` reconnects after network changes when enabled. If it is inactive, restore the service first, then run `sudo tailscale up` only when reauthentication or changed settings require it. Tailscale loss must not alter or restart OpenSSH.

## Verification Checklist

Run these repository scripts from the repository root after deployment:

```text
sudo scripts/remote/validate-sshd-config.sh
scripts/remote/check-ssh-service.sh
scripts/remote/check-tailscale-status.sh
scripts/remote/check-remote-reachability.sh TAILSCALE_HOST
```

`check-tailscale-status.sh` exits with status `2` when Tailscale is absent, making the missing optional transport explicit while leaving the SSH baseline unaffected. `check-remote-reachability.sh` requires one user-supplied Tailscale hostname; it stores no host identity in the repository.

## Troubleshooting

- `sshd -t` fails: do not restart `sshd`; correct the configuration error while retaining local access, then validate again.
- SSH rejects a login: verify the intended public key is in the target account's `authorized_keys` and test with `ssh -v` from the remote device.
- Tailscale is inactive: inspect `tailscaled.service`, restore network connectivity, then re-run `check-tailscale-status.sh`.
- Tailscale is connected but SSH fails: run `check-ssh-service.sh` on the workstation and confirm tailnet ACLs allow the remote device to reach SSH.
- A network prevents direct peer connectivity: allow Tailscale to use its relay path; do not add router port forwards as a workaround.

## Installation Order

1. Install and verify NetworkManager on the workstation.
2. Install OpenSSH; configure key-only access locally and verify a LAN SSH connection.
3. Install Tailscale; authenticate both workstation and remote device into the same tailnet.
4. Verify SSH through the workstation's Tailscale hostname or address.
5. Define least-privilege tailnet ACLs; optionally add Tailscale SSH policies.
6. Install RustDesk and verify a GUI session while physically present at the workstation.
7. Test remote RustDesk access from an external network, then test SSH simultaneously.
8. Document the tested recovery procedure before relying on unattended remote access.

## Network Flow

### Terminal Access

```text
Remote SSH client
  → Tailscale encrypted tunnel
  → workstation Tailscale address or hostname
  → OpenSSH or Tailscale SSH policy
  → Fish / tmux / development tools
```

Tailscale uses encrypted peer connectivity and coordinates NAT traversal. If a direct peer path is unavailable, its relay path preserves connectivity without opening inbound home-router ports.

### Graphical Access

```text
Remote RustDesk client
  → RustDesk rendezvous service
  → direct NAT traversal when possible
  → relay when direct traversal fails
  → RustDesk host in the active Hyprland session
```

Use the public RustDesk infrastructure first to minimize maintenance. A self-hosted `hbbs`/`hbbr` deployment is a future infrastructure choice, not part of the initial workstation implementation.

## Failure Recovery

| Failure | Immediate action | Recovery path |
| --- | --- | --- |
| RustDesk unavailable | Continue terminal work | SSH over Tailscale |
| Tailscale unavailable | Check local network and service state | Local access; optionally LAN SSH if deliberately configured |
| SSH unavailable | Use RustDesk to inspect `sshd`, Tailscale, and network state | Local physical access if GUI is also unavailable |
| Hyprland session unavailable or locked | Do not depend on RustDesk capture | SSH; local login or physical access |
| College network blocks a transport | Try the alternate remote path | Tailscale relay for SSH; RustDesk relay for GUI |
| Home internet outage or power loss | No remote service can recover the host | Physical access, power recovery, or separately managed out-of-band hardware |

Every change to remote services must be made while a local session is available and verified from a second terminal before closing the original session.

For Phase 1, recovery is ordered as follows:

1. Preserve the existing local session before changing SSH settings.
2. If Tailscale fails, recover it locally or use another intentionally configured SSH network path.
3. If SSH fails, use local physical access to validate and restore `sshd`.
4. Do not add RustDesk as a recovery dependency until Phase 2 is implemented and independently tested.

## Future Improvements

- EnderOS SSH instrument: readiness of agent, keys, and approved remote hosts.
- EnderOS Network instrument: tailnet state and remote-workstation reachability.
- Optional self-hosted RustDesk rendezvous/relay service on a separately managed VPS.
- Tailscale ACL tags for workstation, personal devices, and infrastructure roles.
- `mosh` for terminals that move between unreliable networks.
- Out-of-band power control only when its security and maintenance costs are justified.

## Constraints

- EnderOS Core must remain usable without RustDesk, self-hosted relays, Quickshell, AGS, Eww, or another custom shell framework.
- No hardcoded hostnames, IP addresses, user names, paths, Tailscale tailnet names, or RustDesk IDs belong in repository configuration.
- No manual port forwarding is part of the baseline design.
- Wayland graphical capture and control must be validated against the installed RustDesk version and Hyprland session; it must not be assumed to work at the display manager or lock screen.
- This document defines architecture only. It does not install packages, enable services, create credentials, change firewall rules, or alter existing EnderOS components.

## References

- [Tailscale SSH documentation](https://tailscale.com/docs/features/tailscale-ssh)
- [Tailscale Linux installation documentation](https://tailscale.com/docs/install/linux)
- [RustDesk Linux documentation](https://rustdesk.com/docs/en/manual/linux/)
- [RustDesk self-hosting documentation](https://rustdesk.com/docs/en/self-host/)
