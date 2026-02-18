{
  pkgs,
  lib,
  config,
  ...
}:
{
  services.nextjs-ollama-llm-ui.enable = config.services.ollama.enable;
  services.ollama = {
    package = pkgs.ollama-vulkan;
    enable = false;
    loadModels = [
      "wizardlm-uncensored"
      "granite4:3b"
      "qwen2.5-coder:7b"
    ];
  };
}
