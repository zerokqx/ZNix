{ pkgs, lib, ... }:
{
  services.nextjs-ollama-llm-ui.enable = true;
  services.ollama = {
    package = pkgs.ollama-vulkan;
    enable = true;
    loadModels = [
      "wizardlm-uncensored"
      "granite4:3b"
      "qwen2.5-coder:7b"
    ];
  };
}
