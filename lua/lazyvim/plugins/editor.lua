local Util = require("lazyvim.util")

return {

  -- file explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    keys = {
      {
        "<leader>fe",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = require("lazyvim.util").get_root() })
        end,
        desc = "Explorer NeoTree (root dir)",
      },
      {
        "<leader>fE",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
        end,
        desc = "Explorer NeoTree (cwd)",
      },
      { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (root dir)", remap = true },
      { "<leader>E", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
    },
    deactivate = function()
      vim.cmd([[Neotree close]])
    end,
    init = function()
      vim.g.neo_tree_remove_legacy_commands = 1
      if vim.fn.argc() == 1 then
        local stat = vim.loop.fs_stat(vim.fn.argv(0))
        if stat and stat.type == "directory" then
          require("neo-tree")
        end
      end
    end,
    opts = {
      source_selector = {
        winbar = true,
        statusline = false
      },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = true,
      },
      window = {
        mappings = {
          ["<space>"] = "none",
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        icon = {
          folder_empty = "󰜌",
          folder_empty_open = "󰜌",
        },
        git_status = {
          symbols = {
            renamed = "󰁕",
            unstaged = "󰄱",
          },
        },
      },
    },
  },

  -- search/replace in multiple files
  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    opts = { open_cmd = "noswapfile vnew" },
    -- stylua: ignore
    keys = {
      { "<leader>sr", function() require("spectre").open() end, desc = "Replace in files (Spectre)" },
    },
  },

  -- fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
      "debugloop/telescope-undo.nvim",
        opts = {},
        event = "VeryLazy",
        config = function(_, opts)
          require("telescope").load_extension("undo")
        end,
        keys = {
          { "<leader>fu", "<Cmd>Telescope undo<CR>", desc = "Undo Tree" },
        },
      },
    },
    cmd = "Telescope",
    version = false, -- telescope did only one release, so use HEAD for now
    keys = {
      { "<leader>ff", Util.telescope("files"), desc = "Find Files (root dir)" },
      { "<leader>fw", "<cmd> Telescope live_grep <CR>" },
      { "<leader>fb", "<cmd> Telescope buffers <CR>" },
      { "<leader>fo", "<cmd> Telescope oldfiles <CR>" },
      { "<leader>fk", "<cmd> Telescope keymaps <CR>" },
    },
    opts = {
      defaults = {
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
        },
        prompt_prefix = " ",
        selection_caret = " ",
        mappings = {
          n = {
            ["q"] = function(...)
              return require("telescope.actions").close(...)
            end,
          },
        },
      },
    },
  },

  -- git signs
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    keys = {
      { "<leader>hs", ":Gitsigns stage_hunk<CR>" },
      { "<leader>hu", ":Gitsigns undo_stage_hunk<CR>" },
      { "<leader>hS", ":Gitsigns stage_buffer<CR>" },
      { "<leader>hd", ":Gitsigns diffthis<CR>" },
      {
        "<leader>hD",
        function()
          require("gitsigns").diffthis("~")
        end,
      },
    },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
    },
  },

  -- references
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { "lsp" },
      },
    },
    config = function(_, opts)
      require("illuminate").configure(opts)
    end,
  },

  {
    "liangxianzhe/nap.nvim",
    opts = {
      next_prefix = ",",
      prev_prefix = ",",
      next_repeat = "<c-n>",
      prev_repeat = "<c-p>",
    },
    init = function()
      require("nap").map("t", {
        next = {
          command = function()
            require("trouble").next({ skip_groups = true, jump = true })
          end,
          desc = "Trouble next",
        },
        prev = {
          command = function()
            require("trouble").previous({ skip_groups = true, jump = true })
          end,
          desc = "Trouble previous",
        },
        mode = { "n", "v", "o" },
      })
      require("nap").map("r", {
        next = { command = require("illuminate").goto_next_reference, desc = "Next cursor word" },
        prev = { command = require("illuminate").goto_prev_reference, desc = "Prev cursor word" },
        mode = { "n", "x", "o" },
      })
      require("nap").map("h", {
        next = {
          command = function()
            require("gitsigns").next_hunk({ preview = false, wrap = true })
          end,
          desc = "Next diff",
        },
        prev = {
          command = function()
            require("gitsigns").prev_hunk({ preview = false, wrap = true })
          end,
          desc = "Prev diff",
        },
        mode = { "n", "v", "o" },
      })
    end,
  },

  -- better diagnostics list and others
  {
    "folke/trouble.nvim",
    cmd = { "TroubleToggle", "Trouble" },
    opts = { use_diagnostic_signs = true },
    keys = {
      { "<leader>ld", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document Diagnostics (Trouble)" },
      { "<leader>lw", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics (Trouble)" },
    },
  },

  -- todo comments
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      keywords = {
        FIX = {
          icon = " ", -- icon used for the sign, and in search results
          color = "error", -- can be a hex color, or a named color (see below)
          alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
          -- signs = false, -- configure signs for some keywords individually
        },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },
    },
    config = true,
    -- stylua: ignore
    keys = {
      { "<leader>lt", "<cmd>TodoTrouble<cr>", desc = "Todo (Trouble)" },
      { "<leader>lT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
    },
  },
}
