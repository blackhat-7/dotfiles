# sudo-approve

When an AI agent runs `sudo`, you approve the exact command: with Touch ID in a box on your Mac,
or with Approve and Deny on your phone (ntfy). No password is typed, so an agent never sees or
fakes a password prompt. When you run `sudo` yourself, you just type your password. It lives in
sudo's PAM, so it works the same from any terminal, ssh session or agent harness, on the PC
(Linux) and the Mac.

An agent is a sudo with no terminal (Claude Code, pi and opencode run commands that way, and
nobody could type a password there anyway), or one whose environment has `AI_AGENT` or
`GEMINI_CLI` (agents that run commands in a terminal, like Gemini CLI). An agent that hides
these gets a password prompt it can't answer.

## Who asks you

The Mac first, for sudo on either machine. `sudo-approve-mac`, a root launchd service, shows the
box "sudo is trying to run …" with the command, the machine and the processes that asked:

- You used the Mac in the last 2 minutes: only the box. No touch in 10 s: the phone too.
- The Mac is open but idle: the box and the phone at once.
- The Mac is locked, asleep, off or at the login window: only the phone.
- A command longer than 300 characters skips the box; the phone shows up to 1500.
- One box at a time: a second request meanwhile goes to the phone, so a new box can't take the
  place of the one you're reading.

The first answer counts, and the box closes when the phone answers. For an agent, Deny, Cancel
or no answer ends sudo with a one-line reason and no password try, so it never counts toward a
faillock lockout. If the helper is missing or broken, everyone gets the normal password prompt,
so it cannot lock you out.

## Server

Private ntfy at `https://ntfy.imrtl.dev` (server-stack `ntfy/`), `auth-default-access: deny-all`.

| ntfy user | access | used by |
|---|---|---|
| `phone` | read `sudo` | the ntfy iPhone app |
| `sudo-host` | write `sudo`, read-write `sudo-mac`, read `sudo-reply` | the helper and `sudo-approve-mac` (token) |
| `sudo-approver` | write `sudo-reply` | `sudo-approve-mac` and the phone's buttons (token inside each push) |

Each request carries a random one-time code; only an answer with that code counts.
`sudo-approve-mac` denies a code it sees twice, since a second request with it is forged. After
an Approve on the phone, a silent ✅ push follows. The ntfy iPhone app can't replace or delete a
push (only Android and web can), so there is no result push for Deny or no answer.

Tokens and codes never go in a program's arguments: any user can read those with `ps`, but not
a root process's environment. They reach curl and jq through the environment or a pipe.

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
small PAM module in `/etc/pam.d/sudo_local`, runs the helper. `touchid-prompt.m` is the box,
built as `sudo` because the box names the program asking. `just run` installs everything but
the config:

```sh
sudo install -o root -g wheel -m 0600 ~/sudo-approve.conf /etc/sudo-approve.conf && rm ~/sudo-approve.conf
```

On macOS, Deny or no answer falls through to the password prompt, which fails at once without
a terminal (macOS has no faillock lockout by default). The service logs to
`/var/log/sudo-approve-mac.log`.

## Limits

- Approving `sudo bash script.sh` approves whatever the script holds when it runs; the same goes
  for any program the agent can change after you approve.
- Anyone who controls the ntfy server can approve. An agent that can `ssh hetzner` (unprotected
  key, `docker` group there) can do that; accepted for now (2026-11-21).
