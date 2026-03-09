---
name: aftershoot-docs
description: >
  Search and answer questions about Aftershoot's internal documentation, codebase architecture, and AI editing pipeline.
  Use this skill whenever the user asks about anything related to Aftershoot's editing pipeline, services, jobs, repos,
  infrastructure, or internal tooling — including (but not limited to) editing-preprocesser, editing-trainer, editing-ml,
  bifrost, aftershoot-cloud, EditingDebugHelper, or any component of the AI training system.
  Trigger even if the user just mentions a service name, asks how something works, asks where to find something,
  asks about a job or cron, mentions training, preprocessing, model conversion, profiles, sliders, ONNX, or anything
  that sounds like it's part of the Aftershoot backend or ML infrastructure.
---

# Aftershoot Docs Search

When the user asks about Aftershoot internals, your job is to find the right documentation and answer their question from it. Don't guess — read the actual files.

## Repository Map

All repos live under `~/Documents/Work/Editing/`. Here's where documentation exists:

### Primary Docs Site
- **`asdocs/`** — Docusaurus-based internal docs site. The canonical reference.
  - `docs/editing/` — Full editing pipeline docs (image ingestion → preprocessing → training → metrics → monitoring → manual ops, architecture overview, end-to-end flow, glossary)
  - `docs/cloud/` — Cloud/backend docs (bifrost, dev setup, go modules, go workspaces, monorepo, OTLP)
  - `docs/build_pipeline/` — Build pipeline docs (backend, cloud, frontend, OTA, etc.)
  - `docs/backend/` — Backend dev setup, build system, integration tests
  - `docs/app/` — App dev setup
  - `docs/website/` — Website docs
  - `docs/infra-overview.md` — Infrastructure overview
  - `docs/ota-manager-docs.md` — OTA manager

### Editing Pipeline Repos

- **`Editing-Preprocesser/`** — Python service that handles image ingestion and data preprocessing before training.
  - `README.md`
  - `docs/` — architecture-overview, end-to-end-flow, glossary, index, preprocessing, image-ingestion (01), data-preprocessing (02), model-training (03), metrics-evaluation (04), monitoring-debugging (05), manual-operations (06)

- **`editing-trainer/`** — Python service that runs the actual AI model training.
  - `README.md`
  - `docs/` — architecture-overview, end-to-end-flow, glossary, index, model-training (03), monitoring-debugging (05), manual-operations (06)

- **`editing-ml/`** — ML utilities and analysis projects.
  - `README.md`
  - `libs/editlib/README.md` + `libs/editlib/docs/`
  - `projects/data-inconsistency-report/README.md`
  - `projects/editing-metrics-server/README.md`
  - `projects/raw-similarity-metrics/README.md`
  - `projects/trainer-testset/README.md`

- **`editing-consistency-metrics/`** — Metrics service for editing consistency.
  - `README.md`

### aftershoot-cloud (Monorepo)

Root: `aftershoot-cloud/`
- `README.md` — Monorepo overview
- `docs/` — dev.md, setup.md, monorepo.md, go-workspaces.md, deployment-setup.png

**Apps with README and/or docs:**
| App | README | docs/ folder |
|-----|--------|--------------|
| `apps/bifrost/` | ✓ | ✓ |
| `apps/blake/` | ✓ | ✓ |
| `apps/feedback/` | ✓ | — |
| `apps/functions/` | ✓ | — |
| `apps/inference-orchestration/` | ✓ | — |
| `apps/kratos/` | ✓ | ✓ |
| `apps/marketplace/` | ✓ | — |
| `apps/mseo/` | ✓ | — |
| `apps/payments/` | ✓ | ✓ |
| `apps/profile-manager/` | ✓ | ✓ |
| `apps/referral/` | ✓ | ✓ |
| `apps/retouching/` | ✓ | — |
| `apps/tracker/` | ✓ | — |
| `apps/workflow-integration/` | — | ✓ |

**Jobs with README:**
| Job | README |
|-----|--------|
| `jobs/edits-style-remover-job/` | ✓ |
| `jobs/edits-style-sampler-job/` | ✓ |
| `jobs/trial-end-reminder-job/` | ✓ |

**Libs with README:**
| Lib | README |
|-----|--------|
| `libs/core/` | ✓ |
| `libs/infra/` | ✓ |
| `libs/middlewares/` | ✓ |
| `libs/pubsub/` | ✓ |
| `libs/sqlite_extensions/` | ✓ |

### Other Repos

- **`infra/`** — Infrastructure config. `README.md`
- **`Editing-Scripts/`** — Utility scripts. `README.md`
- **`EditingDebugHelper/`** — Collection of debug/utility tools. `README.md` at root, plus READMEs in:
  - `autocreate-pipeline/`, `biller/`, `dump_lr_edits/`, `firestore-cli/`, `info_converter/`, `model_converter/`, `model_sharing/`, `profile_performance_metrics/`, `profile_transfer/`, `recreate_lrdata/`, `train_trigger/`, `transfer_and_model_convert/`

## How to Answer Questions

1. **Start with `asdocs/docs/`** for conceptual or pipeline-level questions — it's the most organized and up-to-date reference. For editing pipeline questions, `docs/editing/` is the first place to look.

2. **Go to the specific repo** for implementation details, setup instructions, or questions scoped to a particular service. E.g. for "how do I run the preprocessor locally", read `Editing-Preprocesser/README.md`.

3. **Use the Grep tool** to search across files when you're not sure where something is documented, e.g. searching for a specific config key, function name, or concept.

4. **Be specific about sources** — tell the user which file you read so they can go look at it themselves if they want more detail.

5. **Don't read every file** for a broad question — skim headings and introductions first, then drill in. Use the Read tool with a limit if you just need a high-level summary.

## Key Pipeline Concepts (quick orientation)

- **Editing pipeline**: User photos → `Editing-Preprocesser` (image ingestion, data prep) → `editing-trainer` (ML model training) → model deployed via `editing-ml` → served by `bifrost` (inference)
- **Bifrost**: Go service in `aftershoot-cloud/apps/bifrost/` — handles inference/prediction requests
- **Blake**: Service in `aftershoot-cloud/apps/blake/` — check its README for its role
- **Profile**: An Aftershoot editing profile (per-user trained model)
- **Sliders**: Lightroom/editing adjustment parameters that the model predicts
- **ONNX**: Model format used for deployment (converting from TF/PyTorch → ONNX)
- **Training scheduler**: `jobs/serverless-training-scheduler-job/` — triggers training jobs
- **Edits style sampler/remover**: Jobs that handle style extraction from user edits
