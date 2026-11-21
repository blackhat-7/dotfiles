# sudo-approve

`sudo` pushes the exact command to your phone (ntfy) with Approve and Deny. Approve runs it with
no password typed, so an agent never sees or fakes a password prompt. Deny, no answer in 60 s,
or any error falls back to the normal password prompt, so a broken helper cannot lock you out.
Works the same from any terminal, ssh session or agent harness, because it lives in sudo's PAM.

## Server

Private ntfy at `https://ntfy.imrtl.dev` (server-stack `ntfy/`), `auth-default-access: deny-all`.

| ntfy user | access | used by |
|---|---|---|
| `phone` | read `sudo` | the ntfy iPhone app |
| `sudo-host` | write `sudo`, read `sudo-reply` | this helper (token) |
| `sudo-approver` | write `sudo-reply` | the Approve/Deny buttons (token inside each push) |

Each request carries a random one-time code; only a reply with that code counts.

## Install (per machine)

```sh
sudo ./install ~/.config/sudo-approve.conf   # first time: NTFY_URL=, HOST_TOKEN=, APPROVER_TOKEN=
sudo ./install                               # later: update the helper
sudo ./install --uninstall
```

Keep a root shell open the first time. Also sets `timestamp_timeout=0`: every sudo asks.

## Limits

- Approving `sudo bash script.sh` approves whatever the script holds when it runs.
- Anyone who controls the ntfy server can approve. An agent that can `ssh hetzner` (unprotected
  key, `docker` group there) can do that; accepted for now (2026-11-21).
