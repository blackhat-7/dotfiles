---
name: oncall-summary
description: Write the end-of-shift training on-call summary for #google-cloud-training-alerts as a short Slack message. Use when the user asks for an on-call summary, handover, "what happened on my on-call", or a summary of training alerts for a date range.
---

# On-call summary (training alerts)

Output: one paste-ready Slack message in a code block. Short, but every customer issue, count and open item is in it.

## 1. Collect (window = what the user says, else since last Monday 10:00 IST)

- Read `#google-cloud-training-alerts` (`C078HT31HNH`) with `oldest=<epoch>`; page with the cursor until done. Big pages spill to a file: parse it with a script, not by eye.
- From each alert take job ID, profile ID, job type. Read the thread: Quinn's RCA plus any human reply. A human reply wins over Quinn.
- Check the current state of every profile in Cloud SQL: `profiles` (PK `key`: status, deleted, staged/trained images, user_id). Find its jobs with `bifrost_jobs.job_payload->>'cmd' LIKE '%<profile>%'`.
- Split internal from customer: internal user IDs in the `training-debug` skill, golden dataset user `adKZh0qetGeS7UaxDUfweGA1q0O2`, `joint_signals_*` jobs, learning profiles, `@aftershoot.com` / `@yopmail.com`.
- For Sentry alerts in the channel, check real impact in `bifrost_jobs` before calling something a fix.

## 2. Find the real reason for each issue

- Never write "unknown" or "unclear" until you have read the logs yourself: Loki `{job="editing-preprocesser"} | job_id=~".*<profile>.*"`, the last lines before `on_fail`, then the code at that line. Match against `~/Documents/Work/Editing/oncall/issues.md`.
- Check that any PR or fix you mention is still open (`gh pr view`). Don't trust the handbook's Open work list.
- A fix is "needed" only if it hurt a customer or will happen again. One-offs with no customer impact go under "Act only if it repeats".

## 3. Group and count

- Group by cause, not by profile. Same cause = one line with counts (users, profiles).
- User-side data problems (bad or corrupt catalog, missing previews, failed upload, missing metadata) = one line: "Bad upload or missing metadata (user side): N users, M profiles. Nothing to fix in the cloud."
- Cloud incidents go in Customer issues with "(cloud side)", not in a separate section.
- Every line ends with its state: "Retriggered, done", "Passed on retry", "Fixed by …", or what is still open.

## 4. Format (exact)

Slack bold is `*text*` (single asterisks). No italics, no tables, no profile IDs, no emails.

```
*Training alerts on-call: <D>–<D> <Mon>*
<One line: is any customer issue still open? Are permanent fixes needed? Anything pending.>

*Customer issues*
• <Cause> (<cloud side|user side>): <N profiles / users>. <What happened, in one short clause>. <State>.
• …

*Permanent fixes*            ← leave this section out if there are none
• <Fix>: <why it is needed, in one clause>.

*Act only if it repeats*
• <Errors from above that were one-offs>.
• <N one-off Bifrost/infra errors>: <short list>.

*Internal*
• Golden dataset: <N profiles>, <N still stuck>.
• R&D joint_signals jobs: <N alerts>.
• Learning profiles: <N>.
```

## 5. Writing rules

- One idea per bullet, one line each. Plain words: "Nomad gave the job no machine", not "allocation failure".
- Give counts everywhere. Say what you did not count rather than guessing.
- Show the draft to the user. Never post to Slack yourself.
- Example of a final post: https://aftershootco.slack.com/archives/C078HT31HNH/p1795416919605949
