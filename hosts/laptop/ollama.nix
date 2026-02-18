{ pkgs, config, ... }:
{
  services.nextjs-ollama-llm-ui = {
    enable = config.services.ollama.enable;
    port = 3123;
  };

  services.ollama = {

    syncModels = true;
    enable = false;
    loadModels = [
      "qwen2.5-coder:3b"
      "granite4:3b"
      "deepseek-coder:6.7b"
    ];
  };
}
