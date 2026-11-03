---
name: oncall
description: Aftershoot training/editing on-call. Use at the start of any on-call work (alerts in #google-cloud-training-alerts, ONCL tickets in #customer-support, stuck/failed profiles, retriggers, "why did this profile fail", missing models, image counts) or any question about training/profile issues even when not on-call, and whenever a session learns something worth remembering.
---

# On-call

The handbook lives in `~/Documents/Work/Editing/oncall/`. Start with `README.md`; it says which file to read for which problem. Read only the files you need.

## During on-call

- Check `issues.md` for the symptom before digging. Most problems repeat.
- Follow `howto.md` (Retrigger) before any retrigger, and the retrigger skill in `EditingDebugHelper/train_trigger`.
- Never post to Slack without the user's OK for that exact message.

## Keep the handbook current

Update it when you learn something a future on-call would need, without being asked:

- A new failure pattern or root cause, or a faster way to confirm one → `issues.md`.
- A new or corrected command, arg rule or trap → `howto.md`.
- A system fact (table, topic, endpoint, version rule) → `system.md`.
- A permanent fix shipped or a new gap found → `README.md` (Open work).
- A user correction about how to work → `README.md` rules.

Rules for edits:

- General lessons only. No single-customer stories, emails or secrets. A profile ID only when it is the example.
- Edit the existing bullet instead of appending a near-duplicate. Delete what turned out wrong or is fixed.
- One fact per bullet, one line, short and exact (table, flag, file path). No explanations or stories.
- Keep these 5 files; don't create new ones. Keep `issues.md` and `howto.md` under ~170 lines, others under ~80. When over, move the least-used bullets to `archive.md` (never delete info that is still true).
- `archive.md` is reference only: don't load it by default; grep it when the main files have no answer.
- Only add what a future on-call can't find quickly in the code or by one query.
- Tell the user in one line what you changed.
