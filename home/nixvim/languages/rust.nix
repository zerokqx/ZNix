{pkgs,...}:{
  plugins.rustaceanvim = {
    enable = true;

    settings = {
      server = {
        default_settings = {
          "rust-analyzer" = {
            cargo = {
              allFeatures = true;
            };
            checkOnSave = true;
            check = {
              command = "clippy";
            };
          };
        };
      };
    };
  };

  extraPackages = with pkgs; [
    rust-analyzer
    rustfmt
    clippy
  ];
}
