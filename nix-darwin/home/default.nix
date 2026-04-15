{ pkgs, lib, ... }:
{
  imports = [
    ./programs
  ];
  home.stateVersion = "23.11";
  home.packages = [
    pkgs.fastfetch
    pkgs.exiftool
    pkgs.python313
    pkgs.python313Packages.pip
    pkgs.opentofu
    (pkgs.google-cloud-sdk.withExtraComponents [pkgs.google-cloud-sdk.components.kubectl pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin])
    pkgs.golangci-lint
    pkgs.nightlight
    pkgs.nodejs_24
    pkgs.spotify
    pkgs.slack
    pkgs.discord
    pkgs.raycast
    pkgs.google-cloud-sql-proxy
    pkgs.dbeaver-bin
    pkgs.gopls
    pkgs.rustup
    pkgs.mongodb-compass
    pkgs.brave
    pkgs.ffmpeg_6-headless
    pkgs.exempi
    pkgs.sqlc
    pkgs.github-copilot-cli
    pkgs.p7zip
    pkgs.vi-mongo
    pkgs.tabiew
    pkgs.just
    pkgs.lazysql
    pkgs.packer
    pkgs.webtorrent_desktop
    pkgs.moonlight-qt
    pkgs.gitleaks
    pkgs.monitorcontrol
  ];

  launchd.agents.turn-on-night-shift = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.nightlight}/bin/nightlight"
        "on"
      ];
      RunAtLoad = true;
    };
  };

  home.activation.writeMutableAiConfigs =
    let
      claudeConfig = ''
        {
          "mcpServers": {
            "ai-tools": {
              "command": "ai-tools-mcp",
              "args": []
            }
          }
        }
      '';

      opencodePackageJson = ''
        {
          "private": true,
          "type": "module",
          "dependencies": {
            "@opencode-ai/plugin": "latest"
          }
        }
      '';

      opencodeRedditTool = ''
        import { tool } from "@opencode-ai/plugin"

        async function run(args: Record<string, unknown>) {
          const process = Bun.spawn(["ai-tools-cli", "reddit", JSON.stringify(args)], {
            stdout: "pipe",
            stderr: "pipe",
          })

          const [stdout, stderr, exitCode] = await Promise.all([
            new Response(process.stdout).text(),
            new Response(process.stderr).text(),
            process.exited,
          ])

          if (exitCode !== 0) {
            throw new Error(stderr.trim() || "ai-tools-cli failed for reddit")
          }

          return stdout.trim()
        }

        export default tool({
          description: "Read Reddit.",
          args: {
            op: tool.schema.enum(["search", "posts", "subreddit", "post", "user"]),
            query: tool.schema.string().optional(),
            subreddit: tool.schema.string().optional(),
            sort: tool.schema
              .enum(["relevance", "hot", "top", "new", "comments", "rising", "controversial"])
              .optional(),
            time: tool.schema.enum(["hour", "day", "week", "month", "year", "all"]).optional(),
            limit: tool.schema.number().int().min(1).max(100).optional(),
            post_id: tool.schema.string().optional(),
            comments: tool.schema.number().int().min(1).max(100).optional(),
            username: tool.schema.string().optional(),
            posts: tool.schema.number().int().min(1).max(100).optional(),
          },
          async execute(args) {
            return run(args)
          },
        })
      '';
    in
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "$HOME/.config/opencode/tools"

      rm -f "$HOME/.claude.json"
      cat <<'EOF' > "$HOME/.claude.json"
      ${claudeConfig}
      EOF

      rm -f "$HOME/.config/opencode/package.json"
      cat <<'EOF' > "$HOME/.config/opencode/package.json"
      ${opencodePackageJson}
      EOF

      rm -f "$HOME/.config/opencode/tools/reddit.ts"
      cat <<'EOF' > "$HOME/.config/opencode/tools/reddit.ts"
      ${opencodeRedditTool}
      EOF
    '';
}
