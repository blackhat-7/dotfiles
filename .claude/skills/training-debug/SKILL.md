---
name: training-debug
description: Debug Aftershoot training and preprocessing failures. Use whenever the user mentions failure stats, recent training failures, a time window of failures, `editing-preprocesser`, `editing-trainer-refactored`, `editing-trainer-reactored`, `profile_id`, `folder_id`, `job_id`, `chkpts.zip`, `lost_job`, `requested_state_stuck`, `scheduled_state_stuck`, `No catalog found`, `Image dir not found`, or asks what logs, SQL tables, or repo files to check for a broken training run.
---

# Training Debug

Scope:
- `editing-preprocesser`
- `editing-trainer-refactored`

Do not start with other services. For aggregate failure stats, start with `bifrost_jobs`. For root cause, start with `editing-preprocesser` and `editing-trainer-refactored`. Only expand beyond `bifrost` if the evidence points there.

If the user asks for "all failures", stay within the training/preprocess pipeline unless they explicitly ask for every service.

## Output Shape

Answer in this order:
- `Scope:` exact unit counted (`bifrost_jobs`, `profiles`, logs) and whether stats are external-only
- `Stats:` counts by source and top failure patterns for the requested window
- `Cause:` exact failed-job cause if proven; otherwise say `not proven yet`
- `Internal anomalies:` excluded internal rows that are still worth calling out
- `Hunch:` 1-3 likely causes, explicitly marked as hunches
- `Next checks:` exact logs, SQL rows, and repo files to inspect next

Default to the last 24 hours if the user does not specify a time window.

## Ignore Internal Profiles

Ignore internal Aftershoot jobs unless the user explicitly asks for them.

Internal user ids:
- `kuWNJmqZa3gPO8dhnAElIQpmbqB2`
- `6qGM63ZK7nboNlfDNr0Wvg6sKCW2`
- `JYtB9LvE9IMBYg7Zg2RpFMhu3fY2`
- `4dWuJcxkWUeUM4xHiBWbJBITyXj2`
- `u8M9wFO10sbcmEsiOvq7mij8ObP2`
- `yO22z2le3TeK19of97His5tgnEm2`
- `FXASuLnhGUV5T8tK7PnRMpP0iG33`
- `S25p6qAYA8dl4tqIRTDHAKGaiv03`
- `e7mKZtmzA5bLsUSxhTStLN6Eyay2`

Internal regex:

```text
job_(kuWNJmqZa3gPO8dhnAElIQpmbqB2|6qGM63ZK7nboNlfDNr0Wvg6sKCW2|JYtB9LvE9IMBYg7Zg2RpFMhu3fY2|4dWuJcxkWUeUM4xHiBWbJBITyXj2|u8M9wFO10sbcmEsiOvq7mij8ObP2|yO22z2le3TeK19of97His5tgnEm2|FXASuLnhGUV5T8tK7PnRMpP0iG33|S25p6qAYA8dl4tqIRTDHAKGaiv03|e7mKZtmzA5bLsUSxhTStLN6Eyay2)_
```

Filtering rules:
- `bifrost_jobs`: do not rely on `display_name` alone for internal filtering; prefer `profile_id -> profiles.user_id` when available, and use the regex only as a fallback
- `bifrost_serverless_jobs`: exclude rows where `user_id` is one of the ids above
- `profiles`: exclude rows where `user_id` is one of the ids above
- logs: ignore hits whose job id or display name contains one of those ids
- If a supposed external row resolves to an internal `profiles.user_id`, treat it as internal even if `display_name` differs by case or typo.
- If excluded internal rows show up in the same window, mention them separately under `Internal anomalies` instead of mixing them into customer-facing stats.

## Stats First

For aggregate stats:
- Use SQL first. Logs are for explanation, not the source of truth for counts.
- Keep units separate: `bifrost_jobs` failures, `profiles` currently `failed`, and logs are different things.
- Use rolling windows from `NOW()` or the system date. Do not hardcode calendar dates.
- Loki queries must stay within `189h`. Do not use midnight-to-23:59 7-day ranges.
- In `Stats:`, report terminal failure states and proved failure classes. Do not list repeated non-fatal log lines as failure reasons.

## Attribution Rules

- For "why did this fail?", work job-first, not profile-first.
- Start from the exact failed `bifrost_jobs` row and keep `external_job_id`, `created_at`, `completed_at`, `provider`, and `profile_id`.
- If a profile has multiple jobs in the window, treat them as separate runs. Do not merge them.
- Use `bifrost_job_events` first, then logs scoped to that job window. Prefer `external_job_id`, `job_id`, or `correlation_id` over raw `profile_id` searches.
- Treat profile-level training logs as pattern-finding only. They are not enough to prove causality for one failed job.
- `ERROR` does not mean fatal. Only call something the cause if you have a terminal traceback, explicit failure reason, or matching terminal state transition.
- Common non-fatal logs are not causes. Do not report a repeated warning/error line as the failure reason unless the code path or traceback shows it terminates the run.
- If a log line is common but non-fatal, omit it from `Stats:` and mention it only as background noise if needed.
- Do not use final `profiles.status` or `retry_count` to explain why one specific job failed unless the evidence directly supports it.
- If you only see incidental warnings or mixed signals, say `not proven yet` instead of guessing.

