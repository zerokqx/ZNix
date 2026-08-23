{ pkgs, ... }:
{

  home.packages = with pkgs; [ delta ];
  programs.git = {
    enable = true;
    settings = {
      core = {
        pager = "delta";
      };
      interactive = {
        diffFilter = "delta --color-only";
      };
      delta = {
        navigate = true;
      };
      merge = {
        conflictStyle = "zdiff3";

      };
      user = {
        name = "zerokqx";
        email = "swiftkey382@gmail.com";
      };
      init.defaultBranch = "main";
    };
  };
}
