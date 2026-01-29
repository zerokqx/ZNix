{

  programs.opencode = {
    enable = true;
    settings = {
      provider = {
        ollama = {
          npm = "@ai-sdk/openai-compatible";
          name = "Ollama";
          options = {
            baseURL = "http://localhost:11434/v1";
          };
          models = {
            "qwen2.5-coder:7b" = {
              name = "Qwen 2.5 Coder 7B"
            }
          };
        };
      };
    };
  };
}
