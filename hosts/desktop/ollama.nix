{ pkgs, ... }:
{
  services.nextjs-ollama-llm-ui.enable = true;
  services.ollama = {
    syncModels = true;
    enable = true;
    loadModels = [
      "granite4:3b"
      "qwen2.5-coder:7b"
    ];
  };
}
