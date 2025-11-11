
{
  plugins.yazi.enable = true;

  keymaps = [
    {
      mode = "n";
      key = "<leader>E";
      action = "<cmd>Yazi<cr>";
      options = {
        desc = "Yazi toggle";
        silent = true;
      };
    }
  ];
}
