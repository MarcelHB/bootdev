vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.number = true

vim.opt.backup = false
vim.opt.swapfile = false

vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.tabstop = 2

vim.opt.background = "light"
vim.opt.signcolumn = "yes"

vim.opt.mouse = "a"
vim.opt.clipboard = "unnamed"

vim.g.mapleader = ","

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- v0.10.0 compatible
require("lazy").setup({
  spec = {
    {
      "hrsh7th/nvim-cmp",
      commit = "2ffe79f1f021def8dd1fcd81deb16f1bb0d989f3",
      dependencies = {
        {
          "hrsh7th/cmp-buffer",
          commit = "b74fab3656eea9de20a9b8116afa3cfc4ec09657",
        },
        {
          "hrsh7th/cmp-nvim-lsp",
          commit = "cbc7b02bb99fae35cb42f514762b89b5126651ef",
        },
        {
          "hrsh7th/cmp-path",
          commit = "c642487086dbd9a93160e1679a1327be111cbc25",
        },
      },
    },
    {
      "lewis6991/gitsigns.nvim",
      tag = "v2.1.0",
    },
    {
      "neovim/nvim-lspconfig",
      tag = "v2.3.0",
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        tag = "v8.13.0",
        dependencies = { 
          { 
            "nvim-treesitter/nvim-treesitter",
            tag = "v0.10.0",
          },
          { 
            "nvim-mini/mini.nvim",
            tag = "v0.18.0",
          },
        },
        ---@module "render-markdown"
        ---@type render.md.UserConfig
        opts = {},
        ft = { "markdown" },
    },
    {
      "nvim-telescope/telescope.nvim",
      tag = "v0.1.9",
dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-fzf-native.nvim",
      },
    },
    {
      "nvim-tree/nvim-tree.lua",
      tag = "v1.18.0",
    },
  },
})

-- cmp (auto completion)
local cmp = require("cmp")
local cmp_config = {
  mapping = {
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        cmp.complete()
      end
    end),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  },
  sources = cmp.config.sources({
    { name = "buffer" },
    { name = "nvim_lsp" },
  })
}
cmp.setup(cmp_config)

local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lsp_config = require("lspconfig")

for _, lsp in ipairs({ 
  "clangd", 
  "lua_ls", 
  "pylsp", 
  "ruby_lsp", 
  "vtsls" 
}) do
  lsp_config[lsp].setup({ capabilities = capabilities })
end

-- gitsigns
vim.api.nvim_create_user_command("Git", "Gitsigns <args>", { nargs = "*" })

-- telescope: (in) file finder
local telescope = require("telescope.builtin")
vim.keymap.set("n", "<leader>f", telescope.find_files, {})
vim.keymap.set("n", "<leader>r", telescope.live_grep, {})
vim.keymap.set("n", "<leader>R", telescope.resume, {})

-- nvim-tree: file tree
local tree_config = {
  renderer = {
    icons = {
      show = {
        bookmarks = false,
        diagnostics = false,
        file = false,
        folder = false,
        folder_arrow = false,
        git = false,
        hidden = false,
      }
    }
  }
}

require("nvim-tree").setup(tree_config)

local tree_api = require("nvim-tree.api")
vim.api.nvim_create_user_command("NERDTree", "NvimTreeToggle", {})
vim.keymap.set("n", "<leader>N", tree_api.tree.toggle, {})

-- treesitter (for markdown)
local treesitter_config = {
  ensure_installed = { "markdown", "markdown_inline" },
}

require("nvim-treesitter.configs").setup(treesitter_config)
