{
  programs.niri.settings = {
    workspaces = {
      "09-chat" = { };
    };

    window-rules = [
      {
        matches = [
          {
            app-id = "Throne";
          }
        ];
        open-focused = false;
        open-on-workspace = "09-chat";
      }
    ];
  };
}
