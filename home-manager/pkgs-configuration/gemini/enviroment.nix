{ ... }: {
  home.sessionVariables =
    let config = (import ../../../config.nix) { key = "gemini"; };
    in {

      GEMINI_API_KEY = config.api;
      GEMINI_MODEL = "gemini-2.5-flash";
    };
}
