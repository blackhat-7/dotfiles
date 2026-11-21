# sudo-approve

When an AI agent runs `sudo`, your phone (ntfy) gets the exact command with Approve and Deny.
Approve runs it with no password typed, so an agent never sees or fakes a password prompt. When
you run `sudo` yourself, you just type your password; no push. It lives in sudo's PAM, so it
works the same from any terminal, ssh session or agent harness, on Linux and macOS.

An agent is a sudo with no terminal (Claude Code, pi and opencode run commands that way, and
nobody could type a password there anyway), or one whose environment has `AI_AGENT` or
`GEMINI_CLI` (agents that run commands in a terminal, like Gemini CLI). An agent that hides
these gets a password prompt it can't answer.

For an agent, Deny or no answer in 60 s ends sudo with a one-line reason and no password try,
so it never counts toward a faillock lockout. If the helper is missing or broken, everyone gets
the normal password prompt, so it cannot lock you out.

## Server

Private ntfy at `https://ntfy.imrtl.dev` (server-stack `ntfy/`), `auth-default-access: deny-all`.

| ntfy user | access | used by |
|---|---|---|
| `phone` | read `sudo` | the ntfy iPhone app |
| `sudo-host` | write `sudo`, read `sudo-reply` | this helper (token) |
| `sudo-approver` | write `sudo-reply` | the Approve/Deny buttons (token inside each push) |

Each request carries a random one-time code; only a reply with that code counts. After Approve,
a silent ✅ push follows. The ntfy iPhone app can't replace or delete a push (only Android and
web can), so there is no result push for Deny or no answer.

## Install

The helper is `/etc/sudo-approve`: Nix-managed, root-owned, read-only, with a fixed PATH. Both
need `/etc/sudo-approve.conf` (root, 0600) with `NTFY_URL=`, `HOST_TOKEN=`, `APPROVER_TOKEN=`.
Keep a root shell open the first time. Both set `timestamp_timeout=0`: every sudo asks.

Linux (`nix/linux/default.nix`): `/etc/pam.d/sudo` stays Arch's own file; `./install` adds two
lines to it, plus the config and the sudoers rule.

```sh
just linux                                     # from ~/dotfiles/nix: installs /etc/sudo-approve
sudo ./install ~/.config/sudo-approve.conf     # first time; moves the config into /etc
sudo ./install                                 # later, if the PAM lines or sudoers rule change
sudo ./install --uninstall
```

macOS (`nix-darwin/darwin/default.nix`): macOS has no `pam_exec`, so `pam_sudo_approve.c`, a
small PAM module in `/etc/pam.d/sudo_local`, runs the helper. `just run` installs everything
but the config:

```sh
sudo install -o root -g wheel -m 0600 ~/sudo-approve.conf /etc/sudo-approve.conf && rm ~/sudo-approve.conf
```

On macOS, Deny or no answer falls through to the password prompt, which fails at once without
a terminal (macOS has no faillock lockout by default).

## Limits

- Approving `sudo bash script.sh` approves whatever the script holds when it runs.
- Anyone who controls the ntfy server can approve. An agent that can `ssh hetzner` (unprotected
  key, `docker` group there) can do that; accepted for now (2026-11-21).
