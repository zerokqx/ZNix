{
  ...
}:

{
  programs.zed-editor = {
    enable = false;

    mutableUserSettings = false;
    mutableUserKeymaps = false;
    mutableUserTasks = false;
    mutableUserDebug = false;

    extensions = [
      "html"
      "dockerfile"
      "sql"
      "vue"
      "tokyo-night-themes"
      "emmet"
      "nix"
      "prisma"
      "colored-zed-icons-theme"
      "vscode-great-icons-theme"
      "react-typescript-snippets"
      "nginx"
      "modern-icons-theme"
      "nestjs-snippets"
    ];

    userSettings = {
      autosave = "on_focus_change";
      cursor_blink = true;
      auto_update = false;

      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      use_system_path_prompts = false;
      use_system_prompts = false;
      disable_ai = false;

      git = {
        inline_blame = {
          show_commit_summary = false;
        };
      };

      zoomed_padding = true;
      use_system_window_tabs = false;

      preview_tabs = {
        enable_preview_from_file_finder = false;
        enabled = true;
      };

      tabs = {
        file_icons = true;
        git_status = false;
      };

      tab_bar = {
        show_nav_history_buttons = false;
        show = true;
      };

      title_bar = {
        show_sign_in = true;
        show_user_picture = true;
        show_onboarding_banner = true;
        show_project_items = true;
        show_branch_name = true;
        show_branch_icon = true;
      };

      search = {
        button = true;
      };

      diagnostics = {
        inline = {
          enabled = true;
        };
        button = true;
      };

      terminal = {
        button = false;
      };

      status_bar = {
        cursor_position_button = false;
        active_language_button = true;
      };

      icon_theme = "Colored Zed Icons Theme Dark";

      agent = {
        button = true;

        default_model = {
          provider = "zed.dev";
          model = "claude-sonnet-4-6";
        };

        inline_assistant_model = {
          provider = "google";
          model = "gemini-2.5-flash-lite-preview";
        };

        model_parameters = [ ];
      };

      base_keymap = "VSCode";
      vim_mode = true;

      theme = "Base16 Tokyo Night Dark";

      project_panel = {
        sort_mode = "directories_first";
        hide_hidden = false;
        hide_root = true;
        auto_fold_dirs = true;
        sticky_scroll = true;
        auto_reveal_entries = true;
        git_status = true;
        folder_icons = true;
        file_icons = true;
        entry_spacing = "standard";
        hide_gitignore = false;
        button = false;
        default_width = 320;

        scrollbar = {
          horizontal_scroll = true;
        };
      };

      languages = {
        TypeScript = {
          language_servers = [
            "vtsls"
            "!typescript-language-server"
            "..."
          ];
        };

        TSX = {
          language_servers = [
            "vtsls"
            "!typescript-language-server"
            "..."
          ];
        };

        JavaScript = {
          language_servers = [
            "vtsls"
            "!typescript-language-server"
            "..."
          ];
        };
      };

      file_scan_exclusions = [
        "**/.git"
        "**/.svn"
        "**/.hg"
        "**/.jj"
        "**/CVS"
        "**/.DS_Store"
        "**/Thumbs.db"
        "**/.classpath"
        "**/.settings"
        "**/node_modules"
      ];
    };

    userKeymaps = [
      {
        context = "Editor && VimControl && !VimWaiting && !menu";
        bindings = {
          "q" = null;
          "ctrl-/" = "terminal_panel::Toggle";
          "g ]" = "editor::GoToDiagnostic";
          "g [" = "editor::GoToPreviousDiagnostic";
          "g r" = "editor::FindAllReferences";
          "g c c" = "editor::ToggleComments";
          "shift-k" = "editor::Hover";
          "z shift-r" = "editor::UnfoldRecursive";
          "z shift-m" = "editor::FoldRecursive";
          "z shift-k" = "editor::Hover";
          "space c a" = "editor::ToggleCodeActions";
          "space c r" = "editor::Rename";
          "space c f" = "editor::Format";
          "space c d" = "diagnostics::DeployCurrentFile";
          "space c n" = "command_palette::Toggle";
          "space l a" = "editor::ToggleCodeActions";
          "space l r" = "editor::Rename";
          "space l f" = "editor::Format";
          "space l l" = "diagnostics::Deploy";
          "space /" = "project_search::ToggleFocus";
          "space ," = "tab_switcher::Toggle";
          "space space" = "file_finder::Toggle";
          "space f" = "file_finder::Toggle";
          "space o" = "tab_switcher::Toggle";
          "space e" = "project_panel::ToggleFocus";
          "space p" = "outline::Toggle";
          "space v" = "editor::GoToDefinitionSplit";
          "space m" = "markdown::OpenPreview";
          "space n" = "command_palette::Toggle";
          "space u shift-c" = "theme_selector::Toggle";
          "space u s" = "project_symbols::Toggle";
          "space u a" = "zed::OpenKeymap";
          "space x x" = "diagnostics::Deploy";
          "space x shift-x" = "diagnostics::DeployCurrentFile";
          "space x l" = "diagnostics::Deploy";
          "space x d" = "editor::GoToDefinition";
          "space x r" = "editor::FindAllReferences";
          "space x t" = "editor::GoToTypeDefinition";
          "space x i" = "editor::GoToImplementation";
          "space x shift-d" = "editor::GoToDeclaration";
          "space g z" = "git_panel::ToggleFocus";
          "space g b" = "git::Branch";
          "space g d" = "git::BranchDiff";
          "space g s" = "git::ViewStash";
          "space g l" = "git_panel::ToggleFocus";
          "space g g" = "project_search::ToggleFocus";
          "space w h" = "workspace::ActivatePaneLeft";
          "space w j" = "workspace::ActivatePaneDown";
          "space w k" = "workspace::ActivatePaneUp";
          "space w l" = "workspace::ActivatePaneRight";
          "space w v" = "pane::SplitRight";
          "space w s" = "pane::SplitDown";
          "space w r" = "workspace::MoveFocusedPanelToNextPosition";
          "space w =" = "workspace::ResetOpenDocksSize";
          "space w d" = "pane::CloseActiveItem";
          "space w o" = "pane::JoinAll";
          "space w q" = "pane::CloseActiveItem";
          "space w a" = "workspace::SaveAll";
          "space q q" = "zed::Quit";
          "[ b" = "pane::ActivatePreviousItem";
          "] b" = "pane::ActivateNextItem";
          "shift-h" = "pane::ActivatePreviousItem";
          "shift-l" = "pane::ActivateNextItem";
          "space b d" = "pane::CloseActiveItem";
          "space b l" = "pane::CloseItemsToTheLeft";
          "space b o" = "pane::CloseOtherItems";
          "space b shift-o" = "pane::CloseAllItems";
          "space b p" = "pane::TogglePinTab";
          "space b shift-p" = "pane::CloseCleanItems";
          "space d c" = "debugger::Continue";
          "space d shift-o" = "debugger::StepOver";
          "space d i" = "debugger::StepInto";
          "space d o" = "debugger::StepOut";
          "space d p" = "debugger::Pause";
          "space d b" = "debugger::ToggleEnableBreakpoint";
          "space d shift-b" = "debugger::ToggleDataBreakpoint";
          "space d shift-r" = "debugger::Restart";
          "space d r" = "debugger::Rerun";
          "space d t" = "debugger::Stop";
          "space d u" = "debug_panel::ToggleFocus";
          "space d e" = "debugger::EvaluateSelectedText";
          "space t n" = "task::Rerun";
          "space t t" = "task::Spawn";
          "space t s" = "zed::OpenTasks";
          "space t o" = "terminal_panel::Toggle";
          "space t shift-o" = "terminal_panel::ToggleFocus";
          "space t shift-s" = "debugger::Stop";
          "ctrl-h" = "workspace::ActivatePaneLeft";
          "ctrl-j" = "workspace::ActivatePaneDown";
          "ctrl-k" = "workspace::ActivatePaneUp";
          "ctrl-l" = "workspace::ActivatePaneRight";
          "alt-h" = "vim::ResizePaneLeft";
          "alt-j" = "vim::ResizePaneDown";
          "alt-k" = "vim::ResizePaneUp";
          "alt-l" = "vim::ResizePaneRight";
          "space k k" = "editor::Hover";
          "space s" = "vim::PushSneak";
          "g s r" = "vim::PushChangeSurrounds";
          "g s d" = "vim::PushDeleteSurrounds";
          "g s a" = "vim::PushAddSurrounds";
        };
      }

      {
        context = "Editor && vim_mode == insert && !menu";
        bindings = {
          "j j" = "vim::NormalBefore";
          "ctrl-s" = "workspace::Save";
          "ctrl-/" = "terminal_panel::Toggle";
        };
      }

      {
        context = "Editor && !menu";
        bindings = {
          "ctrl-s" = "workspace::Save";
        };
      }

      {
        context = "Editor && vim_mode == visual && !VimWaiting && !VimObject";
        bindings = {
          "shift-j" = "editor::MoveLineDown";
          "shift-k" = "editor::MoveLineUp";
        };
      }

      {
        context = "Terminal";
        bindings = {
          "ctrl-/" = "terminal_panel::Toggle";
          "shift-h" = "pane::ActivatePreviousItem";
          "shift-l" = "pane::ActivateNextItem";
          "ctrl-shift-space" = "terminal::ToggleViMode";
        };
      }

      {
        context = "Dock";
        bindings = {
          "ctrl-h" = "workspace::ActivatePaneLeft";
          "ctrl-j" = "workspace::ActivatePaneDown";
          "ctrl-k" = "workspace::ActivatePaneUp";
          "ctrl-l" = "workspace::ActivatePaneRight";
          "alt-h" = "workspace::DecreaseActiveDockSize";
          "alt-j" = "workspace::DecreaseActiveDockSize";
          "alt-k" = "workspace::IncreaseActiveDockSize";
          "alt-l" = "workspace::IncreaseActiveDockSize";
        };
      }

      {
        context = "ProjectPanel";
        bindings = {
          "alt-h" = "workspace::DecreaseActiveDockSize";
          "alt-j" = "workspace::DecreaseActiveDockSize";
          "alt-k" = "workspace::IncreaseActiveDockSize";
          "alt-l" = "workspace::IncreaseActiveDockSize";
        };
      }

      {
        context = "Terminal && vim_mode == insert";
        bindings = {
          "space" = [
            "terminal::SendText"
            " "
          ];
          "escape escape" = "terminal::ToggleViMode";
        };
      }

      {
        context = "menu";
        bindings = {
          "escape" = "menu::Cancel";
        };
      }

      {
        context = "Editor && showing_code_actions";
        bindings = {
          "j" = "editor::ContextMenuNext";
          "k" = "editor::ContextMenuPrevious";
          "enter" = "editor::ConfirmCodeAction";
          "l" = "editor::ConfirmCodeAction";
          "escape" = "menu::Cancel";
        };
      }

      {
        context = "Editor";
        bindings = {
          "space q q" = "zed::Quit";
          "space /" = "project_search::ToggleFocus";
        };
      }

      {
        context = "BufferSearchBar";
        bindings = { };
      }

      {
        context = "BufferSearchBar && !in_replace > Editor";
        bindings = { };
      }

      {
        context = "ProjectPanel && not_editing";
        bindings = {
          "a" = "project_panel::NewFile";
          "shift-a" = "project_panel::NewDirectory";
          "r" = "project_panel::Rename";
          "d" = [
            "project_panel::Trash"
            {
              skip_prompt = false;
            }
          ];
          "m" = "project_panel::Cut";
          "p" = "project_panel::Paste";
          "l" = "project_panel::Open";
        };
      }

      {
        context = "Terminal && vim_mode == normal";
        bindings = {
          "i" = "terminal::ToggleViMode";
          "a" = "terminal::ToggleViMode";
        };
      }
    ];
  };
}
