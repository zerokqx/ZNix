{
  performance.byteCompileLua.enable = true;

  # Disable legacy runtime plugins that are not used by this setup.
  globals = {
    loaded_gzip = 1;
    loaded_zip = 1;
    loaded_zipPlugin = 1;
    loaded_tar = 1;
    loaded_tarPlugin = 1;
    loaded_getscript = 1;
    loaded_getscriptPlugin = 1;
    loaded_vimball = 1;
    loaded_vimballPlugin = 1;
    loaded_netrw = 1;
    loaded_netrwPlugin = 1;
    loaded_netrwSettings = 1;
    loaded_netrwFileHandlers = 1;
    loaded_rrhelper = 1;
    "loaded_2html_plugin" = 1;
  };
}
