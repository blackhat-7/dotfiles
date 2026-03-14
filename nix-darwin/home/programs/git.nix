{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user.name = "blackhat-7";
      user.email = "palshaunak7@gmail.com";
      core.hooksPath = "~/.githooks";
      push.autoSetupRemote = true;
      rerere.enabled = true;
    };
  };

  home.file.".githooks/pre-commit" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      exec gitleaks protect --staged --verbose --config "$HOME/.config/gitleaks/config.toml"
    '';
  };

  home.file.".config/gitleaks/config.toml" = {
    text = ''
      [extend]
      useDefault = true

      [[rules]]
      description = "Chutes API Key"
      id = "chutes-api-key"
      regex = 'cpk_[0-9a-f]{32}\.[0-9a-f]{32}\.[0-9a-zA-Z]{32}'
      tags = ["api", "chutes"]

      [[rules]]
      description = "DeepSeek API Key"
      id = "deepseek-api-key"
      regex = 'sk-[a-f0-9]{32}'
      tags = ["api", "deepseek"]

      [[rules]]
      description = "GLHF API Key"
      id = "glhf-api-key"
      regex = 'glhf_[a-f0-9]{32}=?'
      tags = ["api", "glhf"]

      [[rules]]
      description = "Groq API Key"
      id = "groq-api-key"
      regex = 'gsk_[a-zA-Z0-9]{52}'
      tags = ["api", "groq"]

      [[rules]]
      description = "Jina AI API Key"
      id = "jina-api-key"
      regex = 'jina_[a-zA-Z0-9]{60}'
      tags = ["api", "jina"]

      [[rules]]
      description = "NanoGPT API Key"
      id = "nanogpt-api-key"
      regex = 'sk-nano-[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'
      tags = ["api", "nanogpt"]

      [[rules]]
      description = "OpenRouter API Key"
      id = "openrouter-api-key"
      regex = 'sk-or-v1-[a-f0-9]{64}'
      tags = ["api", "openrouter"]

      [[rules]]
      description = "Tavily API Key"
      id = "tavily-api-key"
      regex = 'tvly-[a-z]+-[A-Za-z0-9]{32}'
      tags = ["api", "tavily"]

      [[rules]]
      description = "RunPod API Key"
      id = "runpod-api-key"
      regex = 'rpa_[A-Za-z0-9]{44,}'
      tags = ["api", "runpod"]
    '';
  };
}