## First Pass

For recent failures, query only:
- `editing-preprocesser` `ERROR`
- `editing-trainer-refactored` `ERROR`

If signal is weak, expand to `WARN`.

Current real patterns:
- preprocess: `No catalog found ... Integrity check failed`, `Image dir not found ... /DNGs`, `Some Catalogs don't have lrcat or dngs/tiffs/jpgs`
- trainer-refactored: `chkpts.zip does not exist at the specified GCS bucket path` is common noise unless a traceback proves otherwise
- one real trainer traceback involved `ToneCurvePV2012` in `editing_trainer/processing.py`
- recent external `bifrost_jobs` also showed `lost_job`, `requested_state_stuck`, and `scheduled_state_stuck`

Default hunches:
- preprocess integrity errors: upload/catalog/DNG problem before training
- `lost_job` / `*_state_stuck`: infra scheduling or watcher issue before app code

## Safe SQL

Never `SELECT job_payload` raw from `bifrost_jobs`. It contains secrets.
Never call `describe_table` on `bifrost_jobs`; sample rows can expose secrets.
Never paste raw tool output containing keys, tokens, or payload blobs.

For stats, always filter `bifrost_jobs` with `job_payload->>'job_type' = 'training'` unless the user explicitly asks for broader Bifrost job stats.

When `profile_id` is present, prefer joining through `profiles` to exclude internal rows instead of trusting `display_name`.

Recent external-only training job failures:

```sql
SELECT provider, job_state, COALESCE(failure_reason, 'null') AS failure_reason, COUNT(*) AS count
FROM bifrost_jobs
LEFT JOIN profiles p
  ON p.key = bifrost_jobs.job_payload->'tracking_args'->>'profile_id'
WHERE created_at >= '<start>'::timestamptz
  AND job_payload->>'job_type' = 'training'
  AND COALESCE(p.user_id, '') NOT IN ('kuWNJmqZa3gPO8dhnAElIQpmbqB2','6qGM63ZK7nboNlfDNr0Wvg6sKCW2','JYtB9LvE9IMBYg7Zg2RpFMhu3fY2','4dWuJcxkWUeUM4xHiBWbJBITyXj2','u8M9wFO10sbcmEsiOvq7mij8ObP2','yO22z2le3TeK19of97His5tgnEm2','FXASuLnhGUV5T8tK7PnRMpP0iG33','S25p6qAYA8dl4tqIRTDHAKGaiv03','e7mKZtmzA5bLsUSxhTStLN6Eyay2')
  AND COALESCE(job_payload->>'display_name', '') !~ 'job_(kuWNJmqZa3gPO8dhnAElIQpmbqB2|6qGM63ZK7nboNlfDNr0Wvg6sKCW2|JYtB9LvE9IMBYg7Zg2RpFMhu3fY2|4dWuJcxkWUeUM4xHiBWbJBITyXj2|u8M9wFO10sbcmEsiOvq7mij8ObP2|yO22z2le3TeK19of97His5tgnEm2|FXASuLnhGUV5T8tK7PnRMpP0iG33|S25p6qAYA8dl4tqIRTDHAKGaiv03|e7mKZtmzA5bLsUSxhTStLN6Eyay2)_'
GROUP BY provider, job_state, COALESCE(failure_reason, 'null')
ORDER BY count DESC
LIMIT 20;
```

Exact failed jobs to attribute:

```sql
SELECT id,
       external_job_id,
       provider,
       job_state,
       failure_reason,
       created_at,
       completed_at,
       job_payload->>'display_name' AS display_name,
       job_payload->'tracking_args'->>'profile_id' AS profile_id,
       p.user_id,
       p.user_email
FROM bifrost_jobs
LEFT JOIN profiles p
  ON p.key = bifrost_jobs.job_payload->'tracking_args'->>'profile_id'
WHERE created_at >= '<start>'::timestamptz
  AND job_state = 'failed'
  AND job_payload->>'job_type' = 'training'
  AND COALESCE(p.user_id, '') NOT IN ('kuWNJmqZa3gPO8dhnAElIQpmbqB2','6qGM63ZK7nboNlfDNr0Wvg6sKCW2','JYtB9LvE9IMBYg7Zg2RpFMhu3fY2','4dWuJcxkWUeUM4xHiBWbJBITyXj2','u8M9wFO10sbcmEsiOvq7mij8ObP2','yO22z2le3TeK19of97His5tgnEm2','FXASuLnhGUV5T8tK7PnRMpP0iG33','S25p6qAYA8dl4tqIRTDHAKGaiv03','e7mKZtmzA5bLsUSxhTStLN6Eyay2')
  AND COALESCE(job_payload->>'display_name', '') !~ 'job_(kuWNJmqZa3gPO8dhnAElIQpmbqB2|6qGM63ZK7nboNlfDNr0Wvg6sKCW2|JYtB9LvE9IMBYg7Zg2RpFMhu3fY2|4dWuJcxkWUeUM4xHiBWbJBITyXj2|u8M9wFO10sbcmEsiOvq7mij8ObP2|yO22z2le3TeK19of97His5tgnEm2|FXASuLnhGUV5T8tK7PnRMpP0iG33|S25p6qAYA8dl4tqIRTDHAKGaiv03|e7mKZtmzA5bLsUSxhTStLN6Eyay2)_'
ORDER BY created_at DESC
LIMIT 100;
```

