{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib) mkIf;
  cfg = config.baseline.nixvim.git;
in {
  options = {
    baseline.nixvim.git = {
      enable = mkEnableOption "Enable baseline git configuiration";
    };
  };

  config = mkIf cfg.enable {
    programs.nixvim = {
      extraPlugins = [
        pkgs.vimPlugins.nvim-web-devicons
        {
          plugin = pkgs.vimPlugins.git-conflict-nvim;
          config = ''
            :lua require('git-conflict').setup()
          '';
        }
      ];

      plugins.telescope.keymaps = {
        "<leader>gb" = {
          action = "git_branches";
          options = {
            desc = "Search branches";
            silent = true;
          };
        };
        "<leader>gC" = {
          action = "git_commits";
          options = {
            desc = "Search commits (repo)";
            silent = true;
          };
        };
        "<leader>gc" = {
          action = "git_bcommits";
          options = {
            desc = "Search commits (file)";
            silent = true;
          };
        };
        "<leader>gt" = {
          action = "git_status";
          options = {
            desc = "Git status";
            silent = true;
          };
        };
      };

      plugins.gitsigns = {
        enable = true;
        settings.on_attach = ''
            function(bufnr)
              local normal_opts = {
                  mode = "n", -- NORMAL mode
                  prefix = "<leader>",
                  buffer = bufnr, -- Global mappings. Specify a buffer number for buffer local mappings
                  silent = true, -- use `silent` when creating keymaps
                  noremap = true, -- use `noremap` when creating keymaps
                  nowait = true -- use `nowait` when creating keymaps
              }

              local git_icon = require'nvim-web-devicons'.get_icon("git", "",
                                                                   {default = true})

              local gs = package.loaded.gitsigns;

              local buffer_mapping = {
                  g = {
                      name = git_icon .. " Git",
                      l = {gs.blame_line, "View Git blame"},
                      L = {function() gs.blame_line {full = true} end, "Full git blame"},
                      p = {gs.preview_hunk, "Preview Git hunk"},
                      r = {gs.reset_hunk, "Reset Git hunk"},
                      R = {gs.reset_buffer, "Reset Git buffer"},
                      s = {gs.stage_hunk, "Stage Git hunk"},
                      S = {gs.stage_buffer, "Stage Git buffer"},
                      u = {gs.undo_stage_hunk, "Unstage Git hunk"},
                      d = {gs.diffthis, "View Git diff"},
                      D = {function() gs.diffthis('~') end, "View Git diff"}
                  }
              }

              local wk = require('which-key')
              wk.register(buffer_mapping, normal_opts)

              local visual_opts = normal_opts
              visual_opts.mode = "v";
              local visual_mapping = {
                  g = {
                      s = {
                          function()
                              gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')}
                          end, "Stage Selection"
                      },
                      r = {
                          function()
                              gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')}
                          end, "Stage Selection"
                      }
                  }
              }
              wk.register(visual_mapping, visual_opts)

              local navigation_options = normal_opts
              navigation_options.expr = true
              navigation_options.silent = false
              navigation_options.prefix = nil
              local navigation_mapping = {
                  ["[c"] = {
                      function()
                          if vim.wo.diff then return '[c' end
                          vim.schedule(function() gs.prev_hunk() end)
                          return '<Ignore>'
                      end, "Go to previous chunk"
                  },
                  ["]c"] = {
                      function()
                          if vim.wo.diff then return ']c' end
                          vim.schedule(function() gs.next_hunk() end)
                          return '<Ignore>'
                      end, "Go to next chunk"
                  }
              }
              wk.register(navigation_mapping, navigation_options)

              local text_object_options = normal_opts
              text_object_options.prefix = nil
              local text_object_mapping = {
                  ["ih"] = {':<C-U>Gitsigns select_hunk<CR>', 'Select Hunk'}
              }
              text_object_options.mode = 'o';
              wk.register(text_object_mapping, text_object_options)
              text_object_options.mode = 'x';
              wk.register(text_object_mapping, text_object_options)
          end
        '';
      };
    };
  };
}
