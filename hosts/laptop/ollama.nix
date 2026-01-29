{ pkgs, ... }:
{
  services.nextjs-ollama-llm-ui = {
    enable = true;
    port = 3123;
  };

  services.ollama = {

    syncModels = true;
    enable = true;
    loadModels = [
      "qwen2.5-coder:3b"
      "granite4:3b"
      "deepseek-coder:6.7b"
    ];
  };
}
