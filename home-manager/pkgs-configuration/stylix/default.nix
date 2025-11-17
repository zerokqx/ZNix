{pkgs,...}:{
  stylix ={
    enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
  targets = {
nvf.enable = false;
    };
  };

}
