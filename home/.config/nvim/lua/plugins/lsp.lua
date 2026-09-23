-- Servers come from Nix (home.packages in home.nix), not Mason.
-- Neovim's built-in LSP maps: K hover, grn rename, gra code action,
-- grr references, gri implementation, [d / ]d diagnostics.
return {
  {
    'neovim/nvim-lspconfig',  -- only supplies per-server defaults
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'saghen/blink.cmp' },  -- advertises completion capabilities
    config = function()
      vim.diagnostic.config({ virtual_text = true })  -- off by default since 0.11
      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            diagnostics = { globals = { 'vim', 'Snacks' } },
            workspace = { library = { vim.env.VIMRUNTIME }, checkThirdParty = false },
          },
        },
      })
      vim.lsp.enable({ 'lua_ls', 'nixd', 'basedpyright', 'ts_ls' })
    end,
  },
  {
    'saghen/blink.cmp',
    version = '1.*',  -- tagged releases ship a prebuilt fuzzy matcher
    event = 'InsertEnter',
    opts = {
      -- VS Code style: <Tab>/<CR> accept (first item is preselected),
      -- <C-n>/<C-p> move, <C-space> open, <C-e> dismiss
      keymap = {
        preset = 'super-tab',
        ['<CR>'] = { 'accept', 'fallback' },
      },
      sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
      signature = { enabled = true },
    },
  },
}
