{ lib, config, ... }:
{
  plugins.obsidian = {
    enable = true;
    settings = {

      completion = {
        min_chars = 2;
        blink_cmp = true;
      };
      notes_subdir = "notes";
      daily_notes = {
        folder = "notes/dailies";
        date_format = "%Y-%m-%d";
        alias_format = "%B %-d, %Y";
        default_tags = [ "daily-notes" ];
      };
      new_notes_location = "notes_subdir";
      mappings = { };
      templates = {
        folder = "templates";
      };
      workspaces = [
        {
          name = "work";
          path = "~/obsidian/work";
        }
        {
          name = "lessons";
          path = "~/obsidian/lessons";
        }
      ];
      node_id_func = lib.nixvim.mkRaw ''
        function(title)
            -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
            -- In this case a note with the title 'My new note' will be given an ID that looks
            -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
            local suffix = ""
            if title ~= nil then
              -- If title is given, transform it into valid file name.
              suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
            else
              -- If title is nil, just add 4 random uppercase letters to the suffix.
              for _ = 1, 4 do
                suffix = suffix .. string.char(math.random(65, 90))
              end
            end
            return tostring(os.time()) .. "-" .. suffix
          end
      '';
    };
  };
  keymaps = lib.mkIf config.plugins.obsidian.enable [
    {
      mode = "n";
      key = "<leader>on"; # Obsidian New
      action = "<cmd>Obsidian new<cr>";
      options = {
        silent = true;
        desc = "Obsidian: New note";
      };
    }
    {
      mode = "n";
      key = "<leader>oN"; # Obsidian New from Template
      action = "<cmd>Obsidian new_from_template<cr>";
      options = {
        silent = true;
        desc = "Obsidian: New from template";
      };
    }

    # Jump / find
    {
      mode = "n";
      key = "<leader>oo"; # Obsidian Open (quick switch)
      action = "<cmd>Obsidian quick_switch<cr>";
      options = {
        silent = true;
        desc = "Obsidian: Quick switch";
      };
    }
    {
      mode = "n";
      key = "<leader>os"; # Obsidian Search
      action = "<cmd>Obsidian search<cr>";
      options = {
        silent = true;
        desc = "Obsidian: Search";
      };
    }

    # Navigation in graph
    {
      mode = "n";
      key = "<leader>of"; # Obsidian Follow link
      action = "<cmd>Obsidian follow_link<cr>";
      options = {
        silent = true;
        desc = "Obsidian: Follow link";
      };
    }
    {
      mode = "n";
      key = "<leader>ob"; # Obsidian Backlinks
      action = "<cmd>Obsidian backlinks<cr>";
      options = {
        silent = true;
        desc = "Obsidian: Backlinks";
      };
    }
    {
      mode = "n";
      key = "<leader>ol"; # Obsidian Links (in note)
      action = "<cmd>Obsidian links<cr>";
      options = {
        silent = true;
        desc = "Obsidian: Links in note";
      };
    }
    {
      mode = "n";
      key = "<leader>ot"; # Obsidian TOC
      action = "<cmd>Obsidian toc<cr>";
      options = {
        silent = true;
        desc = "Obsidian: Table of contents";
      };
    }

    # Meta
    {
      mode = "n";
      key = "<leader>oT"; # Obsidian Tags
      action = "<cmd>Obsidian tags<cr>";
      options = {
        silent = true;
        desc = "Obsidian: Tags";
      };
    }

    # Workspaces
    {
      mode = "n";
      key = "<leader>ow"; # Obsidian Workspace
      action = "<cmd>Obsidian workspace<cr>";
      options = {
        silent = true;
        desc = "Obsidian: Switch workspace";
      };
    }

    # Daily notes (мнемоника: y=Yesterday, d=Daily(today), m=toMorrow)
    {
      mode = "n";
      key = "<leader>oy"; # Obsidian Yesterday
      action = "<cmd>Obsidian yesterday<cr>";
      options = {
        silent = true;
        desc = "Obsidian: Yesterday";
      };
    }
    {
      mode = "n";
      key = "<leader>od"; # Obsidian Daily (today)
      action = "<cmd>Obsidian today<cr>";
      options = {
        silent = true;
        desc = "Obsidian: Today";
      };
    }
    {
      mode = "n";
      key = "<leader>om"; # Obsidian toMorrow
      action = "<cmd>Obsidian tomorrow<cr>";
      options = {
        silent = true;
        desc = "Obsidian: Tomorrow";
      };
    }

    {
      mode = "n";
      key = "<leader>oT"; # Obsidian toMorrow
      action = "<cmd>ObsidianToggleCheckbox<cr>";
      options = {
        silent = true;
        desc = "Obsidian: Toggle checkbox";
      };
    }
  ];
}
