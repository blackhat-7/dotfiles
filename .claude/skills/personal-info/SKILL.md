---
name: personal-info
description: Personal developer profile, tech stack, projects, tools, and preferences for Shaunak Pal (blackhat-7). Use this skill when the user asks about themselves, their projects, what they work on, their tech stack, tools, preferences, setup, work, hobbies, or anything personal/biographical. Also trigger when the user says "I", "my", "me" in the context of their own projects, skills, or background.
---

# Developer Profile: Shaunak Pal

**Handle:** blackhat-7 | **Email:** palshaunak7@gmail.com | **Domain:** immortal.cx
**Machine:** macOS (Apple Silicon) primary, Linux (x86_64, NVIDIA GPU) secondary
**System management:** Nix (nix-darwin + home-manager on mac, home-manager + system-manager on linux)

---

## Work

**Company:** Aftershoot (aftershoot.com) — AI-powered photo editing for photographers
**Role:** Works on the AI editing pipeline — preprocessing, training, inference, backend services, infra, internal tooling
**Org:** github.com/aftershootco
**Tracker:** Linear (PLAT-xxxx ticket IDs)

### Active Work Repos (~/Documents/Work/Editing/)

| Repo | Lang | What it does | Activity |
|---|---|---|---|
| **editing-trainer** (x3 worktrees) | Python (TF 2.15, PyTorch 2.6, ONNX) | Core ML training pipeline — trains personalized editing models | Daily |
| **Editing-Preprocesser** | Python (uv, OpenCV, sklearn, SQLAlchemy) | Data preprocessing — image validation, slider extraction, feature engineering | Daily |
| **aftershoot-cloud** (x2 worktrees) | Go 1.25 + TS (Nx monorepo) | Main backend — 21 Go services, 13 jobs, 17 libs. Key: bifrost (GPU orchestration), kratos (admin), profile-manager | Daily |
| **EditingDebugHelper** | Go, Python, Rust | 35+ debug/utility tools — model converter, train trigger, profile transfer, LR/C1 editors | Daily |
| **editing-ml** | Python (uv, monorepo) | ML research — shared editlib, metrics server, data quality, test datasets | Weekly |
| **editing-consistency-metrics** | Python (DINOv3, ONNX, MongoDB) | Quality metrics — editing consistency via image embeddings | Weekly |
| **Editing-Scripts** | Python (conda, TF, Flask, RunPod) | Legacy training pipeline (being superseded by editing-trainer) | Monthly |
| **infra** | OpenTofu/Terragrunt, Docker Compose | IaC — Grafana/Loki/Alloy monitoring, Headscale VPN, Cloud Run | Monthly |
| **asdocs** | TypeScript (Docusaurus) | Internal eng docs at docs.aftershoot.dev | Biweekly |
| **kratos-ui** | React, Vite, Tailwind v4, Radix, TanStack, Zustand | Internal admin dashboard | Stale (Dec 2025) |

### Editing Pipeline Architecture

```
Desktop App -> Profile Manager (Go) -> PubSub -> Cloud Workflow
-> Vertex AI -> Preprocesser (Python) -> PubSub
-> Bifrost (Go, GPU orchestrator) -> Trainer (Python/TF/PyTorch)
-> ONNX export -> GCS -> Desktop App
```

### Work Infra

- **Cloud:** GCP (GCS, PubSub, Vertex AI, Cloud Run, Cloud Build, Secret Manager, Artifact Registry)
- **CI/CD:** Google Cloud Build (Python services), GitHub Actions (cloud monorepo)
- **Monitoring:** Grafana + Loki + Alloy, OpenTelemetry, Sentry, MLflow
- **Databases:** PostgreSQL (Cloud SQL), MongoDB, Firestore
- **GPU:** RunPod (legacy), SkyPilot (current)
- **IaC:** OpenTofu + Terragrunt
- **MCP Servers:** cloudsql-reader, mongo-reader, stage-mongo-reader, grafana-loki-reader, sentry-reader (all Go binaries from aftershoot-cloud)

---

## Personal Projects (~/Documents/projects/)

### Active (2026)

| Project | Lang | Description |
|---|---|---|
| **server-stack** | Docker Compose | Self-hosted homelab — Caddy, Headscale VPN, SearxNG, Langfuse, Minecraft server, MinIO. Domain: immortal.cx |
| **our-streamer** | Python (TUI) | Finds live sports matches, plays best stream in mpv, auto-switches on failure. Published installer. |
| **benchmark_llms** | Python (uv) | Benchmark framework for LLM coding assistants using OpenCode |
| **llm-functions** | Bash/Python/JS | LLM function-calling toolkit for aichat — tools (coder, SQL, JSON viewer, todo) and agents |
| **aqwer** | Go | macOS-compatible project (recently active) |
| **docent** | Rust + Python | Living documentation engine — AST parsing, call graphs, LLM-powered code summarization |
| **TL** | Go (Templ, HTMX) | Minimalist translator — web + CLI, image OCR support |

### Older / Experimental

