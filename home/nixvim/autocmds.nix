{ lib, ... }:
{
  autoGroups = {
    alacritty_padding = { };
    snacks_picker_border = { };
  };

  autoCmd = [
    {
      event = [ "VimEnter" ];
      pattern = "*";
      desc = "Remove Alacritty padding on startup";
      command = "!alacritty msg config window.padding.x=0 window.padding.y=0";
    }
    {
      event = [ "VimEnter" ];
      pattern = "*";
      desc = "Clear border on snacks picker list";
      command = "highlight WinSeparator guibg=NONE guifg=NONE";
    }
    {
      event = [ "VimEnter" ];
      pattern = "*";
      desc = "Clear bg in number line";
      callback = {
        __raw = ''
          function()
            local groups = {'LineNrBelow', 'LineNr', 'LineNrAbove', 'FoldColumn', 'Folded'}
            for _, hl in ipairs(groups) do
              vim.api.nvim_set_hl(0, hl, { bg="", italic=true })
            end
          end
        '';
      };
    }
    {
      event = [ "VimEnter" ];
      desc = "Fix MiniDiff signs bg";
      callback = {
        __raw = ''
          function()
            for _, group in ipairs{"MiniDiffSignAdd", "MiniDiffSignChange", "MiniDiffSignDelete"} do local h = vim.api.nvim_get_hl(0, {name = group}) if h.fg then
                vim.api.nvim_set_hl(0, group, { fg = h.fg, italic=true, bg = "", ctermbg = "NONE" })
              end
            end
          end
        '';
      };
    }
    {
      event = [ "VimEnter" ];
      pattern = "*";
      desc = "Ensure no terminal windows are open on startup";
      callback = {
        __raw = ''
          function()
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.bo[buf].buftype == "terminal" then
                pcall(vim.api.nvim_win_close, win, true)
              end
            end
          end
        '';
      };
    }
    {
      event = [ "VimLeave" ];
      pattern = "*";
      desc = "Restore Alacritty padding on exit";
      command = "!alacritty msg config window.padding.x=10 window.padding.y=10";
    }
    # {
    #   event = [
    #     "VimEnter"
    #   ];
    #   pattern = "*";
    #   desc = "Change bg number line";
    #   callback = {
    #     __raw = ''
    #       function()
    #         local c = vim.api.nvim_get_hl(0, {name="LineNr"}).fg and "#"..("%06x"):format(c.fg) or "#cdd6f4"
    #         local r,g,b = tonumber(c:sub(2,3),16), tonumber(c:sub(4,5),16), tonumber(c:sub(6,7),16)
    #         for _,h in ipairs{"LineNrBelow","LineNrAbove"} do
    #           vim.api.nvim_set_hl(0, h, {fg=string.format("#%02x%02x%02x", r*0.4, g*0.4, b*0.4), bg="", italic=true})
    #         end
    #       end
    #     '';
    #   };
    # }
  ];
}
