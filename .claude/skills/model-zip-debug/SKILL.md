---
name: model-zip-debug
description: Debug Aftershoot trained model zip/artifact problems. Use this whenever the user mentions `models.as.zip`, `legacy.models.as.zip`, `models.enc.zip`, model zip, trained models, missing/unexpected sliders, presets, `info.json`/`info.jumbled`, `.jumbled`, ONNX output mismatch, checksum/path issues, model download/apply issues, or asks why a trained profile zip does not contain the expected sliders/models.
---

# Model Zip Debug

Goal: prove what was trained, what was packaged, what the app/backend received, and where they diverge.

Keep answers short. Do not RCA from one artifact alone.

## Output shape

Use:
- `IDs:` profile/user/folder/app version/job id if known
- `Last training:` `bifrost_jobs` time, state, provider, image URL
- `Artifacts:` exact GCS paths checked
- `Zip:` key contents and checksum/path result
- `Mismatch:` first proven divergence
- `Next:` 1-3 exact checks or fix targets

## First checks

1. Resolve profile/folder/user:

```sql
SELECT p.key, p.user_id, p.user_email, p.status, p.trained_images,
       p.current_folder, p.trained_folder, p.beta_profile,
       f.key AS folder_id, f.status AS folder_status, f.number_of_images,
       f.app_version, f.model_path_v2, f.model_checksum,
       f.training_completed_on, f.models_version
FROM profiles p
LEFT JOIN folders f ON f.key = COALESCE(NULLIF(p.trained_folder, ''), p.current_folder)
WHERE p.key = '<profile_id>'
LIMIT 1;
```

`model_path_v2` and `model_checksum` live on `folders`, not `profiles`.

2. Check last training in `bifrost_jobs` for when it ran and which image was used:

```sql
SELECT id, provider_job_id, external_job_id, provider, job_state,
       failure_reason, created_at, completed_at, image_url,
       job_payload->>'display_name' AS display_name,
       job_payload->'tracking_args'->>'profile_id' AS profile_id,
       job_payload->'tracking_args'->>'folder_id' AS folder_id
FROM bifrost_jobs
WHERE job_payload->>'job_type' = 'training'
  AND job_payload->'tracking_args'->>'profile_id' = '<profile_id>'
ORDER BY created_at DESC
LIMIT 10;
```

If user gives a provider/run id, match both:

```sql
SELECT provider_job_id, external_job_id, image_url,
       job_payload->'tracking_args'->>'profile_id' AS profile_id
FROM bifrost_jobs
WHERE provider_job_id = '<id>' OR external_job_id = '<id>'
ORDER BY created_at DESC
LIMIT 5;
```

Do not use `job_payload->>'profile_id'`; it is nested under `tracking_args`.
Do not paste raw `job_payload`.

3. User logs, when app-side download/apply behavior matters:

```text
gs://aftershoot-user-logs/<firebase_user_uid>/<unix_timestamp_seconds>/<file_name>
```

Usually list the user prefix around the reported time and inspect `logs.zip`.

## Artifact locations

Prod bucket is usually `gs://editing_userdata`; stage is `gs://editing-userdata-stage`.

Check both `trained_folder` and `current_folder` when retrains or same-folder work are possible:

```text
gs://editing_userdata/<user_id>/<profile_id>/<folder_id>/training_data/out/sliders_exif.csv
gs://editing_userdata/<user_id>/<profile_id>/<folder_id>/training_data/out/process_details.json
gs://editing_userdata/<user_id>/<profile_id>/<folder_id>/trained_models/<timestamp>/models.as.zip
gs://editing_userdata/<user_id>/<profile_id>/<folder_id>/trained_models/<timestamp>/legacy.models.as.zip
gs://editing_userdata/<user_id>/<profile_id>/<folder_id>/trained_models/<timestamp>/artifacts.zip
```

Do not trust only the DB path if multiple timestamps exist; list `trained_models/` and compare timestamps/checksums.

## Zip inspection checklist

Work in `/tmp` or another scratch dir.

- `models.as.zip` is flat and contains `*.jumbled`; `info.json` is usually `info.jumbled`.
- Decrypt with v2 password = `user_id` (`el_ofuscado` or `decrypt_v2` from `Scripts/UniversalProfilesUpdate`).
- Inspect zip names exactly: `models.as.zip`, `legacy.models.as.zip`, `bulk_models.as.zip`.
- Compare DB `folders.model_checksum` to `models.as.zip`; legacy checksum may be GCS object metadata `model_checksum`.
- Verify object exists, generation/timestamp, and public/readability if the app fetches it directly.

Useful local references:
- `Scripts/UniversalProfilesUpdate/AGENTS.md`
- `Scripts/UniversalProfilesUpdate/universalprofilesupdate/api/jobs/model_integrity_check.py`
- `Scripts/UniversalProfilesUpdate/universalprofilesupdate/api/jobs/output_count_mismatch.py`
- `editing-trainer*/editing_trainer/model_packer/info_builder.py`
- `editing-trainer*/editing_trainer/model_packer/packager.py`

## Prove the mismatch

Cross-check these four sources:

1. `sliders_exif.csv` — source slider values.
2. `process_details.json` — train vs preset vs absent contract. Older files may use `enc_name`, not `model_name`.
3. decrypted `info.json` — what app/backend believes is in the zip.
4. decrypted ONNX — actual model inputs/outputs, output count, file names.

Common patterns:
- Non-zero values in `sliders_exif.csv` do not prove a model should exist; `process_details.json` may choose preset.
- HSL/Color Mixer lives under `info.json["color_space"]`, not a top-level slider group.
- Partial retrains must preserve unrequested nested sections; check if `color_space`/WB/etc. was clobbered.
- Backend/app contract can differ by app version. Legacy WB may expect names like `crackthis1.jumbled`; v4 may use `crackthis1_v4.jumbled` and `white_balance.version = "v4"`.
- If `info.json` declares N outputs but ONNX has M, the zip is internally inconsistent.

## Logs

Use logs to explain the row/artifact evidence, not replace it.

- Trainer service: usually `editing-trainer-refactored`.
- Metrics: often `training-metrics-job`.
- For completion/download/path issues, check profile-manager request/response logs too.
- Scope logs by exact `bifrost_jobs` time window, `profile_id`, `external_job_id`, or `provider_job_id`.