Resolve ids first:

```sql
SELECT key, user_id, user_email, status, trained_images, current_folder, trained_folder, beta_profile
FROM profiles
WHERE key = '<profile_id>'
LIMIT 1;

SELECT key, profile_key, status, number_of_images, app_version, training_completed_on
FROM folders
WHERE key = '<folder_id>'
LIMIT 1;

SELECT folder_key, queue
FROM training_queue
WHERE folder_key = '<folder_id>'
LIMIT 10;
```

Safe job inspection:

```sql
SELECT id,
       external_job_id,
       provider,
       job_state,
       failure_reason,
       retry_count,
       max_retries,
       created_at,
       updated_at,
       completed_at,
       job_payload->>'display_name' AS display_name,
       job_payload->'tracking_args'->>'profile_id' AS profile_id,
       job_payload->>'job_type' AS job_type
FROM bifrost_jobs
WHERE job_payload->>'job_type' = 'training'
  AND job_payload->'tracking_args'->>'profile_id' = '<profile_id>'
  AND COALESCE(job_payload->>'display_name', '') !~ 'job_(kuWNJmqZa3gPO8dhnAElIQpmbqB2|6qGM63ZK7nboNlfDNr0Wvg6sKCW2|JYtB9LvE9IMBYg7Zg2RpFMhu3fY2|4dWuJcxkWUeUM4xHiBWbJBITyXj2|u8M9wFO10sbcmEsiOvq7mij8ObP2|yO22z2le3TeK19of97His5tgnEm2|FXASuLnhGUV5T8tK7PnRMpP0iG33|S25p6qAYA8dl4tqIRTDHAKGaiv03|e7mKZtmzA5bLsUSxhTStLN6Eyay2)_'
ORDER BY created_at DESC
LIMIT 20;
```

If you have `external_job_id`:

```sql
SELECT job_id, external_job_id, event_type, previous_state, new_state, event_timestamp, triggered_by, correlation_id
FROM bifrost_job_events
WHERE external_job_id = '<external_job_id>'
ORDER BY event_timestamp ASC
LIMIT 50;
```

Then search logs only around that failed job's time window. Do not attribute cause from unrelated profile-level errors outside that run.

If training got far enough to write metrics:

```sql
SELECT folder_key,
       profile_key,
       timestamp,
       training_queue,
       metrics_images,
       trained_images,
       psnr,
       ssim,
       delta_e,
       hist_bhattacharyya,
       infra_provider
FROM training_quality_metrics
WHERE profile_key = '<profile_id>' OR folder_key = '<folder_id>'
ORDER BY timestamp DESC
LIMIT 10;
```

## Debug Path

### Preprocess-looking failure

Bias toward input integrity first.

Check:
- folder status, image count, app version
- training queue row
- preprocess logs around the failure time
- whether the error is one of the known catalog/DNG integrity patterns

Read:
- `~/Documents/Work/Editing/Editing-Preprocesser/editing/api/get_data/run.py`
- `~/Documents/Work/Editing/Editing-Preprocesser/editing/api/preprocess.py`
- `~/Documents/Work/Editing/Editing-Preprocesser/editing/api/triggers.py`
- `~/Documents/Work/Editing/Editing-Preprocesser/README.md`

### Trainer-refactored-looking failure

Bias toward:
- missing checkpoints
- bad processed artifacts / slider shape mismatch
- infra never got the job fully running

Read:
- `~/Documents/Work/Editing/editing-trainer/main.py`
- `~/Documents/Work/Editing/editing-trainer/editing_trainer/checkpoints/utils.py`
- `~/Documents/Work/Editing/editing-trainer/editing_trainer/processing.py`
- `~/Documents/Work/Editing/editing-trainer/editing_trainer/model_packer/info_builder.py`
- `~/Documents/Work/Editing/editing-trainer/docs/05-monitoring-debugging.md`

### Infra-looking failure

Use `bifrost_jobs` and `bifrost_job_events` before app code.

Strong hunches:
- `requested_state_stuck`: scheduler/provider handoff issue
- `scheduled_state_stuck`: provider resource or watcher issue
- `lost_job`: provider job vanished or watcher could not reconcile it

Read:
- `~/Documents/Work/Editing/aftershoot-cloud-2/apps/bifrost/internal/scheduled/job_watcher.go`
- `~/Documents/Work/Editing/aftershoot-cloud-2/apps/bifrost/README.md`

## Local Breadcrumbs

Only use these if the user asks whether we have seen something similar before:
- `~/.claude/history.jsonl`
- `~/.claude/projects/-Users-illusion-Documents-Work-Editing-editing-trainer-*/**/*.jsonl`
- `~/.local/share/opencode/tool-output/`