| Project | Lang | Description |
|---|---|---|
| **query-builder** | Go (Bubble Tea) | AI-powered query builder TUI |
| **ai** | Rust | AI tools collection — OpenWebUI management, RAG systems |
| **sql2diagram** | Go | Generate DB diagrams from SQL migrations using D2 |
| **musicer** | Go | Discord music bot (YouTube via yt-dlp + FFmpeg) |
| **papertrader** | Python | Paper trading system |
| **trender** | Go | Trend analysis tool |
| **deeper** | Go | Expression evaluation tool |
| **code-rag** | Rust | Code RAG system |
| **crawler-rs** | Rust | Web crawler |
| **inception** | Python | Google API integration project |
| **PyReddit** | Python | Reddit API client |
| **Tars** | Python | Discord bot |
| **slack-dissociate** | Rust | Slack tool |
| **oncall-helper** | Rust | On-call management tool |
| **llm-rs** | Rust | LLM toolkit in Rust |
| **easy_email** | Rust | Email utility |
| **price_tracker** | Go | Price tracking tool |

---

## Tech Stack

### Primary Languages (ranked by usage)

1. **Go** — backend services, CLIs, tooling (gopls, golangci-lint, sqlc)
2. **Python** — ML/data pipelines, scripting (uv, basedpyright, TF, PyTorch, ONNX)
3. **Rust** — personal projects, systems tools (rust-analyzer, cargo)

### Secondary

- TypeScript/JavaScript (React frontends, Nx monorepos, Node.js)
- Lua (Neovim config)
- Bash (scripts, fish functions)
- C/C++ (clangd, vcpkg, cmake — less active)
- C# (omnisharp — less active)
- SQL (sqlc, dadbod, lazysql)
- Nix (system/env management)
- HCL (OpenTofu/Terraform)

### ML Stack

TensorFlow 2.15, PyTorch 2.6, ONNX, scikit-learn, OpenCV, DINOv3, MLflow, Vertex AI

---

## Dev Environment

### Editor: Neovim (primary)

- Plugin manager: lazy.nvim
- Colorscheme: Gruvbox
- Leader: Space
- Key plugins: Telescope, nvim-tree, Copilot, Sidekick.nvim (Claude), nvim-cmp, treesitter, go.nvim, Neogit, diffview, obsidian.nvim, trouble.nvim, FTerm, noice.nvim
- LSPs: gopls, basedpyright, rust-analyzer, clangd, omnisharp, luau_lsp, bash-language-server
- Also has VSCode and Zed installed

### Terminal & Shell

- **Terminal:** Kitty (Monokai Pro theme, MesloLGLDZ Nerd Font)
- **Shell:** Fish (vi keybindings, starship prompt)
- **Multiplexer:** tmux (gruvbox-material theme, vim-tmux-navigator)
- **Session workflow:** Automated tmux sessions via script — Home, Main (all work repos), DebugHelper, Scripts, Hobby, Remote/Services

### CLI Tools

| Tool | Purpose |
|---|---|
| lsd | ls replacement |
| bat | cat replacement |
| ripgrep | fast grep |
| fd | fast find |
| fzf | fuzzy finder |
| jq | JSON processor |
| yazi | terminal file manager |
| zoxide | smart cd |
| atuin | shell history sync |
| btop | resource monitor |
| television | TUI fuzzy finder |
| direnv + nix-direnv | per-project envs |
| carapace | completion bridging |

### AI Tooling (heavily AI-augmented workflow)

| Tool | Setup |
|---|---|
| **Claude Code** | Primary AI assistant, MCP servers for DB/logs/errors |
| **OpenCode** | Secondary, same MCP servers, local LLM support |
| **Copilot** | In-editor (nvim), auto-trigger, M-Tab accept |
| **Sidekick.nvim** | Claude CLI inside neovim |
| **aichat** | CLI chat with LLMs, integrated into fish (Ctrl+X) |
| **Aider** | Code assistant (Qwen2.5-Coder-32B via OpenWebUI) |
| **Ollama** | Local model serving (0.0.0.0) |
| **gcm function** | AI-generated commit messages via aichat |

### Window Management

- **macOS:** AeroSpace (tiling WM) — Cmd+1-9 workspaces, Cmd+Shift+H/J/K/L move
- **Linux:** Hyprland (Wayland) — dual 1440p monitors (360Hz + 144Hz), NVIDIA, Sunshine for remote gaming

### Other

- **Notes:** Obsidian (vault: ~/Documents/Notes, Zettelkasten style, also via obsidian.nvim)
- **Launcher:** Raycast (macOS)
- **Browser:** Zen (primary), Brave, Chromium
- **DB tools:** DBeaver, MongoDB Compass, vi-mongo, lazysql, tabiew, Cloud SQL Proxy (prod:5434, stage:5436)
- **Git:** gitleaks pre-commit hook (custom rules for API keys), rerere enabled, auto-setup remote
- **Gaming:** Moonlight client (mac) + Sunshine server (linux) for remote gaming, Minecraft server on homelab

---

## Preferences & Patterns

- **Declarative everything:** Nix for system config, direnv+flake for per-project envs, `initflake` alias to scaffold new projects
- **Worktree-heavy:** Uses git worktrees for parallel development (3x editing-trainer, 2x aftershoot-cloud)
- **AI-first commits:** `gcm` function auto-generates conventional commit messages from diffs
- **Vi keybindings everywhere:** Fish, Neovim, tmux, Nushell
- **Keyboard-driven:** Tiling WM, no dock, Raycast launcher, terminal-centric workflow
- **Self-hosted:** Runs own Headscale VPN, SearxNG search, Langfuse, MinIO on immortal.cx
- **Dual-platform Nix:** Single `just switch` manages both macOS and Linux from same repo
- **Secret management:** API keys in ~/Documents/Work/Creds/, gitleaks enforced pre-commit
- **CapsLock -> Control** on both platforms
- **Fast key repeat** (KeyRepeat=2)
